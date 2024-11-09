local rStore = game:GetService("ReplicatedStorage")

local SharedEnums = require(rStore.Data.SharedEnums)

return {
    MeleeName = "rarest sword";
    BackendName = "Supersword";
    CastType = {
        Type = SharedEnums.MeleeCastType.Box;
        Size = Vector3.new(7,7, 7);
    };
    CentralCast = false;
    Cooldown = 0.7;
    TimeBetweenCasts = 0.07;
    NumberOfCasts = 7;
    Automatic = false;
    Damage = 77.7;
    RagdollInfo = {
        DoRagdoll = true;
        Force = function(unit: Vector3)
            return Vector3.new(unit.X*777, (unit.Y+1)*777, unit.Z*777)
        end;
        RecoveryTime = 0.777;
    }
}