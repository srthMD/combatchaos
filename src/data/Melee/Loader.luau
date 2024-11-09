local rStore = game:GetService("ReplicatedStorage")

local SharedTypes = require(rStore.Data.SharedType)

local dir = script.Parent.__data

return function(name: string): SharedTypes.MeleeInfo?
	if name == nil then
		return nil
	end
	
	local mod = dir:FindFirstChild(name)
	
	if mod == nil then
		error(`{name} does not have a corresponding modulescript, check the capitlization mabye?`)
	end
	
    return require(mod) :: SharedTypes.MeleeInfo
end