local rStore = game:GetService("ReplicatedStorage")

local SharedEnums = require(rStore.Data.SharedEnums)

return {
    MeleeName = "flashlight";
    BackendName = "Light";
    CastType = {
        Type = SharedEnums.MeleeCastType.Box;
        Size = Vector3.new(4, 5, 4.7);
    };
    CentralCast = false;
    Cooldown = 1.1;
    TimeBetweenCasts = 0.05;
    NumberOfCasts = 6;
    Automatic = false;
    Damage = 4.5;
    RagdollInfo = {
        DoRagdoll = true;
        Force = function(unit: Vector3)
            return Vector3.new(unit.X*125, (unit.Y+1)*50, unit.Z*125)
        end;
        RecoveryTime = 0.14;
    }
}