local rStore = game:GetService("ReplicatedStorage")

local SharedEnums = require(rStore.Data.SharedEnums)

return {
	MeleeName = "pitchfork";
	BackendName = "Pitchfork";
	CastType = {
		Type = SharedEnums.MeleeCastType.Box;
		Size = Vector3.new(2.8, 4, 4.9);
	};
	CentralCast = false;
	Cooldown = 1.5;
	TimeBetweenCasts = 0.03;
	NumberOfCasts = 12;
	Automatic = false;
	Damage = 15;
	RagdollInfo = {
		DoRagdoll = true;
		Force = function(unit: Vector3, ...)
			return Vector3.new(unit.X*115, (unit.Y+1)*700, unit.Z*205)
		end;
		RecoveryTime = 0.01;
	}
}