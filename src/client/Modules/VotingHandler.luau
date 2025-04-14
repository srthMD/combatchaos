--> Services
local rStore = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")
local CollectionService = game:GetService("CollectionService")

--> Variables
local module = {}

local info = TweenInfo.new(1.25, Enum.EasingStyle.Linear)
local buttonCenterInfo = TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
local playerIconInfo = TweenInfo.new(0.15, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
local buttonInfo = TweenInfo.new(0.3, Enum.EasingStyle.Circular, Enum.EasingDirection.Out)

local playerIconDefaultSize = UDim2.fromScale(0.15, 0.15)

local lPlr = Players.LocalPlayer
local Mouse = lPlr:GetMouse()

local votingEvents = rStore.Signals.Remote:WaitForChild("Voting")

local votingRes = rStore.Assets.Voting

local votingUi = votingRes.Voting
local mapButton = votingRes.Map
local playerIconUI = votingRes.Player
local voteClickSound = votingRes.Click

local event = rStore.Signals.Remote.OnMapChange
local votingEffectEvent = rStore.Signals.Remote.Unreliable.VotingEffect

local mapData = rStore.Data.Maps
local lobbyData = rStore.Data.Lobbies

local defaultLightingData = require(rStore.Data.DefaultLighting)

local SharedTypes = require(rStore.Data.SharedType)

local tipTexts: {string} = require(rStore.Data.MenuTips)

--> Private Functions

local function offsetToScale(u: UDim2, ui: ScreenGui)
	local screensize = ui.AbsoluteSize
	return UDim2.new(
		u.X.Offset/screensize.X, 0,
		u.Y.Offset/screensize.Y, 0
	)
end

local function vector2toUDim2Offset(v: Vector2)
	return UDim2.new(
		0,v.X,
		0,v.Y
	)
end

local function getPlayerThumbnails(): { [string]: any }
	local thumbnails = {}

	for _, plr in pairs(Players:GetPlayers()) do
		local suc, thumbnail = pcall(function()
			return Players:GetUserThumbnailAsync(
				plr.UserId,
				Enum.ThumbnailType.HeadShot,
				Enum.ThumbnailSize.Size180x180
			)
		end)

		if suc then
			thumbnails[plr.Name] = thumbnail
		end
	end

	return thumbnails
end

local function votingStarted(
	dat: { string }?,
	voteDict: SharedTypes.VoteDict?,
	seconds: number,
	serverTime: number
): ScreenGui
	if lPlr.PlayerGui:FindFirstChild("Voting") then
		lPlr.PlayerGui.Voting:Destroy()
	end

	local ccCore = lPlr.PlayerGui:FindFirstChild("CC_Core")
	if ccCore then
		ccCore.Enabled = false
	else
		warn("CC_Core GUI not found in PlayerGui")
	end

	local ui = votingUi:Clone()

	for _, inst in pairs(ui.VotingMain.Maps:GetChildren()) do
		if inst:IsA("ImageButton") then
			inst:Destroy()
		end
	end
	
	local tipText = ui.VotingMain.Tip
	local selectedText = tipTexts[math.random(1, #tipTexts)]
	
	tipText.Text = selectedText

	local maps = {}
	if dat then
		maps = dat
	else
		for map, _ in pairs(voteDict :: SharedTypes.VoteDict) do
			table.insert(maps, map)
		end
	end

	ui.VotingMain.Maps.UIListLayout.Padding = UDim.new(0.1 - (0.025 * (#maps - 3)), 0)

	ui.Parent = lPlr.PlayerGui
	ui.VotingMain.Visible = true
	TweenService:Create(ui.VotingMain, info, { GroupTransparency = 0 }):Play()

	local blur = Instance.new("BlurEffect")
	blur.Parent = game.Lighting
	blur.Name = "VotingBlur"
	blur.Size = 0

	TweenService:Create(blur, info, { Size = 24 }):Play()

	local db = false

	for _, mapName in pairs(maps) do
		local button = mapButton:Clone()
		button.Name = mapName
		button.MapName.Text = mapName

		local data: Folder = mapData:WaitForChild(mapName)

		if data then
			local image = data:FindFirstChild("Image")

			if image and image:IsA("StringValue") then
				button.Image = image.Value
				button.ImageColor3 = Color3.new(255, 255, 255)
			end
		else
			warn(`Unknown map {mapName}.`)
			warn(debug.traceback())
		end

		local _connection = button.MouseButton1Click:Connect(function()
			if db == true then
				return
			end

			db = true

			task.delay(0.3, function()
				db = false
			end)

			local x, y = Mouse.X, Mouse.Y

			local size = button.AbsoluteSize
			local pos = button.AbsolutePosition
			local xScale, yScale = (x - pos.X) / size.X, (y - pos.Y) / size.Y

			votingEvents.VoteSubmitted:FireServer(mapName, UDim2.fromScale(xScale, yScale))
		end)

		button.Parent = ui.VotingMain.Maps
	end

	return ui
end

local function votingEnded(ui: ScreenGui, chosenMap: string)
	print("Voting Ended, chose "..chosenMap)
	-- this runs after a map is chosen
	-- it's me, devwing again
	-- I added tweening for the chosen map so it gets put in the center and allat
	
	local mainFrame = ui:FindFirstChild("VotingMain")

	if not mainFrame then
		return
	end

	local maps: Frame = mainFrame:FindFirstChild("Maps")
	if not maps then
		return
	end

	local c = votingRes.Successful:Clone()
	c.Parent = ui
	c:Play()

	task.spawn(function()
		c.Ended:Wait()
		c:Destroy()
	end)
	
	local mapDataFolder = mapData:FindFirstChild(chosenMap)
	
	local button = maps[chosenMap]
	local bclone = button:Clone()
	
	bclone.Parent = ui
	
	bclone.Position = vector2toUDim2Offset(button.AbsolutePosition - votingUi.AbsolutePosition)
	bclone.Size = vector2toUDim2Offset(button.AbsoluteSize)
	
	bclone.Position = offsetToScale(bclone.Position, ui)
	bclone.Size = offsetToScale(bclone.Size, ui)
	
	bclone.AnchorPoint = button.AnchorPoint
	
	--bclone:FindFirstChildWhichIsA("UIAspectRatioConstraint").AspectType = Enum.AspectType.FitWithinMaxSize
	
	bclone.Visible = false
	
	for _, b in pairs(maps:GetChildren()) do -- tweens for the other map buttons
		if b:IsA("ImageButton") then -- this code is very spaghetti 🍝
			local uielements = {}
			
			for _,e in b:GetDescendants() do
				if e:IsA("ImageLabel") then
					TweenService:Create(e, info, { BackgroundTransparency = 1, ImageTransparency = 1 }):Play()
				elseif e:IsA("UIStroke") or e:IsA("TextLabel") then
					TweenService:Create(e, info, { Transparency = 1 }):Play()
				end
			end
			
			TweenService:Create(b, info, { BackgroundTransparency = 1, ImageTransparency = 1 }):Play()
		end
	end
	
	
	bclone.Visible = true
	
	-- tweens for the winning map button
	
	TweenService:Create(bclone.UIStroke, info, { Color = Color3.new(0.0941176, 1, 0.0313725) }):Play()
	TweenService:Create(bclone, buttonCenterInfo, {
		Size = UDim2.new(0.209, 0, 0.444, 0),
		Position = UDim2.new(0.395, 0, 0.397, 0)
	}):Play()
	
	local creators = mapDataFolder:FindFirstChild("Creators")

	if creators then
		bclone.MadeBy.Text = "Made by: "..creators.Value
		
		TweenService:Create(bclone.MadeBy, info, { TextTransparency = 0 }):Play()
		TweenService:Create(bclone.MadeBy.UIStroke, info, { Transparency = 0 }):Play()
	end
	
	task.wait(5)

	local blur = game.Lighting:FindFirstChild("VotingBlur")
	if blur then
		blur:Destroy()
	end

	ui:Destroy()

	local ccCore = lPlr.PlayerGui:FindFirstChild("CC_Core")
	if ccCore then
		ccCore.Enabled = true
	else
		warn("CC_Core GUI not found in PlayerGui")
	end
end

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

local function onMapChange(mapName: string, isLobby: boolean?)
	local mapDataFolder: Folder
	
	if isLobby then
		mapDataFolder = lobbyData:FindFirstChild(mapName)
	else
		mapDataFolder = mapData:FindFirstChild(mapName)
	end

	if not mapDataFolder then
		setLighting(defaultLightingData)
		warn(`Map "{mapName}" does not have corresponding mapData folder!`)
	else
		local lightingData = mapDataFolder:FindFirstChild("Lighting")
		local ui = mapDataFolder:FindFirstChild("UI")
		local postFx = mapDataFolder:FindFirstChild("PostEffects")
		local skybox = mapDataFolder:FindFirstChildWhichIsA("Sky")
		local clouds = mapDataFolder:FindFirstChildWhichIsA("Clouds")
		
		-- it's me, devwing
		-- I added a "Creators" StringValue to every map under Data/Maps so we can give credit to the creator(s)
		-- The values are separated by comma ',', and they're just the usernames
		-- maybe we should add a way to get someone's username from the ID, though, because we can change username
		
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
	end
end

local function createPlayerIcon(plr: Player, map: string, pos: UDim2, ui: ScreenGui, thumbnails: { [string]: any })
	local mainFrame = ui:FindFirstChild("VotingMain")

	if not mainFrame then
		warn("Ui not present when trying to create player icon")
		return
	end

	local playerIcon: ImageLabel?

	for _, v in pairs(mainFrame.Maps:GetChildren()) do
		if v:IsA("ImageButton") then
			for _, c in pairs(v:GetChildren()) do
				if c.Name == plr.Name then
					playerIcon = c
				end
			end
		end
	end

	local mapButton = mainFrame.Maps[map]

	if playerIcon ~= nil then
		task.spawn(function()
			local t = TweenService:Create(playerIcon, playerIconInfo, {
				Size = UDim2.new(0, 0, 0, 0),
				Transparency = 1,
			})

			local t2 = TweenService:Create(playerIcon.UIStroke, info, {
				Transparency = 1,
				Thickness = 0,
			})

			t:Play()
			t2:Play()

			task.spawn(function()
				t.Completed:Wait()
				playerIcon:Destroy()
			end)
		end)
	end

	local suc, _ = pcall(function()
		return thumbnails[plr.Name]
	end)

	if not suc then
		local suc, thumbnail = pcall(function()
			return Players:GetUserThumbnailAsync(
				plr.UserId,
				Enum.ThumbnailType.HeadShot,
				Enum.ThumbnailSize.Size180x180
			)
		end)

		if suc then
			thumbnails[plr.Name] = thumbnail
		end
	end

	local newIcon = playerIconUI:Clone()
	newIcon.Name = plr.Name
	newIcon.Position = pos
	newIcon.Size = UDim2.new(0, 0, 0, 0)
	newIcon.Transparency = 1
	newIcon.Image = thumbnails[plr.Name]
	newIcon.ZIndex = math.random(10, 20)
	newIcon.UIStroke.Transparency = 1
	newIcon.UIStroke.Thickness = 0
	newIcon.Parent = mapButton
	newIcon.Visible = true

	TweenService:Create(newIcon, playerIconInfo, {
		Size = playerIconDefaultSize,
		Transparency = 0,
	}):Play()

	TweenService:Create(newIcon.UIStroke, playerIconInfo, {
		Transparency = 0,
		Thickness = 2.5,
	}):Play()

	voteClickSound:Play()
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
		Color = button:GetAttribute("VoteColor") or Color3.fromHSV(0.308056, 0.827451, 1)
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

--> Module Functions

--> Loader Methods
function module.Start()
	event.OnClientEvent:Connect(onMapChange)
	
	votingEffectEvent.OnClientEvent:Connect(votingEffect)

	votingEvents.VoteStart.OnClientEvent:Connect(
		function(maps: { string }?, voteDict: SharedTypes.VoteDict?, seconds: number, serverTime: number)
			local thumbnails = getPlayerThumbnails()

			local ui: ScreenGui = nil

			if maps ~= nil then
				ui = votingStarted(maps, nil, seconds, serverTime)
			else
				ui = votingStarted(nil, voteDict :: SharedTypes.VoteDict, seconds, serverTime)

				for map, tbl in pairs(voteDict :: SharedTypes.VoteDict) do
					for _, dat in pairs(tbl) do
						createPlayerIcon(dat.player, map, dat.clickPos, ui, thumbnails)
					end
				end
			end

			local con = votingEvents.VoteRecv.OnClientEvent:Connect(function(plr: Player, map: string, pos: UDim2)
				createPlayerIcon(plr, map, pos, ui, thumbnails)
			end)

			votingEvents.VoteEnd.OnClientEvent:Connect(function(chosenMap: string)
				con:Disconnect()

				votingEnded(ui, chosenMap)
			end)
		end
	)
end

return module
