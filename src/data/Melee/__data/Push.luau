local rStore = game:GetService("ReplicatedStorage")

local SharedEnums = require(rStore.Data.SharedEnums)

return {
    MeleeName = "push";
    BackendName = "Push";
    CastType = {
        Type = SharedEnums.MeleeCastType.Box;
        Size = Vector3.new(4, 5, 6);
    };
    CentralCast = false;
    Cooldown = 8.5;
    TimeBetweenCasts = 0.05;
    NumberOfCasts = 18;
    Automatic = false;
    Damage = 12.57;
    RagdollInfo = {
        DoRagdoll = true;
        Force = function(unit: Vector3)
            return Vector3.new(unit.X*165, (unit.Y+1)*70, unit.Z*165)
        end;
        RecoveryTime = 2.25;
    }
}