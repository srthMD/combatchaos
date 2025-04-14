local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Debris = game:GetService("Debris")

local module = {}

local SharedType = require(ReplicatedStorage.Data.SharedType)
local FastCast = require(ReplicatedStorage.Packages.FastCast)
local Projectiles = require(ReplicatedStorage.Data.Projectiles.Loader)

local Caster = FastCast.new()

local LocalPlayer = Players.LocalPlayer

local ev_CreateProjectile = ReplicatedStorage.Signals.Client.CreateProjectile
local rev_ReplicateProjectile = ReplicatedStorage.Signals.Remote.ReplicateProjectile
local rev_Hit = ReplicatedStorage.Signals.Remote.Hit

local CastParams = RaycastParams.new()
CastParams.FilterType = Enum.RaycastFilterType.Exclude

function HitSomething(cast, result: RaycastResult, velocity: Vector3, inst: Instance)
	local t = os.time()
	local packet = cast.UserData.Packet

	if packet.Owner == false then
		inst:Destroy()
		return
	end

	rev_Hit:FireServer(
		cast.UserData,
		{ Instance = result.Instance, Position = result.Position, Material = result.Material },
		velocity,
		inst,
		t
	)

	inst:Destroy()
end

function cleanUpInst(inst: Instance)
	for _, v in pairs(inst:GetDescendants()) do
		if v:IsA("ParticleEmitter") then
			v.Enabled = false
		end

		if v:IsA("PVAdornment") or v:IsA("Highlight") or v:IsA("Light") or v:IsA("BillboardGui") then
			v:Destroy()
		end

		if v:IsA("BasePart") then
			v.Transparency = 1
		end

		if v:IsA("SpecialMesh") then
			v:Destroy()
		end

		Debris:AddItem(inst, 2)
	end
end

function StepProjectile(
	cast,
	lastPoint: Vector3,
	rayDir: Vector3,
	displacement: number,
	velocity: Vector3,
	inst: BasePart
)
	if cast.StateInfo.TotalRuntime > cast.UserData.Lifetime then
		cast:Terminate()
		cleanUpInst(inst)
	end

	inst.Position = lastPoint + (rayDir * displacement)
end

function AddProjectile(id: string, start: Vector3, direction: Vector3, doSound: boolean?, owner: Player?)
	local data = Projectiles(id)

	if owner then
		local behaviour = FastCast.newBehavior()
		behaviour.CosmeticBulletTemplate = data.Model
		local rcp = RaycastParams.new()
		rcp.FilterDescendantsInstances = { LocalPlayer.Character }
		rcp.IgnoreWater = true
		rcp.FilterType = Enum.RaycastFilterType.Exclude
		behaviour.RaycastParams = rcp
		behaviour.Acceleration = data.Acceleration
		behaviour.CosmeticBulletContainer = workspace.Debris
		local Cast = Caster:Fire(start, direction.Unit, direction.Magnitude, behaviour)
		Cast.UserData = { Packet = { Owner = false }, Lifetime = data.Lifetime }

		return
	end

	local t0 = os.time()

	local new: SharedType.ProjectilePacket = {
		Id = id,
		Origin = start,
		Position = start,
		Velocity = direction * data.Velocity,
		Acceleration = data.Acceleration,
		StartTime = t0,
		ProjectileType = id,
	}

	local behaviour = FastCast.newBehavior()
	behaviour.CosmeticBulletTemplate = data.Model
	local rcp = RaycastParams.new()
	rcp.FilterDescendantsInstances = { LocalPlayer.Character }
	rcp.IgnoreWater = true
	rcp.FilterType = Enum.RaycastFilterType.Exclude
	behaviour.RaycastParams = rcp
	behaviour.Acceleration = data.Acceleration
	behaviour.CosmeticBulletContainer = workspace.Debris
	local Cast = Caster:Fire(start, direction.Unit, new.Velocity, behaviour)
	Cast.UserData = { Packet = new, Lifetime = data.Lifetime }

	if doSound == nil then
		doSound = true
	end

	rev_ReplicateProjectile:FireServer(table.clone(new), doSound)
end

function ReplicateProjectile(packet: SharedType.ProjectilePacket)
	--	local currentTime = os.time()
	--	local data = Projectiles(packet.Id)
	--	local deltaTime = currentTime - packet.StartTime

	if packet["Id"] == nil then
		return
	end

	local pos = packet.Origin -- + (packet.Velocity * deltaTime)

	AddProjectile(packet.Id, pos, packet.Velocity, true, packet.Owner)
end

function module.Start()
	Caster.RayHit:Connect(HitSomething)
	Caster.LengthChanged:Connect(StepProjectile)
	ev_CreateProjectile.Event:Connect(AddProjectile)
	rev_ReplicateProjectile.OnClientEvent:Connect(ReplicateProjectile)
end

return module
