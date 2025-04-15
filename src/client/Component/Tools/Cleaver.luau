local rStore = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Component = require(rStore.Packages.Component)

local BaseTool = require(script.Parent.Parent.AbstractComponents.BaseTool)
local Super = require(script.Parent.Parent.AbstractComponents.BaseGun)
local OnlyLocalPlayer = require(script.Parent.Parent.AbstractComponents.OnlyLocalPlayer)
local Cleaver = Component.new({
	Tag = "Cleaver",
	Extensions = { OnlyLocalPlayer, Super, BaseTool },
	Ancestors = { workspace, game.Players },
})

local equipSound = rStore.Assets.ItemDeps.Cleaver.EquipSound

local Player = Players.LocalPlayer
local Mouse = Player:GetMouse()

function Cleaver:Construct()
	self.debounce = false
end

function Cleaver:OnEquip()
	local clone = equipSound:Clone()
	clone.Parent = self.Instance
	clone:Play()
end

function Cleaver:OnActivate()
	if not self.debounce then
		self.debounce = true

		local hPos = self.Instance.Handle.Position
		local mHit = Mouse.Hit.Position
		local dir = (mHit - hPos).Unit

		self.Event:Fire("Cleaver", hPos, dir)

		task.wait(1.25)
		self.debounce = false
	end
end

return Cleaver
