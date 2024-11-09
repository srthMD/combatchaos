-- @title: Server Projectile Handler
-- @author: qweekertom
-- @date: 2.29.2024

--> Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")

--> Variables
local module = {}

local SharedType = require(ReplicatedStorage.Data.SharedType)
local SharedFuncs = require(ServerScriptService.Server.Shared.Projectile.ProjectileShared)

local rev_ReplicateProjectile = ReplicatedStorage.Signals.Remote.ReplicateProjectile
local rev_Hit = ReplicatedStorage.Signals.Remote.Hit

local CastParams = RaycastParams.new()
CastParams.FilterType = Enum.RaycastFilterType.Exclude

--in seconds
local DIFF_DROP_PACKET = 2

--> Private Functions
function _fireClientsExcept(exception: Player, ...)
	for _, player in Players:GetPlayers() do
		if player == exception then
			continue
		end
		rev_ReplicateProjectile:FireClient(player, ...)
	end
end

function HitSomething(plr: Player, userData: { any }, result: {}, velocity: Vector3, inst: Instance, t: number)
	local diff = os.time() - t
	local packet = userData.Packet :: SharedType.ProjectilePacket

	if diff > DIFF_DROP_PACKET then
		warn(`Dropped projectile packet from {packet.Owner.Name} because diff was {diff} seconds.`)
		return
	end

	packet.Owner = plr

	local func = SharedFuncs.getFunc(packet.ProjectileType, "Hit")

	if func then
		func(packet, result)
	else
		SharedFuncs.defaultHitBehaviour(packet, result)
	end
end

--function ClampMagnitude(v, max)
--    if (v.magnitude == 0) then return Vector3.new(0,0,0) end -- prevents NAN,NAN,NAN
--    return v.Unit * math.min(v.Magnitude, max)
--end

-- Dosent do anything in live servers
--function sendVisualization(owner: Player, pos: Vector3, dir: Vector3, hit: boolean)
--	if isStudio then
--		urev_VisualizeProjectile:FireClient(owner, pos, dir, hit)
--	end
--end

--function StepProjectiles(t, dt)
--    for key, projectile in ProjectileCache :: {[string]: SharedType.ProjectilePacket} do
--        local timeNow = os.time()
--        local projectileInfo: SharedType.ProjectileInfo = Projectiles[projectile.ProjectileType]
--        CastParams.FilterDescendantsInstances = {projectile.Owner.Character}

--        local steppedVelocity = projectile.Velocity + (projectile.Acceleration * dt)
--        local steppedPosition = projectile.Position + (steppedVelocity * dt)

--		local castResult: RaycastResult

--		local dir = projectile.Velocity * dt

--        if projectileInfo.UseSpherecast then
--            castResult = workspace:Spherecast(projectile.Position, projectileInfo.CastRadius, dir, CastParams)
--        else
--			castResult = workspace:Raycast(projectile.Position, dir, CastParams)
--		end

--		projectile.Velocity = steppedVelocity
--		projectile.Position = steppedPosition

--        if castResult then
--			ProjectileCache[key] = nil
--			sendVisualization(projectile.Owner, castResult.Position, nil, true)
--			HitSomething(castResult, projectile)
--        elseif timeNow - projectile.StartTime > projectileInfo.Lifetime then
--			ProjectileCache[key] = nil
--		else
--			sendVisualization(projectile.Owner, projectile.Position, dir, false)
--        end
--    end
--end

function AddProjectile(owner: Player, packet: SharedType.ProjectilePacket, doSound: boolean)
	local char = owner.Character

	if not owner.Character then
		return
	end

	local root: BasePart? = char:FindFirstChild("HumanoidRootPart")

	if not root then
		return
	end

	local dist = (packet.Origin - root.Position)

	if dist.Magnitude > 16 then
		return
	end

	packet.Owner = owner

	--local behaviour = FastCast.newBehavior()
	--local rcp = RaycastParams.new()
	--rcp.FilterDescendantsInstances = {owner.Character}
	--rcp.IgnoreWater = true
	--rcp.FilterType = Enum.RaycastFilterType.Exclude
	--behaviour.RaycastParams = rcp
	--behaviour.Acceleration = Vector3.new(0, -9.81, 0)
	--local Cast = Caster:Fire(packet.Origin, packet.Velocity.Unit, packet.Velocity.Magnitude, behaviour)
	--Cast.UserData = {Packet = packet}

	local func = SharedFuncs.getFunc(packet.ProjectileType, "Spawn")

	if func then
		task.spawn(func, packet, doSound)
	else
		if doSound then
			task.spawn(SharedFuncs.defaultSpawnBehaviour, packet)
		end
	end

	_fireClientsExcept(owner, packet)
end

--> Module Functions

--> Loader Methods
function module.Start()
	rev_Hit.OnServerEvent:Connect(HitSomething)
	rev_ReplicateProjectile.OnServerEvent:Connect(AddProjectile)
end

return module
