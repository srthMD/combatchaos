local Players = game:GetService("Players")
local sStore = game:GetService("ServerStorage")
local rStore = game:GetService("ReplicatedStorage")

local RagdollJoints = require(sStore.Shared.RagdollJoints)

local module = {}

local ev_AddModel = sStore.Signals.Event.AddRagdoll
local ev_DoRagdoll = sStore.Signals.Event.DoRagdoll
local rev_ReplicateRagdoll = rStore.Signals.Remote.ReplicateRagdoll
local rev_ReplicateGetUp = rStore.Signals.Remote.ReplicateGetUp

local function addModel(char: Model)
	local hum = char:FindFirstChildWhichIsA("Humanoid")
	if hum then
		hum:AddTag("Ragdollable")
		RagdollJoints:SetupJoints(char, hum)
	end
end

local function doRagdoll(char: Model, recoveryTime: number?, force: Vector3?)
	local plr = Players:GetPlayerFromCharacter(char)
	if not plr then
		return
	end

	for _, inst in pairs(char:GetDescendants()) do
		if inst:IsA("Motor6D") then
			if inst.Name ~= "RootJoint" then
				inst.Enabled = false
			else
				inst.Enabled = false -- disable RootJoint too
			end
		end
	end

	local root = char:FindFirstChild("HumanoidRootPart")
	local torso = char:FindFirstChild("Torso")

	local hasTag = char:HasTag("Ragdolled")

	-- this part is when u see people ragdolling they will smoothly ragdol 😀
	if root and torso and not hasTag then
		char:AddTag("Ragdolled")

		-- create attachments
		local a0 = Instance.new("Attachment")
		a0.Name = "RagdollAttachmentRoot"
		a0.Position = Vector3.zero
		a0.Rotation = Vector3.zero
		a0.Parent = root

		local a1 = Instance.new("Attachment")
		a1.Name = "RagdollAttachmentTorso"
		a1.Position = Vector3.zero
		a1.Rotation = Vector3.zero
		a1.Parent = torso

		local ball = Instance.new("BallSocketConstraint")
		ball.Attachment0 = a0
		ball.Attachment1 = a1
		ball.LimitsEnabled = true
		ball.UpperAngle = 180
		ball.TwistLimitsEnabled = true
		ball.TwistLowerAngle = -180
		ball.TwistUpperAngle = 180
		ball.Parent = root

		local align = Instance.new("AlignOrientation")
		align.Name = "RagdollAlignOrientation"
		align.Attachment0 = a0
		align.RigidityEnabled = false
		align.Responsiveness = 10
		align.MaxAngularVelocity = 0
		align.MaxTorque = math.huge
		align.Mode = Enum.OrientationAlignmentMode.OneAttachment
		align.Parent = root
	end

	rev_ReplicateRagdoll:FireClient(plr, recoveryTime, force)
end

local function replicateGetUp(plr: Player, char: Model)
	local plrChar = plr.Character
	if not plrChar or char ~= plrChar then
		return
	end

	plrChar:RemoveTag()

	local hum = char:FindFirstChildWhichIsA("Humanoid")
	if not hum or not hum:HasTag("Ragdollable") then
		return
	end

	for _, inst in pairs(char:GetDescendants()) do
		if inst:IsA("Motor6D") then
			inst.Enabled = true
		end
	end

	local root = char:FindFirstChild("HumanoidRootPart")
	if root then
		local align = root:FindFirstChild("RagdollAlignOrientation")
		if align then
			align:Destroy()
		end

		for _, obj in pairs(root:GetChildren()) do
			if obj:IsA("BallSocketConstraint") or obj.Name == "RagdollAttachmentRoot" then
				obj:Destroy()
			end
		end
	end

	local torso = char:FindFirstChild("Torso")
	if torso then
		local a1 = torso:FindFirstChild("RagdollAttachmentTorso")
		if a1 then
			a1:Destroy()
		end
	end
end

function module.Start()
	ev_AddModel.Event:Connect(addModel)
	ev_DoRagdoll.Event:Connect(doRagdoll)
	rev_ReplicateGetUp.OnServerEvent:Connect(replicateGetUp)

	Players.PlayerAdded:Connect(function(plr)
		--[[e]]
		plr.CharacterAdded:Connect(addModel)
	end)
end

return module
