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
	self.Humanoid = self.Instance:FindFirstChildWhichIsA("Humanoid")
	self["Ragdolled"] = false
end

function Ragdollable:Start()
	if self.Humanoid == nil then
		self:Stop()
		return
	end

	ev_AddRagdoll:Fire(self)

	self.Humanoid.Died:Once(function()
		ev_DoRagdoll:Fire(self.Character)
	end)

	RagdollJoints:SetupJoints(self.Character, self.Humanoid)
	local a = Instance.new("Attachment")
	a.Name = "LinearVelAttachment"
	a.Parent = self.Character.HumanoidRootPart
	a.Position = self.Character.HumanoidRootPart.Position

	self.Humanoid.BreakJointsOnDeath = false
	self.Humanoid:SetStateEnabled(Enum.HumanoidStateType.GettingUp, false)
end

function Ragdollable:Stop()
	self.Humanoid = nil
	ev_RemoveRagdoll:Fire(self.Character)
end

return Ragdollable
