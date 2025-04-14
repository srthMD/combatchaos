--> Services
local rStore = game:GetService("ReplicatedStorage")

--> Component Framework Dependencies
local Component = require(rStore.Packages.Component)

--> Class Definition
local Super = require(script.Parent.Parent.AbstractComponents.BaseMelee)
local OnlyLocalPlayer = require(script.Parent.Parent.AbstractComponents.OnlyLocalPlayer)
local SBottle =
	Component.new({ Tag = "SBottle", Extensions = { OnlyLocalPlayer, Super }, Ancestors = { workspace, game.Players } })

--> Variables
local urev_OnEquip = rStore.Signals.Remote.Unreliable.OnEquipMelee
local cooldownEvent = rStore.Signals.Client.CreateCooldownUI

--> Constructor
function SBottle:Construct()
	self.EquipDB = false
	self.Debounce = false
end

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

function SBottle:OnEquip()
	if not self.EquipDB then
		self.EquipDB = true

		urev_OnEquip:FireServer(self.Data.BackendName, self.Instance)
		task.delay(self.Instance.Cooldown.Value, function()
			self.EquipDB = false
		end)
	end
end

return SBottle
