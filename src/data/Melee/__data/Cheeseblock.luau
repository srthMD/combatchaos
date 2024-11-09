local rStore = game:GetService("ReplicatedStorage")

local SharedEnums = require(rStore.Data.SharedEnums)

return {
    MeleeName = "173";
    BackendName = "Cheeseblock";
    CastType = {
        Type = SharedEnums.MeleeCastType.Box;
        Size = Vector3.new(5, 5, 5);
    };
    CentralCast = false;
    Cooldown = 3;
    TimeBetweenCasts = 0.05;
    NumberOfCasts = 20;
    Automatic = false;
    Damage = 17.3;
    RagdollInfo = {
        DoRagdoll = true;
        Force = function(unit: Vector3)
            return Vector3.new(unit.X*165, (unit.Y+1)*70, unit.Z*165)
        end;
        RecoveryTime = 0.2;
    }
}