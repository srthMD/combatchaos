--> Services
local rStore = game:GetService("ReplicatedStorage")
local stReg = game:GetService("SharedTableRegistry")
local Players = game:GetService("Players")

local plrRemovedEvent = rStore.Signals.Remote.PlayerRemoved

--> Variables
local module = {}

--> Private Functions
function initTables()
	local t = {}

	for _, v in pairs(Players:GetPlayers()) do
		t[v.Name] = v
	end

	stReg:SetSharedTable("Players", SharedTable.new(t))
end

function updatePlayerSharedTable(plr: Player)
	local t = stReg:GetSharedTable("Players")

	if not t then
		return
	end

	t[plr.Name] = true
end

function updatePlayerSharedTableLeave(plr: Player)
	plrRemovedEvent:FireAllClients(plr.Name)

	local t = stReg:GetSharedTable("Players")

	if not t then
		return
	end

	t[plr.Name] = nil
end

--> Module Functions

--> Loader Methods
function module.Start()
	initTables()

	Players.PlayerAdded:Connect(updatePlayerSharedTable)

	Players.PlayerRemoving:Connect(updatePlayerSharedTableLeave)
end

return module
