--> Services
local rStore = game:GetService("ReplicatedStorage")

--> Component Framework Dependencies
local Component = require(rStore.Packages.Component)

--> Class Definition
local Super = require(script.Parent.Parent.AbstractComponents.BaseMelee)
local OnlyLocalPlayer = require(script.Parent.Parent.AbstractComponents.OnlyLocalPlayer)
local GenericAnimatable = Component.new({
	Tag = "GenericAnimatableMelee",
	Extensions = { OnlyLocalPlayer, Super },
	Ancestors = { workspace, game.Players },
})

--> Variables
local urev_OnEquip = rStore.Signals.Remote.Unreliable.OnEquipMelee

--> Constructor
function GenericAnimatable:Construct()
	self.Debounce = false
	self.EquipDB = false
end

--> Module Functions
function GenericAnimatable:OnActivate()
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
