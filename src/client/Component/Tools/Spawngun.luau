local rStore = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Component = require(rStore.Packages.Component)
local Super = require(script.Parent.Parent.AbstractComponents.BaseGun)
local OnlyLocalPlayer = require(script.Parent.Parent.AbstractComponents.OnlyLocalPlayer)
local Spawngun =
	Component.new({ Tag = "Spawngun", Extensions = { OnlyLocalPlayer, Super }, Ancestors = { workspace, game.Players } })

local equipSound = rStore.Assets.ItemDeps.Spawngun.EquipSound

local Player = Players.LocalPlayer
local Mouse = Player:GetMouse()

function Spawngun:Construct()
	self.debounce = false
	self.Animation = Instance.new("Animation")
	self.Animator = nil
end

function Spawngun:OnEquip()
	local clone = equipSound:Clone()
	clone.Parent = self.Instance
	clone:Play()

	self.Animation.AnimationId = "rbxassetid://119324743861996" -- Set the animation ID
	local humanoid = Player.Character and Player.Character:FindFirstChild("Humanoid")
	if humanoid then
		self.Animator = humanoid:LoadAnimation(self.Animation)
	else
		warn("Humanoid not found in character.")
	end
end

function Spawngun:OnActivate()
	if not self.debounce then
		self.debounce = true

		local hPos = self.Instance.Handle.Position
		local mHit = Mouse.Hit.Position
		local dir = (mHit - hPos).Unit

		self.Event:Fire("Spawngun", hPos, dir)

		-- Play the animation
		if self.Animator then
			self.Animator:Play()
		end

		task.wait(1.35)
		self.debounce = false
	end
end

return Spawngun
