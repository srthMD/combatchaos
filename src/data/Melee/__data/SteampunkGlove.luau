local rStore = game:GetService("ReplicatedStorage")

local SharedEnums = require(rStore.Data.SharedEnums)

return {
    MeleeName = "steampunkglove";
    BackendName = "SteampunkGlove";
    CastType = {
        Type = SharedEnums.MeleeCastType.Box;
        Size = Vector3.new(4.7, 5, 5);
    };
    CentralCast = false;
    Cooldown = 4.6;
    TimeBetweenCasts = 0.05;
    NumberOfCasts = 12;
    Automatic = false;
    Damage = 35;
    RagdollInfo = {
        DoRagdoll = true;
        Force = function(unit: Vector3)
            return Vector3.new(unit.X*1500, (unit.Y+1)*200, unit.Z*1500)
        end;
        RecoveryTime = 1.15;
    }
}