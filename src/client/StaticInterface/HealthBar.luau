local rStore = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local StarterGui = game:GetService("StarterGui")
local RunService = game:GetService("RunService")

local info = TweenInfo.new(0.08, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)

local MAX_AS_SCALE = 0.1
local MIN_AS_SCALE = -1
local BASE_HUE = 0.35
local BASE_SAT = 0.75
local BASE_VALUE = 0.85

local lPlr = game.Players.LocalPlayer

local events = rStore.Signals
local assets = rStore.Assets

local voteStarted = events.Remote.Voting.VoteStart
local voteEnd = events.Remote.Voting.VoteEnd
local sendTime = events.Remote.Unreliable.SendTime

local ui: CanvasGroup

local function characterAdd(char: Model)
	local hum: Humanoid = char:WaitForChild("Humanoid", 6)

	if not hum then
		return
	end
	
	if not hum:IsA("Humanoid") then
		return
	end
	
	--reset stuff to defaults
	local health = hum.Health
	local max = hum.MaxHealth
	
	ui.Health.Bar.BackgroundColor3 = Color3.fromHSV(BASE_HUE, BASE_SAT, BASE_VALUE)
	ui.Health.Info.Numbers.Text = string.format(" %d/%d", health, max)
	ui.Health.Bar.UIGradient.Offset = Vector2.new(0.1, 0)

	
	local con = hum.Changed:Connect(function(property: string)
		if property == "Health" then
			local health = hum.Health
			local max = hum.MaxHealth

			local scale = health/max - 1
			local hue = ((scale - MIN_AS_SCALE) / (MAX_AS_SCALE - MIN_AS_SCALE)) * BASE_HUE
			ui.Health.Bar.BackgroundColor3 = Color3.fromHSV(math.max(hue, 0), BASE_SAT, BASE_VALUE)
			
			ui.Health.Info.Numbers.Text = string.format(" %d/%d", health, max)
			TweenService:Create(ui.Health.Bar.UIGradient, info, {Offset = Vector2.new(scale, 0)}):Play()
		elseif property == "MaxHealth" then
			local health = hum.Health
			local max = hum.MaxHealth
			
			ui.Health.Info.Numbers.Text = string.format(" %d/%d", health, max)
		end
	end)
	
	hum.Died:Once(function()
		con:Disconnect()
		con = nil
	end)
end

local function setTime(t: number)
	local label: TextLabel = ui.Time
	
	label.Text = string.format( "%d", t)
end

return function(CoreUI: ScreenGui)
	local main = assets.StaticInterface.Main

	main.Parent = CoreUI
	ui = main

	voteStarted.OnClientEvent:Connect(function()
		main.Visible = false
	end)

	voteEnd.OnClientEvent:Connect(function()
		main.Visible = true
	end)
	
	sendTime.OnClientEvent:Connect(setTime)

	lPlr.CharacterAdded:Connect(characterAdd)
end