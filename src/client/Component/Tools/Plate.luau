local rStore = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Component = require(rStore.Packages.Component)

local BaseTool = require(script.Parent.Parent.AbstractComponents.BaseTool)
local Super = require(script.Parent.Parent.AbstractComponents.BaseGun)
local OnlyLocalPlayer = require(script.Parent.Parent.AbstractComponents.OnlyLocalPlayer)
local Plate = Component.new({
	Tag = "Plate",
	Extensions = { OnlyLocalPlayer, Super, BaseTool },
	Ancestors = { workspace, game.Players },
})

local CreateProjectileEvent = rStore.Signals.Client.CreateProjectile
local Player = Players.LocalPlayer
local Mouse = Player:GetMouse()

function Plate:Construct()
	self.debounce = false
end

function Plate:OnActivate()
	if not self.debounce then
		self.debounce = true

		local tool: BasePart = self.Instance:FindFirstChild("Handle")

		local hPos = self.Instance.Handle.Position
		local mHit = Mouse.Hit.Position
		local dir = (mHit - hPos).Unit

		CreateProjectileEvent:Fire("Plate", hPos, dir)
		tool.Transparency = 1

		task.wait(2.25)
		self.debounce = false
		tool.Transparency = 0
	end
end

return Plate
