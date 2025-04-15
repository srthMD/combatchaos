local rStore = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Component = require(rStore.Packages.Component)

local BaseTool = require(script.Parent.Parent.AbstractComponents.BaseTool)
local Super = require(script.Parent.Parent.AbstractComponents.BaseGun)
local OnlyLocalPlayer = require(script.Parent.Parent.AbstractComponents.OnlyLocalPlayer)
local Pistol = Component.new({
	Tag = "Pistol",
	Extensions = { OnlyLocalPlayer, Super, BaseTool },
	Ancestors = { workspace, game.Players },
})

local equipSound = rStore.Assets.ItemDeps.Pistol.EquipSound

local Player = Players.LocalPlayer
local Mouse = Player:GetMouse()

function Pistol:Construct()
	self.debounce = false

	-- shooting animation
	self.ShootAnimation = Instance.new("Animation")
	self.ShootAnimator = nil

	-- equip animation
	self.EquipAnimation = Instance.new("Animation")
	self.EquipTrack = nil
end

function Pistol:OnEquip()
	local clone = equipSound:Clone()
	clone.Parent = self.Instance
	clone:Play()

	local humanoid = Player.Character and Player.Character:FindFirstChild("Humanoid")
	if humanoid then
		-- set up shooting animation
		self.ShootAnimation.AnimationId = "rbxassetid://17537676504"
		self.ShootAnimator = humanoid:LoadAnimation(self.ShootAnimation)
		self.ShootAnimator.Looped = false

		-- set up equip animation
		self.EquipAnimation.AnimationId = "rbxassetid://16582768744"
		self.EquipTrack = humanoid:LoadAnimation(self.EquipAnimation)
		self.EquipTrack.Looped = false
		self.EquipTrack:Play()
	else
		warn("Humanoid not found in character.")
	end
end

function Pistol:OnUnequip()
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

function Pistol:OnActivate()
	if not self.debounce then
		self.debounce = true

		local hPos = self.Instance.Handle.Position
		local mHit = Mouse.Hit.Position
		local dir = (mHit - hPos).Unit

		self.Event:Fire("Pistol", hPos, dir)

		-- play shooting animation
		if self.ShootAnimator then
			self.ShootAnimator:Play()
		end

		task.wait(0.25)
		self.debounce = false
	end
end

return Pistol
