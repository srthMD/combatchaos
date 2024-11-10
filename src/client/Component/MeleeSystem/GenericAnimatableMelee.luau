--> Services
local rStore = game:GetService("ReplicatedStorage")

--> Component Framework Dependencies
local Rcade = require(rStore.Shared.Rcade)

local SETTINGS = {
	Tag = "GenericAnimatableMelee",
}

--> Class Definition
local Super = require(script.Parent.Parent.AbstractComponents.BaseMelee)
local GenericAnimatable = Rcade.class({ __super = Super, Tag = SETTINGS.Tag })

--> Variables
local urev_OnEquip = rStore.Signals.Remote.Unreliable.OnEquipMelee

--> Constructor
function GenericAnimatable:__init(inst: Tool)
	self.__super.__init(self, inst)
	self:__backendInit()
end

--> Backend Constructor
function GenericAnimatable:__backendInit(): ()
	if self.Instance == nil then
		return
	end

	self.Instance.Activated:Connect(function()
		self:OnActivate()
	end)

	self.Instance.Equipped:Connect(function()
		self:OnEquip()
	end)

	self.Instance.Destroying:Connect(function()
		self:Destroy()
	end)
end

--> Private Functions
-- not inheritable

--> Module Functions
function GenericAnimatable:OnActivate(): ()
	if self.Debounce then
		return
	end
	self.Debounce = true

	local hrp: BasePart = self.Instance.Parent:FindFirstChild("HumanoidRootPart")
	local hCFrame = hrp.CFrame

	self.Event:Fire(self.Data.BackendName, hCFrame)

	local cooldown

	if self.Instance:FindFirstChild("Cooldown") then
		cooldown = self.Instance.Cooldown.Value
	else
		cooldown = self.Data.Cooldown
	end

	task.delay(cooldown, function()
		self.Debounce = false
	end)
end

function GenericAnimatable:OnEquip(): ()
	if not self.EquipDB then
		self.EquipDB = true

		urev_OnEquip:FireServer(self.Data.BackendName, self.Instance)
		task.delay(0.15, function()
			self.EquipDB = false
		end)
	end
end

return GenericAnimatable
