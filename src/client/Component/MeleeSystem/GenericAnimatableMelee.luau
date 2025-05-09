local rStore = game:GetService("ReplicatedStorage")

local Component = require(rStore.Packages.Component)

local BaseTool = require(script.Parent.Parent.AbstractComponents.BaseTool)
local Super = require(script.Parent.Parent.AbstractComponents.BaseMelee)
local OnlyLocalPlayer = require(script.Parent.Parent.AbstractComponents.OnlyLocalPlayer)
local GenericAnimatable = Component.new({
	Tag = "GenericAnimatableMelee",
	Extensions = { OnlyLocalPlayer, Super, BaseTool },
	Ancestors = { workspace, game.Players },
})

local urev_OnEquip = rStore.Signals.Remote.Unreliable.OnEquipMelee

function GenericAnimatable:Construct()
	self.Debounce = false
	self.EquipDB = false
end

function GenericAnimatable:OnActivate()
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
