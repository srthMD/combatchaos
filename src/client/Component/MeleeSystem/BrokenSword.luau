--> Services
local rStore = game:GetService("ReplicatedStorage")

--> Component Framework Dependencies
local Component = require(rStore.Packages.Component)

--> Class Definition
local Super = require(script.Parent.Parent.AbstractComponents.BaseMelee)
local OnlyLocalPlayer = require(script.Parent.Parent.AbstractComponents.OnlyLocalPlayer)
local BrokenSword = Component.new({
	Tag = "BrokenSword",
	Extensions = { OnlyLocalPlayer, Super },
	Ancestors = { workspace, game.Players },
})

--> Variables
local urev_OnEquip = rStore.Signals.Remote.Unreliable.OnEquipMelee
local LUNGE_IMPULSE = Vector3.new(0, 0.6, -0.6) * 1000

--> Constructor
function BrokenSword:Construct()
	self.EquipDB = false
	self.Debounce = false
	self.lastAttackTime = 0
end

--> Private Functions
local function Lunge(hrp: BasePart)
	local pos = hrp.CFrame
	local translatedVelocity = pos:VectorToWorldSpace(LUNGE_IMPULSE)

	hrp:ApplyImpulse(translatedVelocity)
end

--> Module Functions
function BrokenSword:OnActivate()
	if self.EquipDB == true then
		return
	end
	if self.Debounce == true then
		return
	end
	self.Debounce = true

	local hrp: BasePart = self.Instance.Parent:FindFirstChild("HumanoidRootPart")
	local hCFrame = hrp.CFrame

	local curTime = os.clock()

	if (curTime - self.lastAttackTime) <= 0.55 then
		Lunge(hrp)
		self.Event:Fire(self.Data.BackendName, hCFrame, "Lunge", "Lunge")
		task.delay(self.Data.Cooldown + 0.5, function()
			self.Debounce = false
		end)
	else
		self.Event:Fire(self.Data.BackendName, hCFrame, "Attack", "Attack")
		task.delay(self.Data.Cooldown, function()
			self.Debounce = false
		end)
	end

	self.lastAttackTime = os.clock()
end

function BrokenSword:OnEquip(): ()
	if not self.EquipDB then
		self.EquipDB = true

		urev_OnEquip:FireServer(self.Data.BackendName, self.Instance)

		task.delay(0.2, function()
			self.EquipDB = false
		end)
	end
end

return BrokenSword
