local rStore = game:GetService("ReplicatedStorage")

local Component = require(rStore.Packages.Component)

local BaseTool = require(script.Parent.Parent.AbstractComponents.BaseTool)
local Super = require(script.Parent.Parent.AbstractComponents.BaseMelee)
local OnlyLocalPlayer = require(script.Parent.Parent.AbstractComponents.OnlyLocalPlayer)
local Parasol = Component.new({
	Tag = "ParasolMelee",
	Extensions = { OnlyLocalPlayer, Super, BaseTool },
	Ancestors = { workspace, game.Players },
})

local urev_OnEquip = rStore.Signals.Remote.Unreliable.OnEquipMelee

function Parasol:Cosnstruct()
	self.Debounce = false
	self.EquipDB = false
	self.Phase = 0
end

function Parasol:OnActivate(): ()
	if self.EquipDB == true then
		return
	end

	if self.Debounce == true then
		return
	end

	self.Debounce = true

	local hrp: BasePart = self.Instance.Parent:FindFirstChild("HumanoidRootPart")
	local hCFrame = hrp.CFrame

	if self.Phase == nil then
		self.Phase = 0
	end

	self.Phase += 1

	if self.Phase > 4 then
		hrp:ApplyImpulse(hrp.CFrame:VectorToWorldSpace(-Vector3.zAxis * 3700))

		self.Event:Fire(self.Data.BackendName, hCFrame, "Dash", "Dash")

		self.Phase = 0
	else
		self.Event:Fire(self.Data.BackendName, hCFrame, "Jab", "Jab")
	end

	task.delay(self.Data.Cooldown, function()
		self.Debounce = false
	end)
end

function Parasol:OnEquip(): ()
	if not self.EquipDB then
		self.EquipDB = true

		urev_OnEquip:FireServer(self.Data.BackendName, self.Instance)
		task.delay(0.4, function()
			self.EquipDB = false
		end)
	end
end

return Parasol
