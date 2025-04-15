local rStore = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local cooldownEvent = rStore.Signals.Client.CreateCooldownUI

local Component = require(rStore.Packages.Component)

local BaseTool = require(script.Parent.Parent.AbstractComponents.BaseTool)
local Super = require(script.Parent.Parent.AbstractComponents.BaseGun)
local OnlyLocalPlayer = require(script.Parent.Parent.AbstractComponents.OnlyLocalPlayer)
local Shotgun = Component.new({
	Tag = "Shotgun",
	Extensions = { OnlyLocalPlayer, Super, BaseTool },
	Ancestors = { workspace, game.Players },
})

local equipSound = rStore.Assets.ItemDeps.Shotgun.EquipSound

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

	self.Animation.AnimationId = "rbxassetid://134762428057854" -- Set the animation ID
	local humanoid = Player.Character and Player.Character:FindFirstChild("Humanoid")
	if humanoid then
		self.Animator = humanoid:LoadAnimation(self.Animation)
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

		for i = 0, 9, 1 do
			local spread = dir + rand:NextUnitVector() * 0.057

			if i == 0 then
				self.Event:Fire("Shotgun", hPos, spread, true)
			else
				self.Event:Fire("Shotgun", hPos, spread)
			end
		end

		-- Play the animation
		if self.Animator then
			self.Animator:Play()
		end

		cooldownEvent:Fire("Shotgun", 3.18, Color3.fromRGB(25, 200, 25))
		task.wait(3.18)
		self.debounce = false
	end
end

return Shotgun
