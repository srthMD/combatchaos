local rStore = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local rServ = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")

local rev_ReplicateGetUp = rStore.Signals.Remote.ReplicateGetUp

local Component = require(rStore.Packages.Component)

local Ragdollable = Component.new({
	Tag = "Ragdollable",
	Ancestors = { workspace },
	Extensions = {
		{
			ShouldConstruct = function(component)
				local char = Players.LocalPlayer.Character

				if not char then
					return false
				end

				return component.Instance:IsDescendantOf(char)
			end,
		},
	},
})

local DOWN = Vector3.new(0, -6, 0)

local rev_Ragdoll = rStore.Signals.Remote.ReplicateRagdoll

local function waitUntilGrounded(model: Model): number
	local torso = model:FindFirstChild("Torso")

	if not torso then
		return 0
	end

	while true do
		for i = 0, 3, 1 do
			rServ.Heartbeat:Wait()
		end

		if torso.AssemblyLinearVelocity.Magnitude <= 4 then
			local rcp = RaycastParams.new()
			rcp.RespectCanCollide = true
			rcp.IgnoreWater = false
			rcp.FilterDescendantsInstances = { model }

			local res = workspace:Raycast(torso.Position, DOWN, rcp)
			--local waterCheck = workspace:Raycast(torso.Position + (Vector3.yAxis * 3), DOWN, rcp)

			local min = torso.Position - (0.5 * torso.Size)
			local max = torso.Position + (0.5 * torso.Size)
			local region = Region3.new(min, max):ExpandToGrid(4)

			local material = workspace.Terrain:ReadVoxels(region, 4)[1][1][1]
			if material == Enum.Material.Water then
				return 1
			end

			--if waterCheck then
			--	if waterCheck.Material == Enum.Material.Water then
			--		return
			--	end
			--end

			if res then
				local penalty = if res.Material == Enum.Material.Water then 1 else 0

				return penalty
			end
		end
	end
end

function Ragdollable:Construct()
	assert(self.Instance.ClassName == "Humanoid")

	self.Ragdolled = false
	self.Character = self.Instance.Parent
end

function Ragdollable:Start()
	self.Instance.Died:Once(function()
		self:StartRagdoll()
	end)

	self.Connection = rev_Ragdoll.OnClientEvent:Connect(function(recoveryTime: number?, force: Vector3?)
		self:StartRagdoll(recoveryTime, force)
	end)

	self.Instance.BreakJointsOnDeath = false
	self.Instance:SetStateEnabled(Enum.HumanoidStateType.GettingUp, false)
end

function Ragdollable:GetUp()
	if self.Instance.Health > 0 then
		if self.Ragdolled then
			for i, v in pairs(self.Character:GetDescendants()) do
				if v:IsA("Motor6D") and v.Name ~= "RootJoint" then
					v.Enabled = true
				end
			end

			self.Instance:ChangeState(Enum.HumanoidStateType.GettingUp)
			self.Instance.AutoRotate = true
		end
	end

	StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, true)
	self.Ragdolled = false
	rev_ReplicateGetUp:FireServer(self.Character)
end

function Ragdollable:StartRagdoll(recoveryTime: number?, force: Vector3?)
	if self.Ragdolled then
		if force then
			self.Character.Torso:ApplyImpulse(force)
		end

		return
	end

	self.Instance.AutoRotate = false
	self.Ragdolled = true
	self.Instance:ChangeState(Enum.HumanoidStateType.Physics)
	StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, false)
	self.Instance:UnequipTools()

	for _, anim in pairs(self.Instance:GetPlayingAnimationTracks()) do
		anim:Stop()
	end

	for _, inst in pairs(self.Character:GetDescendants()) do
		if inst:IsA("Motor6D") and inst.Name ~= "RootJoint" then
			inst.Enabled = false
		end
	end

	if force then
		self.Character.Torso:ApplyImpulse(force)
	end

	if recoveryTime then
		local penalty = waitUntilGrounded(self.Character)

		task.delay(recoveryTime + penalty, function()
			self:GetUp()
		end)
	end
end

function Ragdollable:Stop()
	StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, true)

	if self.Connection and self.Connection.Connected then
		self.Connection:Disconnect()
	end

	self.Ragdolled = false
	self.Character = nil
end

return Ragdollable
