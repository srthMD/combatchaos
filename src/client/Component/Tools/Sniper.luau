local rStore = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local cooldownEvent = rStore.Signals.Client.CreateCooldownUI

local Component = require(rStore.Packages.Component)

local BaseTool = require(script.Parent.Parent.AbstractComponents.BaseTool)
local Super = require(script.Parent.Parent.AbstractComponents.BaseGun)
local OnlyLocalPlayer = require(script.Parent.Parent.AbstractComponents.OnlyLocalPlayer)
local Sniper = Component.new({
	Tag = "Sniper",
	Extensions = { OnlyLocalPlayer, Super, BaseTool },
	Ancestors = { workspace, game.Players },
})

local equipSound = rStore.Assets.ItemDeps.Sniper.EquipSound

local Player = Players.LocalPlayer
local Mouse = Player:GetMouse()

function Sniper:Construct()
	self.debounce = false

	-- shooting animation
	self.ShootAnimation = Instance.new("Animation")
	self.ShootAnimator = nil

	-- equip animation
	self.EquipAnimation = Instance.new("Animation")
	self.EquipTrack = nil
end

function Sniper:OnEquip()
	local clone = equipSound:Clone()
	clone.Parent = self.Instance
	clone:Play()

	local humanoid = Player.Character and Player.Character:FindFirstChild("Humanoid")
	if humanoid then
		-- setup shoot anim
		self.ShootAnimation.AnimationId = "rbxassetid://94943934894680"
		self.ShootAnimator = humanoid:LoadAnimation(self.ShootAnimation)
		self.ShootAnimator.Looped = false

		-- setup equip anim
		self.EquipAnimation.AnimationId = "rbxassetid://77183496146678"
		self.EquipTrack = humanoid:LoadAnimation(self.EquipAnimation)
		self.EquipTrack.Looped = false
		self.EquipTrack:Play()
	else
		warn("Humanoid not found in character.")
	end
end

function Sniper:OnUnequip()
	if self.EquipTrack then
		self.EquipTrack:Stop()
		self.EquipTrack:Destroy()
		self.EquipTrack = nil
	end

	if self.ShootAnimator then
		self.ShootAnimator:Stop()
		self.ShootAnimator:Destroy()
		self.ShootAnimator = nil
	end
end

function Sniper:OnActivate()
	if not self.debounce then
		self.debounce = true

		local hPos = self.Instance.Handle.Position
		local mHit = Mouse.Hit.Position
		local dir = (mHit - hPos).Unit

		self.Event:Fire("Sniper", hPos, dir)

		-- play shooting animation
		if self.ShootAnimator then
			self.ShootAnimator:Play()
		end

		cooldownEvent:Fire("Sniper", 4.3, Color3.fromRGB(25, 200, 25))
		task.wait(4.3)
		self.debounce = false
	end
end

return Sniper
