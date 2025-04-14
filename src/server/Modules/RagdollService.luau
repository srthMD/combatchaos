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
local rev_ReplicateGetUp = rStore.Signals.Remote.ReplicateGetUp

--> Private Functions
local function addModel(char: Model)
	local hum = char:FindFirstChildWhichIsA("Humanoid")

	if hum then
		hum:AddTag("Ragdollable")
		--hum.BreakJointsOnDeath = false
		--hum:SetStateEnabled(Enum.HumanoidStateType.GettingUp, false)
		RagdollJoints:SetupJoints(char, hum)
	end
end

local function doRagdoll(char: Model, recoveryTime: number?, force: Vector3?)
	local plr = Players:GetPlayerFromCharacter(char)

	if not plr then
		return
	end

	for _, inst in pairs(char:GetDescendants()) do
		if inst:IsA("Motor6D") and inst.Name ~= "RootJoint" then
			inst.Enabled = false
		end
	end

	rev_ReplicateRagdoll:FireClient(plr, recoveryTime, force)
end

--i dont really care if this is exploitable lol
local function replicateGetUp(plr: Player, char: Model)
	local plrChar = plr.Character

	if not plrChar then
		return
	end

	if char ~= plrChar then
		return
	end

	local hum = char:FindFirstChildWhichIsA("Humanoid")

	if not hum:HasTag("Ragdollable") then
		return
	end

	for _, inst in pairs(char:GetDescendants()) do
		if inst:IsA("Motor6D") and inst.Name ~= "RootJoint" then
			inst.Enabled = true
		end
	end
end

--> Module Functions

--> Loader Functions
function module.Start()
	ev_AddModel.Event:Connect(addModel)
	ev_DoRagdoll.Event:Connect(doRagdoll)
	rev_ReplicateGetUp.OnServerEvent:Connect(replicateGetUp)

	Players.PlayerAdded:Connect(function(plr)
		plr.CharacterAdded:Connect(addModel)
	end)
end

return module
