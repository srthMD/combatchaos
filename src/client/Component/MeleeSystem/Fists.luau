local rStore = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Component = require(rStore.Packages.Component)

local BaseTool = require(script.Parent.Parent.AbstractComponents.BaseTool)
local Super = require(script.Parent.Parent.AbstractComponents.BaseMelee)
local OnlyLocalPlayer = require(script.Parent.Parent.AbstractComponents.OnlyLocalPlayer)

local GenericAnimatable = Component.new({
	Tag = "Fists",
	Extensions = { OnlyLocalPlayer, Super, BaseTool },
	Ancestors = { workspace, game.Players },
})

local urev_OnEquip = rStore.Signals.Remote.Unreliable.OnEquipMelee
local Player = Players.LocalPlayer
local abilityFrame = rStore.Assets.StaticInterface.Ability

function GenericAnimatable:Construct()
	self.Debounce = false
	self.EquipDB = false
	self.EquipAnimation = Instance.new("Animation")
	self.EquipTrack = nil
end

function GenericAnimatable:OnActivate()
	if self.Debounce then
		return
	end
	self.Debounce = true

	local hrp: BasePart = self.Instance.Parent:FindFirstChild("HumanoidRootPart")
	local hCFrame = hrp and hrp.CFrame

	self.Event:Fire(self.Data.BackendName, hCFrame)

	task.delay(self.Data.Cooldown, function()
		self.Debounce = false
	end)
end

function GenericAnimatable:OnEquip()
	if self.EquipDB then
		return
	end
	self.EquipDB = true

	local playerGui = Player:FindFirstChild("PlayerGui")
	local abilitiesUI = playerGui and playerGui:FindFirstChild("CC_Core"):FindFirstChild("Abilities")

	if abilitiesUI and abilityFrame then
		local ability = abilityFrame:Clone()
		ability.Parent = abilitiesUI
		ability.Name = "BlockAbility"
		ability.Info.Description.Text = "Block"
		ability.Key.Text = "E"
	end

	urev_OnEquip:FireServer(self.Data.BackendName, self.Instance)

	local humanoid = Player.Character and Player.Character:FindFirstChild("Humanoid")
	if humanoid then
		self.EquipAnimation.AnimationId = "rbxassetid://130924096940191"

		if not self.EquipTrack then
			self.EquipTrack = humanoid:LoadAnimation(self.EquipAnimation)
			self.EquipTrack.Looped = true
			self.EquipTrack:Play()
		end
	else
		warn("Humanoid not found in character.")
	end

	task.delay(0.15, function()
		self.EquipDB = false
	end)
end

function GenericAnimatable:OnUnequip()
	if self.EquipTrack then
		self.EquipTrack:Stop()
		self.EquipTrack:Destroy()
		self.EquipTrack = nil
	end

	local playerGui = Players.LocalPlayer:FindFirstChild("PlayerGui")
	local abilitiesUI = playerGui and playerGui:FindFirstChild("CC_Core"):FindFirstChild("Abilities")
	if abilitiesUI then
		local ability = abilitiesUI:FindFirstChild("BlockAbility")
		if ability then
			ability:Destroy()
		end
	end
end

return GenericAnimatable
