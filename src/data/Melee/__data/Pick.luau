local rStore = game:GetService("ReplicatedStorage")

local SharedEnums = require(rStore.Data.SharedEnums)

return {
    MeleeName = "pickaxe";
    BackendName = "Pick";
    CastType = {
        Type = SharedEnums.MeleeCastType.Box;
        Size = Vector3.new(3.8, 5.2, 4.5);
    };
    CentralCast = false;
    Cooldown = 0.7;
    TimeBetweenCasts = 0.035;
    NumberOfCasts = 9;
    Automatic = false;
    Damage = 28;
    RagdollInfo = {
        DoRagdoll = false;
    }
}