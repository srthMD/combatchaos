local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local lPlr = game.Players.LocalPlayer

local Component = require(ReplicatedStorage.Packages.Component)
local ScrollingPattern = Component.new({ Tag = "ScrollingPattern", Ancestors = { lPlr.PlayerGui } })

local info = TweenInfo.new(60, Enum.EasingStyle.Linear)
local goal = { Position = UDim2.fromScale(-1, -0.85) }

local function stepImage(image: ImageLabel)
	local tween = TweenService:Create(image, info, goal)
	tween:Play()

	tween.Completed:Wait()

	image.Position = UDim2.fromScale(0, 0)
end

function ScrollingPattern:Construct()
	self.thread = task.spawn(function()
		while true do
			stepImage(self.Instance :: ImageLabel)
		end
	end)
end

function ScrollingPattern:Stop()
	task.cancel(self.thread)
	self.thread = nil
end

return ScrollingPattern
