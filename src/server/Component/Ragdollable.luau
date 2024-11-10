--> Services
local rStore = game:GetService("ReplicatedStorage")
local sStore = game:GetService("ServerStorage")

--> Component Framework Dependencies
local Component = require(rStore.Packages.Component)

local Ragdollable = Component.new({ Tag = "Ragdollable", Ancestors = { workspace } })

local RagdollJoints = require(sStore.Shared.RagdollJoints)

--> Variables
local ev_AddRagdoll = sStore.Signals.Event.AddRagdoll
local ev_RemoveRagdoll = sStore.Signals.Event.RemoveRagdoll
local ev_DoRagdoll = sStore.Signals.Event.DoRagdoll

function Ragdollable:Construct()
	assert(self.Instance.ClassName == "Humanoid")

	self.Ragdolled = false
	self.Character = self.Instance.Parent
end

function Ragdollable:Start()
	ev_AddRagdoll:Fire(self.Instance)

	self.Instance.Died:Once(function()
		ev_DoRagdoll:Fire(self.Instance)
	end)

	RagdollJoints:SetupJoints(self.Character, self.Instance)
	local a = Instance.new("Attachment")
	a.Name = "LinearVelAttachment"
	a.Parent = self.Instance.Parent.HumanoidRootPart
	a.Position = self.Instance.Parent.HumanoidRootPart.Position

	self.Instance.BreakJointsOnDeath = false
	self.Instance:SetStateEnabled(Enum.HumanoidStateType.GettingUp, false)
end

function Ragdollable:Stop()
	ev_RemoveRagdoll:Fire(self.Instance)
end

return Ragdollable
