local rStore = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local cooldownEvent = rStore.Signals.Client.CreateCooldownUI

local Component = require(rStore.Packages.Component)

local BaseTool = require(script.Parent.Parent.AbstractComponents.BaseTool)
local Super = require(script.Parent.Parent.AbstractComponents.BaseGun)
local OnlyLocalPlayer = require(script.Parent.Parent.AbstractComponents.OnlyLocalPlayer)
local Blackhole = Component.new({
	Tag = "Blackhole",
	Extensions = { OnlyLocalPlayer, Super, BaseTool },
	Ancestors = { workspace, game.Players },
})

local equipSound = rStore.Assets.ItemDeps.Blackhole.EquipSound

local Player = Players.LocalPlayer
local Mouse = Player:GetMouse()

local rand = Random.new(os.time())

function Blackhole:Construct()
	self.debounce = false
	self.Animation = Instance.new("Animation")
	self.Animator = nil
end

function Blackhole:OnEquip()
	local clone = equipSound:Clone()
	clone.Parent = self.Instance
	clone:Play()

	self.Animation.AnimationId = "rbxassetid://128130366944938" -- Set the animation ID
	local humanoid = Player.Character and Player.Character:FindFirstChild("Humanoid")
	if humanoid then
		self.Animator = humanoid:LoadAnimation(self.Animation)
	else
		warn("Humanoid not found in character.")
	end
end

function Blackhole:OnActivate()
	if not self.debounce then
		self.debounce = true

		local hPos = self.Instance.Handle.Position
		local mHit = Mouse.Hit.Position
		local dir = (mHit - hPos).Unit

		for i = 0, 2, 1 do
			local spread = dir + rand:NextUnitVector() * 0.022

			if i == 0 then
				self.Event:Fire("Blackhole", hPos, spread, true)
			else
				self.Event:Fire("Blackhole", hPos, spread)
			end
		end

		-- Play the animation
		if self.Animator then
			self.Animator:Play()
		end

		cooldownEvent:Fire("Blackhole Gun", 4.5, Color3.fromRGB(25, 200, 25))
		task.wait(4.5)
		self.debounce = false
	end
end

return Blackhole
