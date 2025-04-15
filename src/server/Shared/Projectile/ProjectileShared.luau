local module = {}

local SNIPER_MIN_DIST_NO_PENALTY = 70
local SNIPER_MAX_PENALTY_PERCENT = 0.8

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Debris = game:GetService("Debris")

local SharedEnums = require(ReplicatedStorage.Data.SharedEnums)

local deps: Folder = ReplicatedStorage.Assets.ItemDeps

local isStudio = RunService:IsStudio()

local SharedTypes = require(ReplicatedStorage.Data.SharedType)
local Projectiles = require(ReplicatedStorage.Data.Projectiles.Loader)

local urev_HitIndicator = ReplicatedStorage.Signals.Remote.Unreliable.HitIndicator
local urev_VisualizeHitbox = ReplicatedStorage.Signals.Remote.Unreliable.VisualizeHitbox
local ev_AddKill = ServerStorage.Signals.Event.AddKill
local ev_DoRagdoll = ServerStorage.Signals.Event.DoRagdoll
local ev_DropWepaon = ServerStorage.Signals.Event.DropWeapon

local emitterPart = ReplicatedStorage.Assets.emitter

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

	if not hit.Parent then
		return
	end

	local pHum: Humanoid = hit.Parent:FindFirstChildOfClass("Humanoid")
	if pHum and pHum.Health > 0 then
		local baseDamage = info.BaseDamage

		if rcr.Instance.Name == "Head" then
			baseDamage *= 1.65
		end

		if packet.ProjectileType == "Sniper" then
			local dist = math.clamp((rcr.Position - packet.Origin).Magnitude, 0, SNIPER_MIN_DIST_NO_PENALTY)

			local penalty = math.min(1 - dist / SNIPER_MIN_DIST_NO_PENALTY, SNIPER_MAX_PENALTY_PERCENT)
			baseDamage -= (baseDamage * penalty)
		end

		if info.Ragdoll then
			ev_DoRagdoll:Fire(
				pHum.Parent,
				info.Ragdoll.RecoveryTime,
				packet.Velocity.Unit * Vector3.new(1, 3, 1) * info.Ragdoll.Force
			)
		end

		pHum:TakeDamage(baseDamage)

		if pHum.Health <= 0 then
			ev_AddKill:Fire(packet.Owner)

			local plr = Players:GetPlayerFromCharacter(pHum.Parent)

			if plr and math.random(1, 4) == 3 then
				ev_DropWeapon:Fire(plr)
			end
		end

		urev_HitIndicator:FireClient(packet.Owner, baseDamage, pHum.Parent.Head.Position, nil, pHum.Parent)
	end

	if info.ExplosionData ~= nil then
		task.defer(function()
			local e_data = info.ExplosionData
			local char = packet.Owner.Character

			if not char then
				return
			end

			if info.ExplosionData.RobloxExplosionConfig then
				local hum = char:FindFirstChildWhichIsA("Humanoid")

				if not hum then
					return
				end

				withRobloxExplosion(e_data, packet, rcr.Position, hum)

				return
			end

			local CastParams = OverlapParams.new()
			CastParams.FilterType = Enum.RaycastFilterType.Exclude
			CastParams.RespectCanCollide = false

			if e_data.SelfHitRules then
				for rule, bool in pairs(e_data.SelfHitRules) do
					if bool then
						CastParams.FilterDescendantsInstances = { workspace.MainMap }
						break
					end
				end
			else
				CastParams.FilterDescendantsInstances = { char, workspace.MainMap }
			end

			local cf = CFrame.new(rcr.Position)

			if e_data.CastInfo.Type.Value == SharedEnums.MeleeCastType.Box.Value then
				local size: Vector3

				if typeof(e_data.CastInfo.Size) == "number" then
					size = Vector3.new(e_data.CastInfo.Size, e_data.CastInfo.Size, e_data.CastInfo.Size)
				else
					size = e_data.CastInfo.Size
				end

				local res = workspace:GetPartBoundsInBox(cf, size, CastParams)

				fromResults(res, e_data, packet, cf, size)
			else
				local size: number

				if typeof(e_data.CastInfo.Size) == "Vector3" then
					warn(
						`Projectile with explosion info has circular explosion hitbox but size of type vector3, pls fix.`
					)
					size = e_data.CastInfo.Size.Magnitude
				else
					size = e_data.CastInfo.Size
				end

				local res = workspace:GetPartBoundsInRadius(rcr.Position, size, CastParams)

				fromResults(res, e_data, packet, cf, Vector3.new(size, size, size))
			end
		end)
	end
end

