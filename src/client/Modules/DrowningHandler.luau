--Im thinking 🤔🤔🤔🤔🤔🤔🤔🤔🤔🤔🤔🤔🤔🤔🤔🤔🤔🤔🤔🤔🤔🤔🤔🤔
local rStore = game:GetService("ReplicatedStorage")
local tServ = game:GetService("TweenService")

local module = {}

local plr = game.Players.LocalPlayer

--How long a player can stay underwater in seconds
local MAX_AIR = 8
--How often the player should be damaged when drowning
local TICK = 1
--How much damage should be taken every tick
local TICK_DMG = 1 / 9 * 100

-- local ATMO_DISABLED = {
-- 	Density = 0,
-- 	Offset = 0,
-- 	Color = Color3.new(1, 1, 1),
-- 	Decay = Color3.new(1, 1, 1),
-- 	Glare = 0,
-- 	Haze = 0,
-- }

-- local ATMO_DEFAULT = {
-- 	Density = 0.85,
-- 	Offset = 0,
-- 	Glare = 0.7,
-- 	Haze = 10,
-- }

local BLUR_SIZE = 9

local sync = rStore.Signals.Remote.SyncDrowning
local tickSound = rStore.Assets.Drowning.Hurt

local underwater = false

-- local underwaterAtmo: Atmosphere
local underwaterBlur: BlurEffect

local info = TweenInfo.new(0.6, Enum.EasingStyle.Circular)

local tweens = {}

local function isDrowning(airTime: number): boolean
	return underwater and airTime <= 0
end

local function updateBar(airFrame: Frame, airTime: number)
	local bar = airFrame:FindFirstChild("Bar")

	if not bar or not bar:IsA("Frame") then
		return
	end

	if not airFrame.Visible then
		return
	end

	bar.Size = UDim2.fromScale(1, airTime / MAX_AIR)
end

local lastState = false

local function toggleEffects(state: boolean)
	if lastState ~= state then
		for _, t in pairs(tweens) do
			if t and t.PlaybackState == Enum.PlaybackState.Playing then
				t:Cancel()
			end
		end

		tweens = {}
	end

	if state == true then
		-- local goalTable = {}

		-- for name, val in pairs(ATMO_DEFAULT) do
		-- 	goalTable[name] = val
		-- end

		-- local tint = workspace.Terrain.WaterColor
		-- goalTable["Color"] = tint
		-- local h, s, v = tint:ToHSV()
		-- goalTable["Decay"] = Color3.fromHSV(h, s, math.max(v - 0.2, 0))

		-- local t = tServ:Create(underwaterAtmo, info, goalTable)
		-- table.insert(tweens, t)
		-- t:Play()

		underwaterBlur.Enabled = true
		local t2 = tServ:Create(underwaterBlur, info, { Size = BLUR_SIZE })
		table.insert(tweens, t2)
		t2:Play()
	else
		-- local goalTable = {}

		-- for name, val in pairs(ATMO_DISABLED) do
		-- 	goalTable[name] = val
		-- end

		-- local t = tServ:Create(underwaterAtmo, info, goalTable)
		-- table.insert(tweens, t)
		-- t:Play()

		local t2 = tServ:Create(underwaterBlur, info, { Size = 0 })
		table.insert(tweens, t2)
		t2:Play()
	end

	lastState = state
end

local function onCharAdded(char: Model)
	local bar: Frame = plr.PlayerGui.CC_Core:FindFirstChild("Air")

	if not bar then
		warn("air bar not found")
		return
	end

	local airTime = MAX_AIR

	local head = char:WaitForChild("Head")
	local hum = char:FindFirstChildWhichIsA("Humanoid")

	if not hum or not head then
		warn("cant find head or humanoid")
		return
	end

	local tickThread = task.spawn(function()
		while true do
			if isDrowning(airTime) then
				sync:FireServer(TICK_DMG)
				local clone = tickSound:Clone()
				clone.Parent = workspace.Debris
				clone:Play()

				task.spawn(function()
					clone.Ended:Wait()
					clone:Destroy()
				end)

				task.wait(TICK)
			else
				task.wait()
			end
		end
	end)

	local airTimeThread = task.spawn(function()
		while true do
			local dt = task.wait(1 / 30)

			local min = head.Position - (0.5 * head.Size)
			local max = head.Position + (0.5 * head.Size)
			local region = Region3.new(min, max):ExpandToGrid(4)

			local water = workspace.Terrain:ReadVoxelChannels(region, 4, { "LiquidOccupancy" })

			if water and water.Size.X ~= 0 and water.Size.Y ~= 0 and water.Size.Z ~= 0 then
				local material = water["LiquidOccupancy"][1][1][1]
				print(water.Size)

				if material >= 0.25 then
					underwater = true
					bar.Visible = true
					airTime = math.max(airTime - (1.2 * dt), 0)
					toggleEffects(true)
					updateBar(bar, airTime)
				else
					underwater = false
					if not (airTime >= MAX_AIR) then
						bar.Visible = true
						airTime = math.min(airTime + (0.75 * dt), MAX_AIR)
						toggleEffects(false)
						updateBar(bar, airTime)
					else
						task.delay(0.5, function()
							if not underwater then
								bar.Visible = false
							end
						end)
					end
				end
			end
		end
	end)

	local c1
	local c2

	c1 = plr.CharacterRemoving:Once(function()
		c2:Disconnect()
		task.cancel(airTimeThread)
		task.cancel(tickThread)
		toggleEffects(false)
		underwater = false
	end)

	c2 = hum.Died:Once(function()
		c1:Disconnect()
		task.cancel(airTimeThread)
		task.cancel(tickThread)
		toggleEffects(false)
		underwater = false
	end)
end

function module.Start()
	plr.CharacterAdded:Connect(onCharAdded)

	underwaterBlur = Instance.new("BlurEffect")
	underwaterBlur.Enabled = false
	underwaterBlur.Size = 0
	underwaterBlur.Parent = game.Lighting
	underwaterBlur.Name = "UnderwaterBlur"
	underwaterBlur:AddTag("UnderwaterEffect")

	-- underwaterAtmo = Instance.new("Atmosphere")
	-- underwaterAtmo.Parent = game.Lighting
	-- underwaterAtmo.Name = "UnderwaterAtmo"
	-- underwaterAtmo:AddTag("UnderwaterEffect")
	-- underwaterAtmo.Color = Color3.new(1, 1, 1)
	-- underwaterAtmo.Decay = Color3.new(1, 1, 1)
	-- underwaterAtmo.Density = 0
end

return module
