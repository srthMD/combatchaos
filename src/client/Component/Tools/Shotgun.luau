local rStore = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local SETTINGS = {
	Tag = "Shotgun",
}

local Component = { Tag = SETTINGS.Tag }
Component.__index = Component

local Shaker = require(rStore.Libs.CameraShaker)

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
		["shaker"] = Shaker.new(Enum.RenderPriority.Last.Value, function(shakeCf: CFrame)
			local newCF = CFrame.new(Vector3.new(shakeCf.X, -math.abs(shakeCf.Y), shakeCf.Z), shakeCf.LookVector * 5)
			workspace.CurrentCamera.CFrame *= newCF
		end),
		["rotShaker"] = Shaker.new(Enum.RenderPriority.Last.Value, function(shakeCf: CFrame)
			local newCF = CFrame.new(Vector3.new(shakeCf.X, shakeCf.Y, shakeCf.Z), shakeCf.LookVector * 25)
			workspace.CurrentCamera.CFrame *= newCF
		end),
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

	self.shaker:Start()
	self.rotShaker:Start()

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

			self.rotShaker:ShakeOnce(12, 100, 0.05, 0.1, Vector3.zero, Vector3.new(1, 0.8, 1))
			self.shaker:ShakeOnce(
				8,
				60,
				0,
				0.075,
				Vector3.new(math.random(0.2, 0.4), 0.95, math.random(0.2, 0.4)),
				Vector3.new(1, 0, 1)
			)

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
