local rStore = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local SETTINGS = {
	Tag = "Plate",
}

local Component = { Tag = SETTINGS.Tag }
Component.__index = Component

local CreateProjectileEvent = rStore.Signals.Client.CreateProjectile
local Player = Players.LocalPlayer
local Mouse = Player:GetMouse()

function Component.new(inst: Tool)
	local self = setmetatable({
		["_initalized"] = false,
		["Instance"] = inst,
		["debounce"] = false,
	}, Component)

	self:_init()
	return self
end

function Component:_init()
	if self._initalized == true then
		return
	end
	self._initalized = true

	self.Instance.Activated:Connect(function()
		if not self.debounce then
			self.debounce = true

			local tool: BasePart = self.Instance:FindFirstChild("Handle")

			local hPos = self.Instance.Handle.Position
			local mHit = Mouse.Hit.Position
			local dir = (mHit - hPos).Unit

			CreateProjectileEvent:Fire("Plate", hPos, dir)
			tool.Transparency = 1

			task.wait(self.Instance.Cooldown.Value)
			self.debounce = false
			tool.Transparency = 0
		end
	end)

	self.Instance.Destroying:Connect(function()
		self:Destroy()
	end)
end

function Component:Destroy()
	self.Instance = nil
end

return Component
