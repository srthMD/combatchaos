--> Services
local Players = game:GetService("Players")
local sStore = game:GetService("ServerStorage")
local rStore = game:GetService("ReplicatedStorage")

local RagdollJoints = require(sStore.Shared.RagdollJoints)

--> Module Stuff
local module = {}

--> Variables
local ev_AddModel = sStore.Signals.Event.AddRagdoll
local ev_DoRagdoll = sStore.Signals.Event.DoRagdoll
local rev_ReplicateRagdoll = rStore.Signals.Remote.ReplicateRagdoll

--> Private Functions
local function addModel(char: Model)
	local hum = char:FindFirstChild("Humanoid")

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

	rev_ReplicateRagdoll:FireClient(plr, recoveryTime, force)
end

--> Module Functions

--> Loader Functions
function module.Start()
	ev_AddModel.Event:Connect(addModel)
	ev_DoRagdoll.Event:Connect(doRagdoll)

	Players.PlayerAdded:Connect(function(plr)
		plr.CharacterAdded:Connect(addModel)
	end)
end

return module
