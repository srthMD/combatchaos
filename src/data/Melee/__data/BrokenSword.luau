local rStore = game:GetService("ReplicatedStorage")

local SharedEnums = require(rStore.Data.SharedEnums)

return {
	MeleeName = "broken sword",
	BackendName = "BrokenSword",
	CastType = {
		Type = SharedEnums.MeleeCastType.Box,
		Size = Vector3.new(4, 5, 4.5),
	},
	CentralCast = false,
	Cooldown = 0.4,
	TimeBetweenCasts = 0.03,
	NumberOfCasts = 8,
	Automatic = false,
	Damage = function(...)
		local x = math.random(-6, 6)
		local b = 20

		return math.abs(b * math.cos(x) + math.sin(b / x) * math.pow(x, 2))
	end,
	RagdollInfo = {
		DoRagdoll = false,
	},
}
