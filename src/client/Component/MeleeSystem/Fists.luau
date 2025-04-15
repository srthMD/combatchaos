local rStore = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

--> Component Framework Dependencies
local Component = require(rStore.Packages.Component)

--> Class Definition
local BaseTool = require(script.Parent.Parent.AbstractComponents.BaseTool)
local Super = require(script.Parent.Parent.AbstractComponents.BaseMelee)
local OnlyLocalPlayer = require(script.Parent.Parent.AbstractComponents.OnlyLocalPlayer)
local GenericAnimatable = Component.new({
	Tag = "Fists",
	Extensions = { OnlyLocalPlayer, Super, BaseTool },
	Ancestors = { workspace, game.Players },
})

--> Variables
local urev_OnEquip = rStore.Signals.Remote.Unreliable.OnEquipMelee

local Player = Players.LocalPlayer

--> Constructor
function GenericAnimatable:Construct()
	self.Debounce = false
	self.EquipDB = false
	self.EquipAnimation = Instance.new("Animation")
	self.EquipTrack = nil
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

	task.delay(self.Data.Cooldown, function()
		self.Debounce = false
	end)
end
-- im gonna lose it all i just want the attack animations to not play the animation weirdly this poop dont worj
function GenericAnimatable:OnEquip()
	if not self.EquipDB then
		self.EquipDB = true

		urev_OnEquip:FireServer(self.Data.BackendName, self.Instance)
		-- Equip animation
		local humanoid = Player.Character and Player.Character:FindFirstChild("Humanoid")
		if humanoid then
			self.EquipAnimation.AnimationId = "rbxassetid://130924096940191"

			-- Make sure the animation doesn't get overridden
			if not self.EquipTrack then
				self.EquipTrack = humanoid:LoadAnimation(self.EquipAnimation)
				self.EquipTrack.Looped = true -- Keep it looped so it doesn't stop
				--	self.EquipTrack.Priority = Enum.AnimationPriority.Action  -- Higher priority to prevent interruptions
				self.EquipTrack:Play()
			end
		else
			warn("Humanoid not found in character.")
		end

		task.delay(0.15, function()
			self.EquipDB = false
		end)
	end
end

function GenericAnimatable:OnUnequip()
	if self.EquipTrack then
		self.EquipTrack:Stop()
		self.EquipTrack:Destroy()
		self.EquipTrack = nil
	end
end

return GenericAnimatable
