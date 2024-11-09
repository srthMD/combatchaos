local module = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local RunService = game:GetService("RunService")

local deps: Folder = ReplicatedStorage.Assets.ItemDeps

local isStudio = RunService:IsStudio()

local SharedTypes = require(ReplicatedStorage.Data.SharedType)
local Projectiles = require(ReplicatedStorage.Data.Projectiles.Loader)

local urev_HitIndicator = ReplicatedStorage.Signals.Remote.Unreliable.HitIndicator
local ev_AddKill = ServerStorage.Signals.Event.AddKill

function module.getFunc(proj: string, state: string)
	local mod = script.Parent.__data:FindFirstChild(proj)

	if mod then
		return require(mod)[state]
	else
		return nil
	end
end

function module.defaultSpawnBehaviour(packet: SharedTypes.ProjectilePacket)
	local assets = deps:FindFirstChild(packet.ProjectileType)

	if not assets then
		warn(`Assets for projectile {packet.ProjectileType} not found.`)
		warn(debug.traceback())

		return
	end

	if not assets:IsA("Folder") then
		warn(`Assets should be a folder for Instance {assets.Name}, got {assets.ClassName}, continuing anyway.`)
		warn(debug.traceback())
	end

	local fireSound: Sound = assets:FindFirstChild("Fire")

	if not fireSound then
		if isStudio then
			warn(`{assets.Name} has no fire sound.`)
		end

		return
	end

	if not fireSound:IsA("Sound") then
		warn(`defaultspawnbehaviour requires Fire to be a Sound, got {fireSound.ClassName}.`)
		warn(debug.traceback())

		return
	end

	local firePart = deps:FindFirstChild("FirePart")

	if not firePart then
		warn(`Could not find FirePart in ItemDeps.`)
		warn(debug.traceback())

		return
	end

	local part = Instance.fromExisting(firePart)
	part.Parent = workspace.Debris
	part.Position = packet.Origin

	local sound = fireSound:Clone()
	sound.Parent = part
	sound:Play()
	sound.Ended:Wait()
	sound:Destroy()
end

function module.defaultHitBehaviour(packet: SharedTypes.ProjectilePacket, rcr: RaycastResult)
	local hit = rcr.Instance
	local info = Projectiles(packet.ProjectileType)

	local pHum: Humanoid = hit.Parent:FindFirstChildOfClass("Humanoid")
	if pHum and pHum.Health > 0 then
		local baseDamage = info.BaseDamage

		if rcr.Instance.Name == "Head" then
			baseDamage *= 1.5
		end

		pHum:TakeDamage(baseDamage)

		if pHum.Health <= 0 then
			ev_AddKill:Fire(packet.Owner)
		end

		urev_HitIndicator:FireClient(packet.Owner, baseDamage, pHum.Parent.Head.Position, nil, pHum.Parent)
	end
end

return module
