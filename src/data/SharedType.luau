export type ProjectilePacket = {
	Origin: Vector3,
	Position: Vector3,
	Velocity: Vector3,
	Acceleration: Vector3,
	StartTime: number,
	Owner: Player,
	ProjectileType: string,
}

export type ProjectileInfo = {
	Velocity: number,
	Acceleration: Vector3,
	Model: Instance,
	Lifetime: number,
	UseSpherecast: boolean,
	CastRadius: number,
	BaseDamage: number,
}

export type ItemKit = {
	Melee: Tool,
	Ranged: Tool,
	Utility: Tool,
	Extra: Tool,
}

export type MeleeInfo = {
	MeleeName: string,
	BackendName: string,
	CastType: MeleeCastInfo,
	CentralCast: boolean, -- if this is true then the center of the cast will be the player's hrp
	Cooldown: number,
	NumberOfCasts: number,
	TimeBetweenCasts: number,
	Automatic: boolean,
	Damage: number | (...any) -> number,
	RagdollInfo: RagdollInfo,
}

export type MeleePacket = {
	Origin: CFrame, -- from client, cannot be trusted
	ClientTime: number, -- acts as action id
	Owner: Player,
	MeleeType: string, -- should check on server if the player has the melee equiped
}

export type MeleeCastInfo = {
	Type: MeleeCastType,
	Size: Vector3 | number,
}

export type MeleeCastType = {
	Value: number,
	Name: string,
}

export type RagdollInfo = {
	DoRagdoll: boolean,
	Force: ((Vector3) -> Vector3) | Vector3,
	RecoveryTime: number,
}

export type VoteDict = {
	[string]: { VoteEntry },
}

export type VoteEntry = {
	player: Player,
	clickPos: UDim2,
}

return {}
