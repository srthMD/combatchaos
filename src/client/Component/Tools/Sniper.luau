local rStore = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local SETTINGS = {
	Tag = "Sniper",
}

local Component = { Tag = SETTINGS.Tag }
Component.__index = Component

local Shaker = require(rStore.Libs.CameraShaker)

local CreateProjectileEvent = rStore.Signals.Client.CreateProjectile

local equipSound = rStore.Assets.ItemDeps.Sniper.EquipSound

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

function isFirstPerson(cameraPos: Vector3)
	return Player:DistanceFromCharacter(cameraPos) < 1
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

		-- Set the animation ID here
		self.animation.AnimationId = "rbxassetid://17537862815" -- Set the animation ID
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

			self.rotShaker:ShakeOnce(10, 90, 0.05, 0.1, Vector3.zero, Vector3.new(1, 0.8, 1))
			self.shaker:ShakeOnce(
				7.5,
				60,
				0,
				0.075,
				Vector3.new(math.random(0.3, 0.5), 0.8, math.random(0.3, 0.5)),
				Vector3.new(1, 0, 1)
			)

			local hPos = self.Instance.Handle.Position
			local mHit = Mouse.Hit.Position
			local dir = (mHit - hPos).Unit

			-- Fire the sniper bullet
			CreateProjectileEvent:Fire("Sniper", hPos, dir)

			-- Play the animation
			if self.animator then
				self.animator:Play()
			end

			task.wait(2.75)
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
