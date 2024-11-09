--> Services
local rStore = game:GetService("ReplicatedStorage")

local SETTINGS = {
	Tag = "Cat",
}

local Component = { Tag = SETTINGS.Tag }
Component.__index = Component

--> Variables
local bounce = rStore.Assets.ItemDeps.CatTube.bounce

--> Constructor
function Component.new(inst: BasePart)
	local self = setmetatable({
		["_initalized"] = false,
		["_spawned"] = inst.Parent == workspace.Debris,
		["Instance"] = inst,
		["hitDebounce"] = false,
	}, Component)

	self:_init()
	return self
end

--> Private functions

--> Component Functions
function Component:OnHit()
	if not self.hitDebounce then
		self.hitDebounce = true

		local boingClone = bounce:Clone()
		boingClone.Parent = self.Instance
		boingClone.PlaybackSpeed = math.random(2, 2.3)
		boingClone:Play()

		task.spawn(function()
			boingClone.Ended:Wait()
			boingClone:Destroy()
		end)

		task.wait(0.1)
		self.hitDebounce = false
	end
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

	local tc = self.Instance.Touched:Connect(function()
		self:OnHit()
	end)

	self.Instance.Destroying:Once(function()
		tc:Disconnect()
		self:Destroy()
	end)
end

function Component:Destroy()
	self.Instnace = nil
end

return Component
