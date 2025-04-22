local rStore = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")
local CollectionService = game:GetService("CollectionService")
local SoundService = game:GetService("SoundService")

local module = {}

local buttonInfo = TweenInfo.new(0.3, Enum.EasingStyle.Circular, Enum.EasingDirection.Out)

local lPlr = Players.LocalPlayer

local event = rStore.Signals.Remote.OnMapChange
local votingEffectEvent = rStore.Signals.Remote.Unreliable.VotingEffect

local mapData = rStore.Data.Maps
local lobbyData = rStore.Data.Lobbies

local defaultLightingData = require(rStore.Data.DefaultLighting)
local SharedTypes = require(rStore.Data.SharedType)

local musicPlayer: AudioPlayer = SoundService.Music
local musicOutput: AudioDeviceOutput = SoundService.MusicOutput
local defaultWire: Wire? = musicOutput.Music
local musicThread: thread?

local function setLighting(lightingData)
	if lightingData.GlobalWind then
		workspace.GlobalWind = lightingData.GlobalWind
	else
		workspace.GlobalWind = Vector3.zero
	end

	for name, v in lightingData do
		if name == "GlobalWind" then
			continue
		end
		game.Lighting[name] = v
	end
end

local function setUpSoundEffects(sound: Sound)
	local lastEffect: Instance = musicPlayer
	local lastWire: Wire?

	local effects = {}

	for _, inst in pairs(sound:GetChildren()) do
		--ROBLOX WHY DO THESE SOUND EFFECTS NOT HAVE ONE COMMON ABSTRACT CLASS FUCK YOU
		if inst["WiringChanged"] ~= nil then
			table.insert(effects, inst)
		end
	end

	if #effects ~= 0 then
		defaultWire:Destroy()

		for _, effect in ipairs(sound:GetChildren()) do
			local clone = effect:Clone()
			clone.Parent = musicPlayer

			local wire = Instance.new("Wire")
			wire.Parent = clone
			wire.SourceInstance = lastEffect

			if lastWire then
				lastWire.TargetInstance = clone
			end

			lastWire = wire
		end

		(lastWire :: Wire).TargetInstance = musicOutput
	end
end

local function createDefaultWire()
	local wire = Instance.new("Wire")
	wire.Parent = musicOutput
	wire.SourceInstance = musicPlayer
	wire.TargetInstance = musicOutput
	wire.Name = "Music"
	defaultWire = wire
end

