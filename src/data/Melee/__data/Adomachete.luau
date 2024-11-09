local rStore = game:GetService("ReplicatedStorage")

local SharedEnums = require(rStore.Data.SharedEnums)

return {
    MeleeName = "adomachete";
    BackendName = "Adomachete";
    CastType = {
        Type = SharedEnums.MeleeCastType.Box;
        Size = Vector3.new(3.75, 5, 5.5);
    };
    CentralCast = false;
    Cooldown = 4;
    TimeBetweenCasts = 0.05;
    NumberOfCasts = 17;
    Automatic = false;
    Damage = 33.55;
    RagdollInfo = {
        DoRagdoll = true;
        Force = function(unit: Vector3)
            return Vector3.new(unit.X*165, (unit.Y+1)*70, unit.Z*165)
        end;
        RecoveryTime = 1.7;
    }
}