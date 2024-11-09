local rStore = game:GetService("ReplicatedStorage")

local SharedEnums = require(rStore.Data.SharedEnums)

return {
    MeleeName = "viking axe";
    BackendName = "Axe";
    CastType = {
        Type = SharedEnums.MeleeCastType.Box;
        Size = Vector3.new(4, 5.5, 5.2);
    };
    CentralCast = false;
    Cooldown = 4.7;
    TimeBetweenCasts = 0.04;
    NumberOfCasts = 16;
    Automatic = false;
    Damage = 40;
    RagdollInfo = {
        DoRagdoll = true;
        Force = function(unit: Vector3)
            return Vector3.new(unit.X*700, (unit.Y+1)*300, unit.Z*100)
        end;
        RecoveryTime = 0.5;
    }
}