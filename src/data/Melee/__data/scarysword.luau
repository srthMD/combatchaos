local rStore = game:GetService("ReplicatedStorage")

local SharedEnums = require(rStore.Data.SharedEnums)

return {
    MeleeName = "darksword";
    BackendName = "scarysword";
    CastType = {
        Type = SharedEnums.MeleeCastType.Box;
        Size = Vector3.new(3.5, 5.2, 4.5);
    };
    CentralCast = false;
    Cooldown = 0.35;
    TimeBetweenCasts = 0.035;
    NumberOfCasts = 7;
    Automatic = false;
    Damage = 16.8;
    RagdollInfo = {
        DoRagdoll = false;
    }
}