function withRobloxExplosion(
	data: SharedTypes.ExplosionData,
	packet: SharedTypes.ProjectilePacket,
	pos: Vector3,
	shooter_hum: Humanoid
)
	local part = Instance.fromExisting(emitterPart)
	part.Name = "explosion"
	part.Position = pos

	local e = Instance.new("Explosion")
	e.Parent = part
	e.Position = part.Position
	e.DestroyJointRadiusPercent = 0
	e.ExplosionType = Enum.ExplosionType.NoCraters

	for key, value in pairs(data.RobloxExplosionConfig) do
		e[key] = value
	end

	local already_hit = {} :: { Humanoid }
	e.Hit:Connect(function(hit: BasePart)
		local hum = hit.Parent:FindFirstChildWhichIsA("Humanoid")

		if not hum then
			return
		end

		if hum.Health <= 0 then
			return
		end

		if table.find(already_hit, hum) then
			return
		end

		table.insert(already_hit, hum)

		if data.Damage ~= 0 then
			if data.SelfHitRules.ApplyDamage and shooter_hum == hum then
				hum:TakeDamage(data.Damage)

				if data.SelfHitRules.DoRagdoll then
					if force ~= 0 then
						ev_DoRagdoll:Fire(hum.Parent, data.RagdollInfo.RecoveryTime, nil)
					end
				end
			elseif shooter_hum ~= hum then
				hum:TakeDamage(data.Damage)

				local head: BasePart = hum.Parent:FindFirstChild("Head")
				if not head then
					head = v.Parent:FindFirstChild("HumanoidRootPart")
				end
				local o_pos = head.Position
				local hitIndPos = Vector3.new(head.Position.X, head.Position.Y + 0.2, head.Position.Z)

				if force ~= 0 then
					ev_DoRagdoll:Fire(hum.Parent, data.RagdollInfo.RecoveryTime, nil)
				end

				urev_HitIndicator:FireClient(packet.Owner, data.Damage, o_pos, hitIndPos, hum.Parent)
			end
		end

		if hum.Health <= 0 and hum ~= shooter_hum then
			ev_AddKill:Fire(packet.Owner)

			local plr = Players:GetPlayerFromCharacter(hum.Parent)

			if plr and math.random(1, 4) == 3 then
				ev_DropWeapon:Fire(plr)
			end
		end
	end)

	part.Parent = workspace.Debris
	Debris:AddItem(part, 20)

	if data.Emitters then
		addEmitters(data, pos)
	end
end

function fromResults(
	res: { BasePart },
	data: SharedTypes.ExplosionData,
	packet: SharedTypes.ProjectilePacket,
	cf: CFrame,
	size: Vector3
)
	local suc_hits = 0
	local already_hit = {} :: { Humanoid }
	local shooter_hum = packet.Owner.Character:FindFirstChildWhichIsA("Humanoid")

	if not shooter_hum then
		return
	end

	for _, v in pairs(res) do
		local pHum = v.Parent:FindFirstChildWhichIsA("Humanoid")

		if pHum then
			if pHum.Health <= 0 then
				continue
			end

			if table.find(already_hit, pHum) then
				continue
			end

			table.insert(already_hit, pHum)
			suc_hits += 1

			local head: BasePart = v.Parent:FindFirstChild("Head")
			local o_pos = head.Position
			if not head then
				head = v.Parent:FindFirstChild("HumanoidRootPart")
			end

			local hitIndPos = Vector3.new(head.Position.X, head.Position.Y + 0.2, head.Position.Z)

			if data.Damage ~= 0 then
				if shooter_hum == pHum and data.SelfHitRules.ApplyDamage then
					pHum:TakeDamage(data.Damage)
				elseif shooter_hum ~= pHum then
					pHum:TakeDamage(data.Damage)
					urev_HitIndicator:FireClient(packet.Owner, data.Damage, o_pos, hitIndPos, pHum.Parent)
				end

				if pHum.Health <= 0 and pHum ~= shooter_hum then
					ev_AddKill:Fire(packet.Owner)

					local plr = Players:GetPlayerFromCharacter(pHum.Parent)

					if plr and math.random(1, 4) == 3 then
						ev_DropWeapon:Fire(plr)
					end
				end
			end

			if data.RagdollInfo and data.RagdollInfo.Force then
				local force = data.RagdollInfo.Force
				local correctAxis = Vector3.new(-force.Z, force.Y, force.X)
				local relative = head.CFrame:VectorToWorldSpace(correctAxis)
				relative *= Vector3.new(1, 0, 1)
				relative += Vector3.new(0, force.Y, 0)

				if pHum == shooter_hum and data.SelfHitRules.DoRagdoll then
					ev_DoRagdoll:Fire(pHum.Parent, data.RagdollInfo.RecoveryTime, relative)
				elseif pHum ~= shooter_hum then
					ev_DoRagdoll:Fire(pHum.Parent, data.RagdollInfo.RecoveryTime, relative)
				elseif data.SelfHitRules.ApplyForce then
					pHum.Parent.HumanoidRootPart:ApplyImpulse(force)
				end
			end
		end
	end

	if isStudio then
		urev_VisualizeHitbox:FireClient(packet.Owner, cf, size, data.CastInfo.Type.Value == 1, suc_hits)
	end

	if data.Emitters then
		addEmitters(data, cf.Position)
	end
end

function addEmitters(data: SharedTypes.ExplosionData, pos: Vector3)
	for _, emitter in pairs(data.Emitters) do
		local part = Instance.fromExisting(emitterPart)
		part.Size = emitter.PartSize or Vector3.new(3, 3, 3)
		part.Position = pos

		local inst = emitter.Instance:Clone()
		inst.Parent = part
		part.Parent = workspace.Debris

		if emitter.Sound and emitter.Sound.IsLoaded then
			local clone = emitter.Sound:Clone()
			clone.Parent = part
			clone:Play()
		end

		if emitter.Delay ~= nil then
			task.delay(emitter.Delay, function()
				inst:Emit(emitter.EmitCount)
				Debris:AddItem(part, emitter.PartLifetime)
			end)
		else
			inst:Emit(emitter.EmitCount)
			Debris:AddItem(part, emitter.PartLifetime)
		end
	end
end

return module
