local rStore = game:GetService("ReplicatedStorage")

local SharedEnums = require(rStore.Data.SharedEnums)

return {
	MeleeName = "dr. reflex's hammer";
	BackendName = "DrreflexHammer";
	CastType = {
		Type = SharedEnums.MeleeCastType.Box;
		Size = Vector3.new(2, 5, 5.3);
	};
	CentralCast = false;
	Cooldown = 0.17;
	TimeBetweenCasts = 0.035;
	NumberOfCasts = 6;
	Automatic = false;
	Damage = 9;
	RagdollInfo = {
		DoRagdoll = false;
		Force = function(unit: Vector3)
			return Vector3.new(0, -((unit.Y + 1) * 500), 0)
		end;
		RecoveryTime = 0;
	}
}
