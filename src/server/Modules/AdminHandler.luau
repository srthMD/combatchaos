-- @title: Server Projectile Handler
-- @author: qweekertom
-- @date: 2.29.2024

--> Services
local rStore = game:GetService("ReplicatedStorage")
local sStore = game:GetService("ServerStorage")
local Players = game:GetService("Players")
local dsService = game:GetService("DataStoreService")
local ssServ = game:GetService("ServerScriptService")

--> Variables
local module = {}
local signals = {}
local isStudio = game:GetService("RunService"):IsStudio()

local funcModule = require(ssServ.Server.Shared.Admin.Functions)
local allowed = funcModule.allowed -- shared table

local ui = sStore.Assets.Admin.Lah
local button = rStore.Assets.Admin.plrbutton

local admDs = dsService:GetDataStore("ADM")

local remoteFunc = sStore.Signals.Functions.ad
local s_hasAdmin = sStore.Signals.Functions.hasAdmin
local hasAdmin = rStore.Signals.Remote.isAdmin
local getCommands = rStore.Signals.Remote.getCommands

--> Private Functions
function onPlayerAdd(plr: Player): ()
	local ds

	if isStudio then
		ds = true
	else
		local suc, has = pcall(function()
			return admDs:GetAsync(plr.UserId)
		end)

		ds = has

		if not suc then
			ds = false
		end

		if ds == nil then
			pcall(function()
				admDs:SetAsync(plr.UserId, false)
			end)
		end
	end

	if ds then
		table.insert(allowed, plr.UserId)

		remoteFunc:Invoke(plr)
		local clone = ui:Clone()
		clone.Parent = plr.PlayerGui
		clone.addbuttons.Enabled = true

		for _, player in pairs(game.Players:GetPlayers()) do
			local suc, plrHasAdmin = pcall(function()
				print("getasync")
				return admDs:GetAsync(player.UserId)
			end)

			if not suc then
				plrHasAdmin = false
			end

			local clonedbutton = button:Clone()

			if plrHasAdmin then
				clonedbutton.BackgroundColor3 = Color3.fromRGB(65, 37, 37)
			end

			clonedbutton.Parent = clone.sframe
			clonedbutton.plr.Value = player
			clonedbutton.Text = player.Name
			clonedbutton.LocalScript.Enabled = true
			clonedbutton.Name = plr.Name
		end
	end
end

function initEvents(): Folder
	local remFolder = Instance.new("Folder")
	remFolder.Parent = rStore.Signals
	remFolder.Name = "admevents"

	for name: string, func in pairs(funcModule.events.player) do
		local rEvnt = Instance.new("RemoteEvent")
		rEvnt.Name = insertSpaces(name)
		rEvnt.Parent = remFolder
		rEvnt:SetAttribute("isPlayer", true)

		table.insert(
			signals,
			rEvnt.OnServerEvent:Connect(function(plr, target, clientArgs: { any })
				handleEvent(string.gsub(rEvnt.Name, " ", ""), plr, target, clientArgs)
			end)
		)
	end

	for name: string, func in pairs(funcModule.events.server) do
		local rEvnt = Instance.new("RemoteEvent")
		rEvnt.Name = insertSpaces(name)
		rEvnt.Parent = remFolder
		rEvnt:SetAttribute("isPlayer", false)

		table.insert(
			signals,
			rEvnt.OnServerEvent:Connect(function(plr, target, clientArgs: { any })
				handleEvent(string.gsub(rEvnt.Name, " ", ""), plr, target, clientArgs)
			end)
		)
	end

	return remFolder
end

function handleEvent(name: string, plr: Player, target: Player, clientArgs: { any }): ()
	if target == nil then
		return
	end

	local sanitized = sanitize(plr, clientArgs, name)

	if not sanitized then
		return
	end

	local func = funcModule.events.player[name] or funcModule.events.server[name]

	print(`{plr.Name} ran command {name} with target {target.Name}`)
	if func then
		task.spawn(func, target, clientArgs)
	end
end

function sanitize(plr: Player, clientArgs: { any }, name: string): boolean
	if isStudio then
		return true
	end

	return table.find(funcModule.allowed, plr.UserId) ~= nil

	--local paramArr = funcModule.paramTypes[name]
	--if paramArr == nil then return false end

	--for i, typ in pairs(paramArr) do
	--	if typeof(clientArgs[i]) ~= typ then
	--		return false
	--	end
	--end
end

function insertSpaces(str: string): string
	local finalStr = ""

	for i, c in pairs(string.split(str, "")) do
		if i == 1 then
			finalStr ..= c
			continue
		end

		if str.upper(c) == c then
			finalStr ..= " " .. c
		else
			finalStr ..= c
		end
	end

	return finalStr
end

--> Module Functions

--> Loader Methods
function module.Start()
	remoteFunc.OnInvoke = function(plr: Player)
		return funcModule.Init(plr)
	end

	hasAdmin.OnServerInvoke = function(plr: Player)
		return table.find(funcModule.allowed, plr.UserId)
	end

	s_hasAdmin.OnInvoke = function(plr: Player)
		return table.find(funcModule.allowed, plr.UserId)
	end

	rStore.Signals.Remote.requestItems.OnServerInvoke = function()
		local t = {}

		for _, item in pairs(funcModule.items) do
			table.insert(t, item.Name)
		end

		return t
	end

	getCommands.OnServerInvoke = function(plr: Player)
		if table.find(funcModule.allowed, plr.UserId) then
			local t = {}

			for _, v in pairs(funcModule.events.player) do
				table.insert(t, v)
			end

			return t
		end

		return nil
	end

	initEvents()

	Players.PlayerAdded:Connect(onPlayerAdd)
end

return module
