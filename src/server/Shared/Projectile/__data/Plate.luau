local rStore = game:GetService("ReplicatedStorage")
local sStore = game:GetService("ServerStorage")

local SharedType = require(rStore.Data.SharedType)
local Projectiles = require(rStore.Data.Projectiles)

local urev_HitIndicator = rStore.Signals.Remote.Unreliable.HitIndicator
local ev_AddKill = sStore.Signals.Event.AddKill

local plateDeps = rStore.Assets.ItemDeps.Plate

return {
	Spawn = function(packet: SharedType.ProjectilePacket)
		local throw: Sound = plateDeps.Throw:Clone()

		local char = packet.Owner.Character

		if char then
			throw.Parent = char:FindFirstChild("HumanoidRootPart")
			throw:Play()

			task.spawn(function()
				throw.Ended:Wait()
				throw:Destroy()
			end)
		end
	end,

	Hit = function(packet: SharedType.ProjectilePacket, rcr: RaycastResult)
		local hit = rcr.Instance
		local info = Projectiles[packet.ProjectileType]

		local pHum: Humanoid = hit.Parent:FindFirstChildOfClass("Humanoid")
		local baseDamage = info.BaseDamage

		if pHum and pHum.Health > 0 then
			pHum:TakeDamage(baseDamage)
			urev_HitIndicator:FireClient(packet.Owner, baseDamage, pHum.Parent.Head.Position, nil, pHum.Parent)

			if pHum.Health <= 0 then
				ev_AddKill:Fire(packet.Owner)
			end
		end

		local breakSound: Sound = plateDeps.Break:Clone()

		local p = Instance.new("Part")
		p.Size = Vector3.one
		p.Transparency = 1
		p.Massless = true
		p.Anchored = true
		p.CanTouch = false
		p.CanQuery = false
		p.CanCollide = false
		p.Position = rcr.Position

		breakSound.Parent = p
		p.Parent = workspace

		breakSound:Play()

		for i = 0, 20, 1 do
			local shard = Instance.new("Part")
			shard.Parent = workspace
			shard.Position = rcr.Position
			shard.Size = Vector3.new(0.2, 0.2, 0.2)
			shard.Color = Color3.fromRGB(255, 255, 255)
			shard.CanCollide = true
			shard.CanTouch = true

			task.defer(function()
				shard:ApplyImpulse(Vector3.new(math.random(-1, 1), math.random(-1, 1), math.random(-1, 1)))
			end)

			local db = false

			task.delay(0.3, function()
				c = shard.Touched:Connect(function(other)
					if not db then
						db = true

						local pHum: Humanoid = other.Parent:FindFirstChild("Humanoid")

						if pHum then
							pHum:TakeDamage(2.5)
						end

						task.delay(2, function()
							db = false
						end)
					end
				end)
			end)

			task.delay(8, function()
				c:Disconnect()
				shard:Destroy()
			end)
		end

		task.spawn(function()
			breakSound.Ended:Wait()
			p:Destroy()
		end)
	end,
}
