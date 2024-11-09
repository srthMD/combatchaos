--> Services
local Players = game:GetService("Players")
local ssServ = game:GetService("ServerScriptService")

--> Module Stuff
local module = {}

--> Variables

local sharedMods = ssServ.Server.Shared

local ACPlayer = require(sharedMods.AC.ACPlayer)
local tags = require(sharedMods.AC.Tags)

local ACPlayers = {}

--> Private Functions
function removePlayer(plr: Player)
	for i, v in pairs(ACPlayers) do
		if v.Player.Name == plr.Name then
			v:Destroy()
			table.remove(ACPlayers, i)
		end
	end
end

function getPlayer(plr: Player)
	for _, v in pairs(ACPlayers) do
		if v.Player.Name == plr.Name then
			return v
		end
	end

	return nil
end

function addPlayer(plr: Player)
	local new = ACPlayer(plr)
	table.insert(ACPlayers, new)
end

function Flag(plr: Player, category: string, tag: string)
	assert(tags[category], "Invalid category")

	local _category = tags[category]

	assert(_category[tag], "Invalid tag")

	getPlayer(plr):AddOrIncrementTag(category, tag)
end

--> Module Functions

--> Loader Functions
function module.Start()
	Players.PlayerAdded:Connect(addPlayer)

	Players.PlayerRemoving:Connect(removePlayer)

	--increment.Event:Connect(Flag)
end

return module
