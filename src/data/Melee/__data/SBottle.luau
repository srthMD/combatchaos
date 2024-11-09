local rStore = game:GetService("ReplicatedStorage")

local SharedEnums = require(rStore.Data.SharedEnums)

return {
    MeleeName = "srth's bottle";
    BackendName = "SBottle";
    CastType = {
        Type = SharedEnums.MeleeCastType.Box;
        Size = Vector3.new(4, 5, 4.3);
    };
    CentralCast = false;
    Cooldown = 3;
    TimeBetweenCasts = 0.04;
    NumberOfCasts = 13;
    Automatic = false;
    Damage = 20;
    RagdollInfo = {
        DoRagdoll = true;
        Force = function(unit: Vector3)
            local r = math.random(725, 1350)
            return Vector3.new(unit.X*r, (unit.Y+1)*-2250, unit.Z*r)
        end;
        RecoveryTime = 1.1;
    }
}