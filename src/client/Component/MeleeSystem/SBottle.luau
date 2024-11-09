--> Services
local rStore = game:GetService("ReplicatedStorage")

--> Component Framework Dependencies
local Rcade = require(rStore.Libs.Rcade)

local SETTINGS = {
	Tag = "SBottle",
}

--> Class Definition
local Super = require(script.Parent.Parent.AbstractComponents.BaseMelee)
local SBottle = Rcade.class({ __super = Super, Tag = SETTINGS.Tag })

--> Variables
local urev_OnEquip = rStore.Signals.Remote.Unreliable.OnEquipMelee

--> Constructor
function SBottle:__init(inst: Tool)
	self.__super.__init(self, inst)
	self["EquipDB"] = false
	self:__backendInit()
end

--> Backend Constructor
function SBottle:__backendInit(): ()
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
function SBottle:OnActivate(): ()
	if self.EquipDB == true then
		return
	end
	if self.Debounce then
		return
	end
	self.Debounce = true

	local hrp: BasePart = self.Instance.Parent:FindFirstChild("HumanoidRootPart")
	local hCFrame = hrp.CFrame

	self.Event:Fire(self.Data.BackendName, hCFrame)

	task.delay(self.Data.Cooldown, function()
		self.Debounce = false
	end)
end

function SBottle:OnEquip(): ()
	if not self.EquipDB then
		self.EquipDB = true

		urev_OnEquip:FireServer(self.Data.BackendName, self.Instance)
		task.delay(self.Instance.Cooldown.Value, function()
			self.EquipDB = false
		end)
	end
end

return SBottle
