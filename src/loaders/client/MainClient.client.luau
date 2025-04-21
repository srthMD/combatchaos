local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Loader = require(ReplicatedStorage.Packages.Loader)

Loader.SpawnAll(
	Loader.LoadChildren(ReplicatedStorage.Client.Modules, function(module: ModuleScript): boolean
		local attr = module:GetAttribute("Load")

		if not attr then
			return false
		end

		return true
	end),
	"Start"
)

Loader.LoadDescendants(ReplicatedStorage.Client.Component, function(module: ModuleScript): boolean
	return not module:IsDescendantOf(ReplicatedStorage.Client.Component.AbstractComponents)
end)
