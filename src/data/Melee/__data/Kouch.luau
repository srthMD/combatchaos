local rStore = game:GetService("ReplicatedStorage")

local SharedEnums = require(rStore.Data.SharedEnums)

return {
    MeleeName = "killer couch";
    BackendName = "Kouch";
    CastType = {
        Type = SharedEnums.MeleeCastType.Box;
        Size = Vector3.new(7, 8, 7);
    };
    CentralCast = false;
    Cooldown = 6.5;
    TimeBetweenCasts = 0.04;
    NumberOfCasts = 7;
    Automatic = false;
    Damage = 100;
    RagdollInfo = {
        DoRagdoll = true;
        Force = function(unit: Vector3)
            local r = math.random(325, 750)
            return Vector3.new(unit.X*r, (unit.Y+1)*1150, unit.Z*r)
        end;
        RecoveryTime = 2;
    }
}