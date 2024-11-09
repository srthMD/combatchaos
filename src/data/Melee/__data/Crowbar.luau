local rStore = game:GetService("ReplicatedStorage")

local SharedEnums = require(rStore.Data.SharedEnums)

return {
    MeleeName = "crowbar";
    BackendName = "Crowbar";
    CastType = {
        Type = SharedEnums.MeleeCastType.Box;
        Size = Vector3.new(4.2, 5, 5);
    };
    CentralCast = false;
    Cooldown = 0.45;
    TimeBetweenCasts = 0.04;
    NumberOfCasts = 8;
    Automatic = false;
    Damage = 20;
    RagdollInfo = {
        DoRagdoll = false;
    }
}