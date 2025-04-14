local rStore = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local Component = require(rStore.Packages.Component)
local Super = require(script.Parent.Parent.AbstractComponents.BaseGun)
local OnlyLocalPlayer = require(script.Parent.Parent.AbstractComponents.OnlyLocalPlayer)
local Romanianrifle = Component.new({
	Tag = "Romanianrifle",
	Extensions = { OnlyLocalPlayer, Super },
	Ancestors = { workspace, game.Players },
})

local cooldownEvent = rStore.Signals.Client.CreateCooldownUI
local equipSound = rStore.Assets.ItemDeps.Romanianrifle.EquipSound

local abilityFrame = rStore.Assets.StaticInterface.Ability

local Player = Players.LocalPlayer
local Mouse = Player:GetMouse()

function Romanianrifle:Construct()
	self.debounce = false
	self.Animation = Instance.new("Animation")
	self.Animator = nil
	self.GrenadeDebounce = false

	local con = UserInputService.InputBegan:Connect(function(io: InputObject, reg: boolean)
		if reg then
			return
		end

		local key = io.KeyCode

		if key.Value == Enum.KeyCode.E.Value then
			if self.GrenadeDebounce then
				return
			end

			local char = game.Players.LocalPlayer.Character

			if not char then
				return
			end

			if not self.Instance:IsDescendantOf(char) then
				return
			end

			self.GrenadeDebounce = true

			local hPos = self.Instance.Handle.Position
			local mHit = Mouse.Hit.Position
			local dir = (mHit - hPos).Unit

			self.Event:Fire("Romanianrifle2", hPos, dir)

			-- Play the animation
			if self.Animator then
				self.Animator:Play()
			end

			cooldownEvent:Fire("Grenade", 20, Color3.fromRGB(25, 200, 25))
			task.wait(20)
			self.GrenadeDebounce = false
		end
	end)
end

function Romanianrifle:OnEquip()
	local abilitiesUI = Players.LocalPlayer.PlayerGui.CC_Core:FindFirstChild("Abilities")
	if abilitiesUI then
		local ability = abilityFrame:Clone()
		ability.Parent = abilitiesUI
		ability.Name = "RomanianRifleAbility"
		ability.Info.Description.Text = "Fire Grenade"
		ability.Key.Text = "E"
	end

	local clone = equipSound:Clone()
	clone.Parent = self.Instance
	clone:Play()

	self.Animation.AnimationId = "rbxassetid://114182370586959" -- Set the animation ID
	local humanoid = Player.Character and Player.Character:FindFirstChild("Humanoid")
	if humanoid then
		self.Animator = humanoid:LoadAnimation(self.Animation)
	else
		warn("Humanoid not found in character.")
	end
end

function Romanianrifle:OnUnequip()
	local abilitiesUI = Players.LocalPlayer.PlayerGui.CC_Core:FindFirstChild("Abilities")
	if abilitiesUI then
		local ability = abilitiesUI:FindFirstChild("RomanianRifleAbility")
		if ability then
			ability:Destroy()
		end
	end
end

function Romanianrifle:OnActivate()
	if not self.debounce then
		self.debounce = true

		local hPos = self.Instance.Handle.Position
		local mHit = Mouse.Hit.Position
		local dir = (mHit - hPos).Unit

		self.Event:Fire("Romanianrifle", hPos, dir)

		-- Play the animation
		if self.Animator then
			self.Animator:Play()
		end

		task.wait(0.14)
		self.debounce = false
	end
end

return Romanianrifle
