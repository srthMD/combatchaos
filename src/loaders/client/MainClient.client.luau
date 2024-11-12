local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Loader = require(ReplicatedStorage.Packages.Loader)

Loader.SpawnAll(
	Loader.LoadChildren(ReplicatedStorage.Client.Modules, function(module: ModuleScript): boolean
		local attr = module:GetAttribute("Load")

		--do this instead of return attr to handle when the attribute is nil
		if attr == false then
			return false
		end

		return true
	end),
	"Start"
)

Loader.LoadDescendants(ReplicatedStorage.Client.Component, function(module: ModuleScript): boolean
	return not module:IsDescendantOf(ReplicatedStorage.Client.Component.AbstractComponents)
end)
