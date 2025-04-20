local rStore = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Debris = game:GetService("Debris")
local UserInputService = game:GetService("UserInputService")

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
local abilityFrame = rStore.Assets.StaticInterface.Ability

local Player = Players.LocalPlayer
local Mouse = Player:GetMouse()

function OldSchool:Construct()
	self.debounce = false
	self.Animator = nil
	self.shotCount = 0
	self.isReloading = false
	self.equipAnim = Instance.new("Animation")
	self.reloadAnim = Instance.new("Animation")
	self.shootAnim = Instance.new("Animation")
	self.equipTrack = nil
	self.shootTrack = nil
	self.reloadTrack = nil

	UserInputService.InputBegan:Connect(function(input, gp)
		if gp then
			return
		end
		if input.KeyCode == Enum.KeyCode.R and not self.isReloading and self.shotCount > 0 then
			self:Reload()
		end
	end)
end

function OldSchool:OnEquip()
	local clone = equipSound:Clone()
	clone.Parent = self.Instance
	clone:Play()
	Debris:AddItem(clone, clone.TimeLength)

	self.equipAnim.AnimationId = "rbxassetid://136412763027768"
	self.reloadAnim.AnimationId = "rbxassetid://129589927537631"
	self.shootAnim.AnimationId = "rbxassetid://118203623074357"

	local humanoid = Player.Character and Player.Character:FindFirstChild("Humanoid")
	if humanoid then
		self.Animator = humanoid:FindFirstChildOfClass("Animator") or humanoid:FindFirstChild("Animate")
		if not self.Animator and humanoid:FindFirstChildOfClass("Animator") == nil then
			self.Animator = Instance.new("Animator")
			self.Animator.Parent = humanoid
		end

		-- Equip animation with Idle priority
		self.equipTrack = humanoid:LoadAnimation(self.equipAnim)
		self.equipTrack.Priority = Enum.AnimationPriority.Idle
		self.equipTrack.Looped = true
		self.equipTrack:Play()
	end

	-- Show ability UI
	local abilitiesUI = Players.LocalPlayer.PlayerGui:WaitForChild("CC_Core"):FindFirstChild("Abilities")
	if abilitiesUI then
		local ability = abilityFrame:Clone()
		ability.Parent = abilitiesUI
		ability.Name = "Reloading"
		ability.Info.Description.Text = "Reload"
		ability.Key.Text = "R"
	end
end

function OldSchool:OnUnequip()
	if self.equipTrack then
		self.equipTrack:Stop()
		self.equipTrack:Destroy()
		self.equipTrack = nil
	end

	local abilitiesUI = Players.LocalPlayer.PlayerGui:FindFirstChild("CC_Core"):FindFirstChild("Abilities")
	if abilitiesUI then
		local ability = abilitiesUI:FindFirstChild("Reloading")
		if ability then
			ability:Destroy()
		end
	end
end

function OldSchool:Reload()
	if self.shotCount <= 0 or self.isReloading then
		return
	end

	self.isReloading = true
	self.debounce = true

	if reloadSound then
		local reloadClone = reloadSound:Clone()
		reloadClone.Parent = self.Instance
		reloadClone:Play()
		Debris:AddItem(reloadClone, reloadClone.TimeLength)
	end

	if self.Animator and self.reloadAnim.AnimationId ~= "" then
		-- Reload animation with Action priority
		self.reloadTrack = self.Animator:LoadAnimation(self.reloadAnim)
		self.reloadTrack.Priority = Enum.AnimationPriority.Action
		self.reloadTrack:Play()
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

		-- 🎞️ Play shoot animation with Action priority
		if self.Animator and self.shootAnim.AnimationId ~= "" then
			self.shootTrack = self.Animator:LoadAnimation(self.shootAnim)
			self.shootTrack.Priority = Enum.AnimationPriority.Core
			self.shootTrack:Play()
		end

		if self.shotCount >= 16 then
			self:Reload()
		else
			task.wait(0.2)
			self.debounce = false
		end
	end
end

return OldSchool
