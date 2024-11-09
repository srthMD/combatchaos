local TweenService = game:GetService("TweenService")

local SETTINGS = {
	Tag = "ScrollingPattern",
}

local Component = { Tag = SETTINGS.Tag }
Component.__index = Component

local lPlr = game.Players.LocalPlayer

local info = TweenInfo.new(60, Enum.EasingStyle.Linear)
local goal = { Position = UDim2.fromScale(-1, -0.85) }

local function stepImage(image: ImageLabel)
	local tween = TweenService:Create(image, info, goal)
	tween:Play()

	tween.Completed:Wait()

	image.Position = UDim2.fromScale(0, 0)
end

function Component.new(inst: Frame)
	if not inst:IsDescendantOf(lPlr.PlayerGui) then
		return nil
	end

	local self = setmetatable({
		["_initalized"] = false,
		["Instance"] = inst,
	}, Component)

	self:_init()
	return self
end

function Component:_init()
	if self._initalized == true then
		return
	end
	self._initalized = true

	self.thread = task.spawn(function()
		while true do
			stepImage(self.Instance :: ImageLabel)
		end
	end)
end

function Component:Destroy()
	self.Instance = nil
	task.cancel(self.thread)
	self.thread = nil
end

return Component
