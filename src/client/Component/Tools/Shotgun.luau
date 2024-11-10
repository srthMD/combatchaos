local rStore = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Component = require(rStore.Packages.Component)

local Super = require(script.Parent.Parent.AbstractComponents.BaseGun)
local OnlyLocalPlayer = require(script.Parent.Parent.AbstractComponents.OnlyLocalPlayer)
local Shotgun = Component.new({
	Tag = "Shotgun",
	Extensions = { OnlyLocalPlayer, Super },
	Ancestors = { workspace, game.Players },
})

local equipSound = rStore.Assets.ItemDeps.Pistol.EquipSound

local Player = Players.LocalPlayer
local Mouse = Player:GetMouse()

local rand = Random.new(os.time())

function Shotgun:Construct()
	self.debounce = false
	self.Animation = Instance.new("Animation")
	self.Animator = nil
end

function Shotgun:OnEquip()
	local clone = equipSound:Clone()
	clone.Parent = self.Instance
	clone:Play()

	self.animation.AnimationId = "rbxassetid://17537676504" -- Set the animation ID
	local humanoid = Player.Character and Player.Character:FindFirstChild("Humanoid")
	if humanoid then
		self.animator = humanoid:LoadAnimation(self.animation)
	else
		warn("Humanoid not found in character.")
	end
end

function Shotgun:OnActivate()
	if not self.debounce then
		self.debounce = true

		local hPos = self.Instance.Handle.Position
		local mHit = Mouse.Hit.Position
		local dir = (mHit - hPos).Unit

		for i = 0, 7, 1 do
			local spread = dir + rand:NextUnitVector() * 0.04

			if i == 0 then
				self.Event:Fire("Shotgun", hPos, spread, true)
			else
				self.Event:Fire("Shotgun", hPos, spread)
			end
		end

		-- Play the animation
		if self.animator then
			self.animator:Play()
		end

		task.wait(0.25)
		self.debounce = false
	end
end

return Shotgun
