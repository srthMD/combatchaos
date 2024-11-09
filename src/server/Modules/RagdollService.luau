--> Services
local rStore = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local sStore = game:GetService("ServerStorage")
local rServ = game:GetService("RunService")

--> Module Stuff
local module = {}

--> Variables
local ev_AddModel = sStore.Signals.Event.AddRagdoll
local ev_RemoveRagdoll = sStore.Signals.Event.RemoveRagdoll
local ev_getRagdollable = sStore.Signals.Event.GetRagdoll
local ev_DoRagdoll = sStore.Signals.Event.DoRagdoll
local rev_Ragdoll = rStore.Signals.Remote.ReplicateRagdoll

local models = {}

local DOWN = Vector3.new(0, -3, 0)

--> Private Functions
function addModel(ragdollable)
	models[ragdollable.Character.Name] = ragdollable
end

function removeModel(model: Model)
	if model == nil then
		return
	end
	models[model.Name] = nil

	for i, v in pairs(model:GetDescendants()) do
		if v:IsA("Motor6D") and v.Name ~= "RootJoint" and v.Name ~= "Root" then
			v.Enabled = false
		end
	end
end

function getRagdoll(model: Model): (Model?, number?)
	for i, v in pairs(models) do
		if v.Character == model then
			return v, i
		end
	end

	return nil
end

function doRagdoll(model: Model, getUpTime: number?, force: Vector3?)
	local v, _idx = getRagdoll(model)

	if not v then
		return
	end

	v.Ragdolled = true
	for _, anim in pairs(v.Humanoid:GetPlayingAnimationTracks()) do
		anim:Stop()
	end

	for _, inst in pairs(v.Character:GetDescendants()) do
		if inst:IsA("Motor6D") and inst.Name ~= "RootJoint" and inst.Name ~= "Waist" and inst.Name ~= "Root" then
			inst.Enabled = false
		end
	end

	local c = nil

	local plr = Players:GetPlayerFromCharacter(v.Character)
	if plr then
		for _, inst in pairs(model:GetChildren()) do
			if inst:IsA("Tool") then
				inst.Parent = plr.Backpack
			end

			if inst:IsA("BasePart") then
				if not inst.Anchored then
					inst:SetNetworkOwner(plr)
				end
			end
		end

		c = plr.Character.ChildAdded:Connect(function(a)
			if a:IsA("Tool") then
				if not plr.Backpack:FindFirstChild(a.Name) then
					a.Parent = plr.Backpack
				end
			end
		end)

		rev_Ragdoll:FireClient(Players:GetPlayerFromCharacter(v.Character), Enum.HumanoidStateType.Physics, force)
	else
		if force then
			task.delay(0.05, function()
				v.Character.Torso:ApplyImpulse(force)
			end)
		end
	end

	v.Humanoid.AutoRotate = false
	v.Humanoid:ChangeState(Enum.HumanoidStateType.Physics)

	if getUpTime then
		local penalty = waitUntilGrounded(v.Character)

		task.delay(getUpTime + penalty, function()
			getUp(v)

			if plr then
				if c and c.Connected then
					c:Disconnect()
				end
			end
		end)
	end
end

function getUp(v)
	if v.Humanoid.Health > 0 then
		if v.Ragdolled then
			for i, v in pairs(v.Character:GetDescendants()) do
				if v:IsA("Motor6D") and v.Name ~= "RootJoint" and v.Name ~= "Waist" and v.Name ~= "Root" then
					v.Enabled = true
				end
			end
			local plr = Players:GetPlayerFromCharacter(v.Character)

			if plr then
				rev_Ragdoll:FireClient(Players:GetPlayerFromCharacter(v.Character), Enum.HumanoidStateType.GettingUp)
			else
				v.Humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
			end

			v.Humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
			v.Humanoid.AutoRotate = true
		end
	end
	v.Ragdolled = false
end

function waitUntilGrounded(model: Model): number
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

--> Module Functions

--> Loader Functions
function module.Start()
	ev_AddModel.Event:Connect(addModel)
	ev_RemoveRagdoll.Event:Connect(removeModel)
	ev_getRagdollable.Event:Connect(getRagdoll)
	ev_DoRagdoll.Event:Connect(doRagdoll)

	Players.PlayerAdded:Connect(function(plr)
		plr.CharacterAdded:Connect(function(char)
			char:FindFirstChild("Humanoid"):AddTag("Ragdollable")
		end)
	end)
end

return module
