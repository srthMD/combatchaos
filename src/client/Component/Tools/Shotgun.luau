local rStore = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local SETTINGS = {
	Tag = "Shotgun",
}

local Component = { Tag = SETTINGS.Tag }
Component.__index = Component

local CreateProjectileEvent = rStore.Signals.Client.CreateProjectile

local equipSound = rStore.Assets.ItemDeps.Shotgun.EquipSound

local rand = Random.new(os.time())

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

		-- Set the animation ID here before loading
		self.animation.AnimationId = "rbxassetid://17537754482" -- Set the animation ID
		self.animator = Player.Character:WaitForChild("Humanoid"):LoadAnimation(self.animation) -- Load the animation after setting ID
	end)

	self.Instance.Activated:Connect(function()
		if not self.debounce then
			self.debounce = true

			local hPos = self.Instance.Handle.Position
			local mHit = Mouse.Hit.Position
			local dir = (mHit - hPos).Unit

			for i = 0, 7, 1 do
				local spread = dir + rand:NextUnitVector() * 0.04

				if i == 0 then
					CreateProjectileEvent:Fire("Shotgun", hPos, spread, true)
				else
					CreateProjectileEvent:Fire("Shotgun", hPos, spread)
				end
			end

			-- Play the animation
			if self.animator then
				self.animator:Play()
			end

			task.wait(self.Instance.Cooldown.Value)
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
