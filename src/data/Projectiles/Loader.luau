local rStore = game:GetService("ReplicatedStorage")

local SharedTypes = require(rStore.Data.SharedType)

local projectileModels = rStore.Assets.Projectiles
local dir = script.Parent.__data

return function(name: string): SharedTypes.ProjectileInfo?
	if name == nil then
		return nil
	end

	local mod = dir:FindFirstChild(name)

	if mod == nil then
		error(`{name} does not have a corresponding modulescript, check the capitlization mabye?`)
	end

	local data = require(mod) :: SharedTypes.ProjectileInfo
	local model = projectileModels:FindFirstChild(data.Model)
	
	if not model then
		error(`Failed to find projectile model for {name}.`)
	end
	
	local clone = table.clone(data)
	clone.Model = model

	return clone
end