local rStore = game:GetService("ReplicatedStorage")
local sStore = game:GetService("ServerStorage")
local Stats = game:GetService("Stats")

local module = {}

local rfun_AdmStats = rStore.Signals.Remote.getStats

function onAdmStatsInvoked(plr: Player)
	if sStore.Signals.Functions.hasAdmin:Invoke(plr) then
		return {
			FPS = workspace:GetRealPhysicsFPS(),
			Memory = Stats:GetTotalMemoryUsageMb(),
			Instances = Stats.InstanceCount,
			Physics = {
				Send = Stats.PhysicsSendKbps,
				Recv = Stats.PhysicsReceiveKbps,
			},
		}
	end

	return nil
end

function module.Start()
	rfun_AdmStats.OnServerInvoke = onAdmStatsInvoked
end

return module
