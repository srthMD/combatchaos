local rStore = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Component = require(rStore.Packages.Component)

local BaseTool = require(script.Parent.Parent.AbstractComponents.BaseTool)
local Super = require(script.Parent.Parent.AbstractComponents.BaseGun)
local OnlyLocalPlayer = require(script.Parent.Parent.AbstractComponents.OnlyLocalPlayer)
local Greenery = Component.new({
	Tag = "Greenery",
	Extensions = { OnlyLocalPlayer, Super, BaseTool },
	Ancestors = { workspace, game.Players },
})

local equipSound = rStore.Assets.ItemDeps.Greenery.EquipSound

local Player = Players.LocalPlayer
local Mouse = Player:GetMouse()

local rand = Random.new(os.time())

function Greenery:Construct()
	self.debounce = false
	self.Animation = Instance.new("Animation")
	self.Animator = nil
end

function Greenery:OnEquip()
	local clone = equipSound:Clone()
	clone.Parent = self.Instance
	clone:Play()

	self.Animation.AnimationId = "rbxassetid://00" -- Set the animation ID
	local humanoid = Player.Character and Player.Character:FindFirstChild("Humanoid")
	if humanoid then
		self.Animator = humanoid:LoadAnimation(self.Animation)
	else
		warn("Humanoid not found in character.")
	end
end

function Greenery:OnActivate()
	if not self.debounce then
		self.debounce = true

		local hPos = self.Instance.Handle.Position
		local mHit = Mouse.Hit.Position
		local dir = (mHit - hPos).Unit

		for i = 0, 3, 1 do
			local spread = dir + rand:NextUnitVector() * 0.03

			if i == 0 then
				self.Event:Fire("Greenery", hPos, spread, true)
			else
				self.Event:Fire("Greenery", hPos, spread)
			end
		end

		-- Play the animation
		if self.Animator then
			self.Animator:Play()
		end

		task.wait(0.7)
		self.debounce = false
	end
end

return Greenery