local function onMapChange(mapName: string, isLobby: boolean?)
	local mapDataFolder: Folder

	if musicThread then
		task.cancel(musicThread)
	end

	musicPlayer:Stop()
	musicPlayer.Asset = ""
	musicPlayer.Looping = false
	musicPlayer.TimePosition = 0

	if not defaultWire then
		createDefaultWire()
	end

	if isLobby then
		mapDataFolder = lobbyData:FindFirstChild(mapName)
	else
		mapDataFolder = mapData:FindFirstChild(mapName)
	end

	if not mapDataFolder then
		setLighting(defaultLightingData)
		warn(`Map "{mapName}" does not have corresponding mapData folder!`)
	else
		local tracks = mapDataFolder:FindFirstChild("Tracks")
		local lightingData = mapDataFolder:FindFirstChild("Lighting")
		local ui = mapDataFolder:FindFirstChild("UI")
		local postFx = mapDataFolder:FindFirstChild("PostEffects")
		local skybox = mapDataFolder:FindFirstChildWhichIsA("Sky")
		local clouds = mapDataFolder:FindFirstChildWhichIsA("Clouds")

		lPlr.PlayerGui:WaitForChild("MapFx"):ClearAllChildren()

		for _, v in pairs(game.Lighting:GetChildren()) do
			if not v:HasTag("UnderwaterEffect") then
				v:Destroy()
			end
		end

		local t_clouds = workspace.Terrain:FindFirstChildWhichIsA("Clouds")
		if t_clouds then
			t_clouds:Destroy()
		end

		if skybox then
			skybox:Clone().Parent = game.Lighting
		end

		if not lightingData then
			setLighting(defaultLightingData)
		else
			setLighting(require(lightingData))
		end

		if ui == nil or postFx == nil then
			warn("aaaa")
			return
		end

		if clouds then
			local c = clouds:Clone()
			c.Parent = workspace.Terrain
		end

		for _, v in pairs(ui:GetChildren()) do
			if v:IsA("GuiObject") then
				local c = v:Clone()
				c.Visible = true
				c.Parent = lPlr.PlayerGui.MapFx
			end
		end

		for _, v in pairs(postFx:GetChildren()) do
			local c = v:Clone()
			if c:IsA("PostEffect") then
				c.Enabled = true
			end
			c.Parent = game.Lighting
		end

		if tracks then
			local sounds: { Sound } = {}
			for _, inst in pairs(tracks:GetChildren()) do
				if inst:IsA("Sound") then
					table.insert(sounds, inst)
				end
			end

			if #sounds ~= 0 then
				if #sounds == 1 then
					local sound = sounds[1]
					setUpSoundEffects(sound)
					musicPlayer.Asset = sound.SoundId
					musicPlayer:Play()
					musicPlayer.Looping = true
				else
					musicThread = task.spawn(function()
						local idx = 1

						while true do
							if idx > #sounds then
								idx = 1
							end

							musicPlayer:ClearAllChildren()
							musicPlayer.TimePosition = 0

							local sound = sounds[idx]
							setUpSoundEffects(sound)
							musicPlayer.Asset = sound.SoundId

							local waitTime: number? = sound:GetAttribute("DelayTimeBeforePlay")

							if waitTime then
								task.wait(waitTime)
							end

							musicPlayer:Play()
							musicPlayer.Ended:Wait()

							idx += 1
						end
					end)
				end
			end
		end
	end
end

local function votingEffect(mdl: Model)
	local data = require(rStore.Data.Lobbies[workspace.MainMap:FindFirstChildWhichIsA("Model").Name].LobbyData)

	local button: BasePart = mdl.Button
	local sound = button:FindFirstChild("TouchSound")

	if not sound then
		--TODO: make this an acctual sound in assets
		sound = rStore.Assets.DefaultTouchSound
	end

	local c: Sound = sound:Clone()
	c.Parent = button
	c.RollOffMinDistance = 24
	c.RollOffMaxDistance = 72
	c:Play()

	task.spawn(function()
		c.Ended:Wait()
		c:Destroy()
	end)

	local b_clone = button:Clone()
	b_clone.Parent = workspace.Debris
	b_clone.CanCollide = false
	b_clone.CanTouch = false
	b_clone.CanQuery = false
	b_clone.CastShadow = false
	b_clone.Color = button:GetAttribute("VoteColor") or Color3.fromHSV(0.308056, 0.827451, 1)
	local t = TweenService:Create(b_clone, buttonInfo, {
		Size = b_clone.Size * Vector3.new(1.2, 1, 1.2),
		Position = b_clone.Position + Vector3.new(0, 3, 0),
		Transparency = 1,
	})

	local b_tween = TweenService:Create(button, buttonInfo, {
		Color = button:GetAttribute("VoteColor") or Color3.fromHSV(0.308056, 0.827451, 1),
	})

	b_tween:Play()
	t:Play()
	Debris:AddItem(b_clone, buttonInfo.Time)

	local otherButtons = CollectionService:GetTagged("LobbyMapButton")

	for _, bt in pairs(otherButtons) do
		if bt == mdl then
			continue
		end

		local button: BasePart = bt.Button
		button.Color = data.DefaultColor
	end
end

function module.Start()
	event.OnClientEvent:Connect(onMapChange)
	votingEffectEvent.OnClientEvent:Connect(votingEffect)
end

return module
