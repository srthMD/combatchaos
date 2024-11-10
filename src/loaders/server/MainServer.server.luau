local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local Loader = require(ReplicatedStorage.Packages.Loader)

Loader.SpawnAll(
	Loader.LoadDescendants(ServerStorage.Server, function(module: ModuleScript): boolean
		if module:IsDescendantOf(ServerStorage.Server.Shared) then
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
