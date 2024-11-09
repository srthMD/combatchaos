local rStore = game:GetService("ReplicatedStorage")

local SharedEnums = require(rStore.Data.SharedEnums)

return {
    MeleeName = "plumbers wrench";
    BackendName = "Plumberwrench";
    CastType = {
        Type = SharedEnums.MeleeCastType.Box;
        Size = Vector3.new(6.1, 5, 5);
    };
    CentralCast = false;
    Cooldown = 1.3;
    TimeBetweenCasts = 0.06;
    NumberOfCasts = 9;
    Automatic = false;
    Damage = 28;
    RagdollInfo = {
        DoRagdoll = false;
    }
}