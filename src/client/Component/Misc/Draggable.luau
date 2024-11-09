--this is old, need to replace this with new UIDragger instance someday

local rStore = game:GetService("ReplicatedStorage")

local SETTINGS = {
	Tag = "Draggable",
}

local Component = { Tag = SETTINGS.Tag }
Component.__index = Component

local module = require(rStore.Libs.DraggableObject)

function Component.new(inst: Frame)
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

	local draggable = module.new(self.Instance)

	draggable:Enable()

	self.Instance.Destroying:Once(function()
		draggable:Disable()
		self:Destroy()
	end)
end

function Component:Destroy()
	self.Instance = nil
end

return Component
