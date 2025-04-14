local rStore = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local cooldownEvent = rStore.Signals.Client.CreateCooldownUI

local Component = require(rStore.Packages.Component)
local Super = require(script.Parent.Parent.AbstractComponents.BaseGun)
local OnlyLocalPlayer = require(script.Parent.Parent.AbstractComponents.OnlyLocalPlayer)
local Pistol =
	Component.new({ Tag = "Carnagecopia", Extensions = { OnlyLocalPlayer, Super }, Ancestors = { workspace, game.Players } })

local Player = Players.LocalPlayer
local Mouse = Player:GetMouse()

function Pistol:Construct()
	self.debounce = false
end

function Pistol:OnActivate()
	if not self.debounce then
		self.debounce = true

		local hPos = self.Instance.Handle.Position
		local mHit = Mouse.Hit.Position
		local dir = (mHit - hPos).Unit

		self.Event:Fire("Carnagecopia", hPos, dir)

		cooldownEvent:Fire("Carnagecopia", 6, Color3.fromRGB(25, 200, 25))
		task.wait(6)
		self.debounce = false
	end
end

return Pistol
