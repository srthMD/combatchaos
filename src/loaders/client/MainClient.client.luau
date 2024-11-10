local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Loader = require(ReplicatedStorage.Packages.Loader)

Loader.SpawnAll(
	Loader.LoadDescendants(ReplicatedStorage.Client, function(module: ModuleScript): boolean
		if module:IsDescendantOf(ReplicatedStorage.Client.StaticInterface) then
			return false
		end

		if module:IsDescendantOf(ReplicatedStorage.Client.Component.AbstractComponents) then
			return false
		end

		local attr = module:GetAttribute("Load")

		if attr == false then
			return false
		end

		return true
	end),
	"Start"
)
