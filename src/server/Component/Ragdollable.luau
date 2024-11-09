--> Services
local rStore = game:GetService("ReplicatedStorage")
local sStore = game:GetService("ServerStorage")

--> Component Framework Dependencies
local Rcade = require(rStore.Libs.Rcade)

local SETTINGS = {
	Tag = "Ragdollable",
}

--> Class Definition
local Ragdollable = Rcade.class({ Tag = SETTINGS.Tag })

--> Variables
local ev_AddRagdoll = sStore.Signals.Event.AddRagdoll
local ev_RemoveRagdoll = sStore.Signals.Event.RemoveRagdoll
local ev_DoRagdoll = sStore.Signals.Event.DoRagdoll

local RagdollJoints = require(sStore.Libs.RagdollJoints)

--> Constructor
function Ragdollable:__init(inst: Humanoid)
	self["Humanoid"] = inst
	self["Character"] = inst.Parent
	self["Ragdolled"] = false
	self:__backendInit()
end

--> Backend Constructor
function Ragdollable:__backendInit()
	ev_AddRagdoll:Fire(self)

	self.Humanoid.Died:Once(function()
		self:OnDied()
	end)

	RagdollJoints:SetupJoints(self.Character, self.Humanoid)
	local a = Instance.new("Attachment")
	a.Name = "LinearVelAttachment"
	a.Parent = self.Character.HumanoidRootPart
	a.Position = self.Character.HumanoidRootPart.Position

	self.Humanoid.BreakJointsOnDeath = false
	self.Humanoid:SetStateEnabled(Enum.HumanoidStateType.GettingUp, false)

	self.Character.Destroying:Connect(function()
		ev_RemoveRagdoll:Fire(self.Character)
	end)
end

--> Private Functions

--> Module Functions

function Ragdollable:Destroy()
	self.Character = nil
	self.Humanoid = nil
	ev_RemoveRagdoll:Fire(self.Character)
end

function Ragdollable:OnDied()
	ev_DoRagdoll:Fire(self.Character)

	self:Destroy()
end

return Ragdollable
