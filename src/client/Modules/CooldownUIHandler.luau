--> Services
local Players = game:GetService("Players")
local rStore = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

--> Variables
local module = {}

local plr = Players.LocalPlayer

local event = rStore.Signals.Client.CreateCooldownUI

local frame = rStore.Assets.StaticInterface.Cooldown
--> Private Functions

function createUI(text: string, length: number, color: Color3?)
	local ui = plr.PlayerGui.CC_Core.cg
	
	if not color then
		color = Color3.fromRGB(179, 179, 179)
	end
	
	local current = frame:Clone()
	current.bar.BackgroundColor3 = color
	current.text.Text = text
	current.Parent = ui
	
	local info = TweenInfo.new(length, Enum.EasingStyle.Linear, Enum.EasingDirection.In)
	
	local t = TweenService:Create(current.bar, info, {Size = UDim2.fromScale(0, 1)})
	t:Play()
	
	t.Completed:Wait()
	current:Destroy()
end

--> Module Functions

--> Loader Methods
function module.Start()
	event.Event:Connect(createUI)
end

return module
