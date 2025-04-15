local rStore = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local cooldownEvent = rStore.Signals.Client.CreateCooldownUI

local Component = require(rStore.Packages.Component)

local BaseTool = require(script.Parent.Parent.AbstractComponents.BaseTool)
local Super = require(script.Parent.Parent.AbstractComponents.BaseGun)
local OnlyLocalPlayer = require(script.Parent.Parent.AbstractComponents.OnlyLocalPlayer)
local Pistol = Component.new({
	Tag = "CoolStoryAirConditioner",
	Extensions = { OnlyLocalPlayer, Super, BaseTool },
	Ancestors = { workspace, game.Players },
})

local Player = Players.LocalPlayer
local Mouse = Player:GetMouse()

function Pistol:Construct()
	self.debounce = false
	self.Animation = Instance.new("Animation")
	self.Animator = nil
end

function Pistol:OnEquip()
	local humanoid = Player.Character and Player.Character:FindFirstChild("Humanoid")
	if humanoid then
		self.Animator = humanoid:FindFirstChildOfClass("Animator") or humanoid:FindFirstChild("Animator")
		if not self.Animator then
			self.Animator = Instance.new("Animator")
			self.Animator.Parent = humanoid
		end
	end
end

function Pistol:OnActivate()
	if not self.debounce then
		self.debounce = true

		local hPos = self.Instance.Handle.Position
		local mHit = Mouse.Hit.Position
		local dir = (mHit - hPos).Unit

		self.Event:Fire("CoolStoryAirConditioner", hPos, dir)

		if self.Animator then
			self.Animation.AnimationId = "rbxassetid://233535408"
			local track = self.Animator:LoadAnimation(self.Animation)
			track:Play()
		end

		cooldownEvent:Fire("CoolStoryAirConditioner", 7, Color3.fromRGB(25, 200, 25))
		task.wait(8.5)
		self.debounce = false
	end
end

return Pistol
