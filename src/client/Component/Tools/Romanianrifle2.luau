local rStore = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local cooldownEvent = rStore.Signals.Client.CreateCooldownUI

local Component = require(rStore.Packages.Component)
local Super = require(script.Parent.Parent.AbstractComponents.BaseGun)
local OnlyLocalPlayer = require(script.Parent.Parent.AbstractComponents.OnlyLocalPlayer)
local Romanianrifle2 =
	Component.new({ Tag = "Romanianrifle2", Extensions = { OnlyLocalPlayer, Super }, Ancestors = { workspace, game.Players } })

local equipSound = rStore.Assets.ItemDeps.Romanianrifle.EquipSound

local Player = Players.LocalPlayer
local Mouse = Player:GetMouse()

function Romanianrifle2:Construct()
	self.debounce = false
	self.Animation = Instance.new("Animation")
	self.Animator = nil
end

function Romanianrifle2:OnEquip()
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

function Romanianrifle2:OnActivate()
	if not self.debounce then
		self.debounce = true

		local hPos = self.Instance.Handle.Position
		local mHit = Mouse.Hit.Position
		local dir = (mHit - hPos).Unit

		self.Event:Fire("Romanianrifle2", hPos, dir)

		-- Play the animation
		if self.Animator then
			self.Animator:Play()
		end
		
		cooldownEvent:Fire("grenbullet", 20, Color3.fromRGB(25, 200, 25))
		task.wait(20)
		self.debounce = false
	end
end

return Romanianrifle2
