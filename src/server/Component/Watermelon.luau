--> Services
local rServ = game:GetService("RunService")

local SETTINGS = {
	Tag = "Watermelon",
}

local Component = { Tag = SETTINGS.Tag }
Component.__index = Component

--> Variables

--> Constructor
function Component.new(inst: BasePart)
	local self = setmetatable({
		["_initalized"] = false,
		["_spawned"] = inst.Parent == workspace.Debris,
		["Instance"] = inst,
		["Target"] = nil,
		["hitDebounce"] = false,
	}, Component)

	self:_init()
	return self
end

--> Private functions

--> Component Functions
function Component:ModifyPlayback()
	if not self.Instance then
		return
	end

	self.Instance.Moving.PlaybackSpeed = math.clamp(self.Instance.AssemblyLinearVelocity.Magnitude / 35, 0.85, 2)
end

--> Init Function
function Component:_init()
	if self._initalized == true then
		return
	end
	if not self._spawned then
		return
	end
	self._initalized = true

	local pc = rServ.Heartbeat:Connect(function()
		self:ModifyPlayback()
	end)

	self.Instance.Destroying:Once(function()
		pc:Disconnect()
		self:Destroy()
	end)
end

function Component:Destroy()
	self.Instance = nil
	self.Target = nil
end

return Component
