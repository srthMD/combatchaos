local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local Loader = require(ReplicatedStorage.Packages.Loader)

Loader.SpawnAll(
	Loader.LoadChildren(ServerStorage.Server.Modules, function(module: ModuleScript): boolean
		local attr = module:GetAttribute("Load")

		--do this instead of return attr to handle when the attribute is nil
		if attr == false then
			return false
		end

		return true
	end),
	"Start"
)

--TODO: change this to not load any extension components when i ever make one
Loader.LoadDescendants(ServerStorage.Server.Component)
