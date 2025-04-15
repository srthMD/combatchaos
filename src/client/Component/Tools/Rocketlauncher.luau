local rStore = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local cooldownEvent = rStore.Signals.Client.CreateCooldownUI

local Component = require(rStore.Packages.Component)

local BaseTool = require(script.Parent.Parent.AbstractComponents.BaseTool)
local Super = require(script.Parent.Parent.AbstractComponents.BaseGun)
local OnlyLocalPlayer = require(script.Parent.Parent.AbstractComponents.OnlyLocalPlayer)
local Rocketlauncher = Component.new({
	Tag = "Rocketlauncher",
	Extensions = { OnlyLocalPlayer, Super, BaseTool },
	Ancestors = { workspace, game.Players },
})

local equipSound = rStore.Assets.ItemDeps.Rocketlauncher.EquipSound

local Player = Players.LocalPlayer
local Mouse = Player:GetMouse()

function Rocketlauncher:Construct()
	self.debounce = false
	self.Animation = Instance.new("Animation")
	self.Animator = nil
end

function Rocketlauncher:OnEquip()
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

function Rocketlauncher:OnActivate()
	if not self.debounce then
		self.debounce = true

		local hPos = self.Instance.Handle.Position
		local mHit = Mouse.Hit.Position
		local dir = (mHit - hPos).Unit

		self.Event:Fire("Rocketlauncher", hPos, dir)

		-- Play the animation
		if self.Animator then
			self.Animator:Play()
		end

		cooldownEvent:Fire("Rocket launcher", 9, Color3.fromRGB(25, 200, 25))
		task.wait(9)
		self.debounce = false
	end
end

return Rocketlauncher
