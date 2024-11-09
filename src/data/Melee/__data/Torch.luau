local rStore = game:GetService("ReplicatedStorage")

local SharedEnums = require(rStore.Data.SharedEnums)

return {
    MeleeName = "torch";
    BackendName = "Torch";
    CastType = {
        Type = SharedEnums.MeleeCastType.Box;
        Size = Vector3.new(3, 4, 4.5);
    };
    CentralCast = false;
    Cooldown = 1.5;
    TimeBetweenCasts = 0.05;
    NumberOfCasts = 5;
    Automatic = false;
    Damage = 6;
    RagdollInfo = {
        DoRagdoll = true;
        Force = function(unit: Vector3)
            return Vector3.new(unit.X*165, (unit.Y+1)*70, unit.Z*165)
        end;
        RecoveryTime = 0.1;
    }
}