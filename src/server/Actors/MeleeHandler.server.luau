--this is me like 1 year later i have no idea why i put this into an actor

local rStore = game:GetService("ReplicatedStorage")
local sStore = game:GetService("ServerStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local isStudio = RunService:IsStudio()

local eventFolder = rStore.Signals.Remote
local serverEventFolder = sStore.Signals.Event

local urev_VisualizeHitbox = eventFolder.Unreliable.VisualizeHitbox
local urev_HitIndicator = eventFolder.Unreliable.HitIndicator
local ev_DoRagdoll = serverEventFolder.DoRagdoll
local ev_OnHit = serverEventFolder.OnHitMelee
local ev_OnAttack = serverEventFolder.OnAttackMelee
local ev_KillEvent = serverEventFolder.AddKill
local ev_DropWeapon = serverEventFolder.DropWeapon

local SharedTypes = require(rStore.Data.SharedType)

local ACIncrement = sStore.Signals.AC.AddOrIncrement

local Melees = require(rStore.Data.Melee.Loader)

local actor = script:GetActor()

--what percent of the player's linear velocity is contributed to hitbox extension
--eg a forward velocity of 10 and a factor of 30 percent extends the hitbox by 3 studs forward
local PERCENT_VELOCITY_COMPENCATION = 0.60

--how much percent the hitbox can extend relative to its original size
--for example 50 percent means that the hitbox can only be extended an extra 50 percent of its og size
local PERCENT_MAX_HITBOX_EXTENSION = 0.7

function originIsAcceptable(origin: CFrame, hrpCFrame: CFrame): boolean
	if math.abs((origin.Position - hrpCFrame.Position).Magnitude) > 5 then
		return false
	end

	return true
end

function validate(plr: Player, packet: SharedTypes.MeleePacket)
	local meleeData = Melees(packet.MeleeType)
	local packetOwner = packet.Owner

	if not meleeData then
		ACIncrement:Fire(plr, "Melee", "InvalidData")
		return
	end

	if packetOwner ~= plr then
		ACIncrement:Fire(plr, "Melee", "InvalidOwner")
		return
	end

	local char = plr.Character
	if not char then
		ACIncrement:Fire(plr, "Melee", "InstanceIsNil")
		return
	end

	local pHum = char:FindFirstChildWhichIsA("Humanoid")
	if not pHum then
		ACIncrement:Fire(plr, "Melee", "InstanceIsNil")
		return
	end

	if pHum.Health == 0 then
		ACIncrement:Fire(plr, "Melee", "AttackWhenDead")
	end

	local hrp: BasePart = char:FindFirstChild("HumanoidRootPart")
	if not hrp then
		return
	end

	if not originIsAcceptable(packet.Origin, hrp.CFrame) then
		ACIncrement:Fire(plr, "Melee", "OriginDifference")
	end

	doCasts(packet, meleeData)
end

function doCasts(packet: SharedTypes.MeleePacket, data: SharedTypes.MeleeInfo)
	local char = packet.Owner.Character
	local hrp: BasePart = char:FindFirstChild("HumanoidRootPart")
	local tool = char:FindFirstChild(data.MeleeName)

	local CastParams = OverlapParams.new()
	CastParams.FilterType = Enum.RaycastFilterType.Exclude
	CastParams.RespectCanCollide = false
	CastParams.FilterDescendantsInstances = { char, workspace.MainMap }
	local size = data.CastType.Size

	local cf: CFrame

	local validHits = 0

	ev_OnAttack:Fire(data.BackendName, tool, packet["Sound"] or nil)

	for i = 1, data.NumberOfCasts do
		task.desynchronize()

		tool = char:FindFirstChild(data.MeleeName)
		if not tool then
			break
		end

		local adjustedSize = size

		if data.CentralCast then
			cf = hrp.CFrame
		else
			if data.CastType.Type.Value == 1 then
				cf = hrp.CFrame * CFrame.new(Vector3.new(0, 0, (-size / 2) - 0.5))
			else
				local localVelocity = hrp.CFrame:VectorToObjectSpace(hrp.AssemblyLinearVelocity)
				local limit = size * PERCENT_MAX_HITBOX_EXTENSION
				adjustedSize += (localVelocity * Vector3.zAxis * -PERCENT_VELOCITY_COMPENCATION):Min(limit):Max(-limit)
				cf = hrp.CFrame * CFrame.new(Vector3.new(0, 0, (-adjustedSize.Z / 2) - 0.5))
			end
		end

		local result: { Instance }

		if data.CastType.Type.Value == 0 then
			result = workspace:GetPartBoundsInBox(cf, adjustedSize, CastParams)
		else
			result = workspace:GetPartBoundsInRadius(cf.Position, size.Magnitude, CastParams)
		end

		for _, v in pairs(result) do
			local pHum = v.Parent:FindFirstChildWhichIsA("Humanoid")

			if pHum then
				if pHum.Health <= 0 then
					continue
				end

				if pHum:HasTag(packet.Time) then
					continue
				end

				validHits += 1

				local head: BasePart = v.Parent:FindFirstChild("Head")
				local o_pos = head.Position
				if not head then
					head = v.Parent:FindFirstChild("HumanoidRootPart")
				end

				local hitIndPos = Vector3.new(head.Position.X, head.Position.Y + 0.2, head.Position.Z)

				local force = data.RagdollInfo.Force
				if type(force) == "function" then
					if data.CastType.Type.Value == 1 then
						force = force((head.Position - hrp.Position).Unit)
					else
						force = force(cf.LookVector.Unit)
					end
				end

				task.synchronize()

				ev_OnHit:Fire(data.BackendName, pHum, tool)
				
				if not data.DoNotTag then
					pHum:AddTag(packet.Time)
				end
				
				local dmg: number
				local damageType = typeof(data.Damage)

				if typeof(data.Damage) == "function" then
					dmg = data.Damage()
				elseif damageType == "number" then
					dmg = data.Damage
				else
					warn(
						`Weapon data {data.MeleeName} has invalid damage data, number or function expected, got {damageType}.`
					)
					return
				end

				if isStudio then
					print(`Hit {pHum.Parent.Name} with {data.MeleeName} for {dmg} dmg`)
				end
				pHum:TakeDamage(dmg)

				if pHum.Health <= 0 then
					ev_KillEvent:Fire(packet.Owner)
					
					local plr = Players:GetPlayerFromCharacter(pHum.Parent)
					
					if plr and math.random(1, 4) == 3 then
						ev_DropWeapon:Fire(plr)
					end
				end

				urev_HitIndicator:FireClient(packet.Owner, dmg, o_pos, hitIndPos, pHum.Parent)

				if data.RagdollInfo.DoRagdoll then
					ev_DoRagdoll:Fire(pHum.Parent, data.RagdollInfo.RecoveryTime, force)
				end
			end
		end

		task.synchronize()

		if isStudio then
			urev_VisualizeHitbox:FireClient(packet.Owner, cf, adjustedSize, data.CastType.Type.Value == 1, validHits)
		end

		task.wait(data.TimeBetweenCasts)
	end
end

actor:BindToMessage("MeleeCast", validate)
