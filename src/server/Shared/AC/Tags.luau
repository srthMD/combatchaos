return {
	DefaultKickMessage = "ac kick";
	Melee = {
		OriginDifference = {
			DecayTime = 10;
			Limit = 7;
		};
		CooldownViolation = {
			DecayTime = 5,
			Limit = 5,
		};
		InstanceIsNil = {
			DecayTime = 3,
			Limit = 20,
		};
		AttackWhenDead = {
			DecayTime = 2,
			Limit = 5,
		};
		InvalidData = {
			DecayTime = nil;
			Limit = 3;
			KickMessage = "nuh Uhhhhhhhh";
			Ban = {
				0,
				12,
				7*24,
				math.huge
			}
		};
		InvalidOwner = {
			DecayTime = nil;
			Limit = 3;
			KickMessage = "nuh Uhhhhhh";
			Ban = {
				0,
				12,
				7*24,
				math.huge
			}
		};
	};

}