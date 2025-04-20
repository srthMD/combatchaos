local rStore = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Debris = game:GetService("Debris")

local Component = require(rStore.Packages.Component)
local BaseTool = require(script.Parent.Parent.AbstractComponents.BaseTool)
local Super = require(script.Parent.Parent.AbstractComponents.BaseGun)
local OnlyLocalPlayer = require(script.Parent.Parent.AbstractComponents.OnlyLocalPlayer)

local OldSchool = Component.new({
	Tag = "OldSchool Pistol",
	Extensions = { OnlyLocalPlayer, Super, BaseTool },
	Ancestors = { workspace, game.Players },
})

local equipSound = rStore.Assets.ItemDeps["OldSchool Pistol"].EquipSound
local reloadSound = rStore.Assets.ItemDeps["OldSchool Pistol"].ReloadSound
local fireSound = rStore.Assets.ItemDeps["OldSchool Pistol"].Fire

local Player = Players.LocalPlayer
local Mouse = Player:GetMouse()

function OldSchool:Construct()
	self.debounce = false
	self.Animation = Instance.new("Animation")
	self.Animator = nil
	self.shotCount = 0
	self.isReloading = false
end

function OldSchool:OnEquip()
	local clone = equipSound:Clone()
	clone.Parent = self.Instance
	clone:Play()
	Debris:AddItem(clone, clone.TimeLength)

	self.Animation.AnimationId = "rbxassetid://17537676504"
	local humanoid = Player.Character and Player.Character:FindFirstChild("Humanoid")
	if humanoid then
		self.Animator = humanoid:LoadAnimation(self.Animation)
	else
		warn("Humanoid not found in character.")
	end
end

function OldSchool:Reload()
	self.isReloading = true
	self.debounce = true

	if reloadSound then
		local reloadClone = reloadSound:Clone()
		reloadClone.Parent = self.Instance
		reloadClone:Play()
		Debris:AddItem(reloadClone, reloadClone.TimeLength)
	end

	task.wait(2)

	self.shotCount = 0
	self.isReloading = false
	self.debounce = false
end

function OldSchool:OnActivate()
	if not self.debounce and not self.isReloading then
		self.debounce = true
		self.shotCount += 1

		local hPos = self.Instance.Handle.Position
		local mHit = Mouse.Hit.Position
		local dir = (mHit - hPos).Unit

		self.Event:Fire("OldSchoolBullet", hPos, dir)

		-- 🔊 Play fire sound
		if fireSound then
			local fireClone = fireSound:Clone()
			fireClone.Parent = self.Instance.Handle
			fireClone:Play()
			Debris:AddItem(fireClone, 5)
		end

		-- 🎞️ Play fire animation
		if self.Animator then
			self.Animator:Play()
		end

		if self.shotCount >= 16 then
			reloadSound.Parent = self.Instance.Handle
			self:Reload()
		else
			task.wait(0.2)
			self.debounce = false
		end
	end
end

return OldSchool
