local rStore = game:GetService("ReplicatedStorage")

local SharedEnums = require(rStore.Data.SharedEnums)

return {
    MeleeName = "british delight";
    BackendName = "BritishDelight";
    CastType = {
        Type = SharedEnums.MeleeCastType.Box;
        Size = Vector3.new(3.6, 4, 3);
    };
    CentralCast = false;
    Cooldown = 0.8;
    TimeBetweenCasts = 0.03;
    NumberOfCasts = 6;
    Automatic = false;
    Damage = 27;
    RagdollInfo = {
        DoRagdoll = false;
    }
}