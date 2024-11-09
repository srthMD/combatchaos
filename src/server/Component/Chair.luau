--> Services
local rServ = game:GetService("RunService")

local SETTINGS = {
	Tag = "Chair",
}

local Component = { Tag = SETTINGS.Tag }
Component.__index = Component

--> Variables

--> Constructor
function Component.new(inst: BasePart)
	local self = setmetatable({
		["_initalized"] = false,
		["Instance"] = inst,
		["_spawned"] = inst:IsDescendantOf(workspace.MainMap),
	}, Component)

	self:_init()
	return self
end

--> Private functions

--> Component Functions

--> Init Function
function Component:_init()
	if self._initalized == true then
		return
	end
	if not self._spawned then
		return
	end
	self._initalized = true

	self.con = rServ.Heartbeat:Connect(function()
		self.Instance.Moving.Volume = math.clamp(self.Instance.AssemblyLinearVelocity.Magnitude / 25, 0, 0.5)
	end)

	self.Instance.Destroying:Connect(function()
		self:Destroy()
	end)
end

function Component:Destroy()
	if self.con.Connected then
		self.con:Disconnect()
	end
	self.Instance = nil
end

return Component
