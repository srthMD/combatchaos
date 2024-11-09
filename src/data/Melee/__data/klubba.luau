local rStore = game:GetService("ReplicatedStorage")

local SharedEnums = require(rStore.Data.SharedEnums)

return {
	MeleeName = "innebandy klubba";
    BackendName = "klubba";
    CastType = {
        Type = SharedEnums.MeleeCastType.Box;
        Size = Vector3.new(4.2, 5, 4.7);
    };
    CentralCast = false;
    Cooldown = 0.8;
    TimeBetweenCasts = 0.04;
    NumberOfCasts = 8;
    Automatic = false;
    Damage = 19;
    RagdollInfo = {
        DoRagdoll = false;
    }
}