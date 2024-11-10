--> Services
local rStore = game:GetService("ReplicatedStorage")

--> Component Framework Dependencies
local Component = require(rStore.Packages.Component)

--> Class Definition
local Super = require(script.Parent.Parent.AbstractComponents.BaseMelee)
local OnlyLocalPlayer = require(script.Parent.Parent.AbstractComponents.OnlyLocalPlayer)
local Pitchfork = Component.new({
	Tag = "Pitchfork",
	Extensions = { OnlyLocalPlayer, Super },
	Ancestors = { workspace, game.Players },
})

--> Variables
local urev_OnEquip = rStore.Signals.Remote.Unreliable.OnEquipMelee

--> Cosnstructor
function Pitchfork:Cosnstruct()
	self.Debounce = false
	self.EquipDB = false
	self.Phase = 0
end

--> Module Functions
function Pitchfork:OnActivate(): ()
	if self.EquipDB == true then
		return
	end
	if self.Debounce then
		return
	end
	self.Debounce = true

	local hrp: BasePart = self.Instance.Parent:FindFirstChild("HumanoidRootPart")
	local hCFrame = hrp.CFrame

	self.Phase += 1

	if self.Phase > 2 then
		hrp:ApplyImpulse(hrp.CFrame:VectorToWorldSpace(-Vector3.zAxis * 3500))

		self.Event:Fire(self.Data.BackendName, hCFrame, "Dash", "Dash")

		self.Phase = 0
	else
		self.Event:Fire(self.Data.BackendName, hCFrame, "Jab", "Jab")
	end

	task.delay(self.Data.Cooldown, function()
		self.Debounce = false
	end)
end

function Pitchfork:OnEquip(): ()
	if not self.EquipDB then
		self.EquipDB = true

		urev_OnEquip:FireServer(self.Data.BackendName, self.Instance)
		task.delay(0.4, function()
			self.EquipDB = false
		end)
	end
end

return Pitchfork
