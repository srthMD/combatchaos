local module = {} -- Joints made by roblox from the drooling zombie model
local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")

local RigTypes = require(script.Parent.RigTypes)

local JOINTS_TAG = "__Ragdoll_Joints"
local RAGDOLLED_TAG = "__Ragdoll_Active"

local function CreateJoints(model, humanoid)
	CollectionService:AddTag(model, JOINTS_TAG)
	local attachments = RigTypes.getAttachments(model, humanoid.RigType)
	for name, objects in pairs(attachments) do
		local parent = model:FindFirstChild(name)
		if parent then
			local constraint = Instance.new("BallSocketConstraint")
			constraint.Name = "RagdollBallSocketConstraint"
			constraint.Attachment0 = objects.attachment0
			constraint.Attachment1 = objects.attachment1
			constraint.LimitsEnabled = true
			constraint.MaxFrictionTorque = 0.025
			constraint.UpperAngle = objects.limits.UpperAngle
			constraint.TwistLimitsEnabled = true
			constraint.TwistLowerAngle = objects.limits.TwistLowerAngle
			constraint.TwistUpperAngle = objects.limits.TwistUpperAngle
			constraint.Parent = parent
		end
	end

	local head = model:FindFirstChild("Head")
	if head then
		head.Size = Vector3.new(1, 1, 1)
			head.Shape = 0 -- makes the head sphericla
	end
end

function module:SetupJoints(model, humanoid)
	assert(humanoid:IsDescendantOf(model))
	if CollectionService:HasTag(model, JOINTS_TAG) then
		return
	end

	-- Turn into loose body:
	CreateJoints(model, humanoid)
	-- Instantiate BallSocketConstraints:
end

function module:Ragdoll(model, humanoid, fall)
	assert(humanoid:IsDescendantOf(model))
	if fall and CollectionService:HasTag(model, RAGDOLLED_TAG) then
		return
	end

	CollectionService:AddTag(model, RAGDOLLED_TAG)
	if CollectionService:HasTag(model, JOINTS_TAG) then
		return
	end
	-- Turn into loose body:
end

return module
