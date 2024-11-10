local rStore = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local SETTINGS = {
	Tag = "Revolver",
}

local Component = { Tag = SETTINGS.Tag }
Component.__index = Component

local CreateProjectileEvent = rStore.Signals.Client.CreateProjectile

local equipSound = rStore.Assets.ItemDeps.Revolver.EquipSound

local Player = Players.LocalPlayer
local Mouse = Player:GetMouse()

function Component.new(inst: Tool)
	local self = setmetatable({
		["_initalized"] = false,
		["Instance"] = inst,
		["debounce"] = false,
		["animation"] = Instance.new("Animation"),
		["animator"] = nil, -- Will be initialized later
	}, Component)

	self:_init()
	return self
end

function Component:_init()
	if self._initalized == true then
		return
	end
	self._initalized = true

	math.randomseed(os.time())

	self.Instance.Equipped:Connect(function(mouse)
		local clone = equipSound:Clone()
		clone.Parent = self.Instance
		clone:Play()

		-- Set the animation ID here
		self.animation.AnimationId = "rbxassetid://17537676504" -- Set the animation ID
		local humanoid = Player.Character and Player.Character:FindFirstChild("Humanoid")
		if humanoid then
			self.animator = humanoid:LoadAnimation(self.animation)
		else
			warn("Humanoid not found in character.")
		end
	end)

	self.Instance.Activated:Connect(function()
		if not self.debounce then
			self.debounce = true

			local hPos = self.Instance.Handle.Position
			local mHit = Mouse.Hit.Position
			local dir = (mHit - hPos).Unit

			-- Fire the revolver bullet
			CreateProjectileEvent:Fire("Revolver", hPos, dir)

			-- Play the animation
			if self.animator then
				self.animator:Play()
			end

			task.wait(0.5)
			self.debounce = false
		end
	end)

	self.Instance.Destroying:Connect(function()
		self:Destroy()
	end)
end

function Component:Destroy()
	self.Instance = nil
	self.rotShaker = nil
	self.shaker = nil
end

return Component
