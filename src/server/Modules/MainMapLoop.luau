--> Services
local rStore = game:GetService("ReplicatedStorage")
local sStore = game:GetService("ServerStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CollectionService = game:GetService("CollectionService")
local PhysicsService = game:GetService("PhysicsService")
local MarketplaceService = game:GetService("MarketplaceService")

local SharedTypes = require(rStore.Data.SharedType)

--> Variables
local votingTime = sStore.VotingTime

local module = {}

local terrain = workspace.Terrain
local mapfolder = workspace:WaitForChild("MainMap")

local evnt = rStore.Signals.Remote.OnMapChange
local votingEvents = rStore.Signals.Remote.Voting
local mapChangedEvent = sStore.Signals.Event.MapChanged
local sendTime = rStore.Signals.Remote.Unreliable.SendTime
local votingEffectEvent = rStore.Signals.Remote.Unreliable.VotingEffect

local playing = sStore.Playing

local rand = Random.new(os.time())

local mapFolder = sStore.Assets.Maps
local maps = mapFolder:GetChildren()

local lobbyFolder = sStore.Assets.Lobbies
local lobbies = lobbyFolder:GetChildren()

local lobbyData = rStore.Data.Lobbies

local forcedMap = nil

if RunService:IsStudio() then
	forcedMap = nil
end

local panGP = 1157645416

--> Private Functions
local function newVoteDict(maps: { string }): SharedTypes.VoteDict
	local voteDict = {} :: SharedTypes.VoteDict

	for _, map in pairs(maps) do
		voteDict[map] = {}
	end

	return voteDict
end

local function cleanUp(isLobby: boolean?)
	if not isLobby then
		playing.Value = false
		rand:Shuffle(maps)
	else
		rand:Shuffle(lobbies)
	end

	terrain:Clear()
	mapfolder:ClearAllChildren()

	if workspace:FindFirstChild("Fragmentable") then
		workspace.Fragmentable:Destroy()
	end

	workspace.Debris:ClearAllChildren()
end

local function pickRandomMaps(len: number): { string }
	local mapTbl: { string } = {}

	repeat
		local map = maps[math.random(1, #maps)]

		if table.find(mapTbl, map.Name) then
			continue
		end

		table.insert(mapTbl, map.Name)
	until #mapTbl >= len

	return mapTbl
end

local function onRecvVote(recvPlr: Player, map: string, pos: UDim2)
	votingEvents.VoteRecv:FireAllClients(recvPlr, map, pos)
end

local function getEntry(dict: SharedTypes.VoteDict, plr: Player): (SharedTypes.VoteEntry?, string?, number?)
	for map, v in pairs(dict) do
		for i = 1, #v, 1 do
			local entry = v[i]

			if entry.player == plr then
				return entry, map, i
			end
		end
	end

	return nil, nil, nil
end

local function initVoting(maps: { string }, seconds: number): (SharedTypes.VoteDict, RBXScriptConnection)
	votingEvents.VoteStart:FireAllClients(maps, nil, seconds, os.time())

	local voteDict = newVoteDict(maps)

	local voteCon = votingEvents.VoteSubmitted.OnServerEvent:Connect(function(plr: Player, map: string, pos: UDim2)
		if typeof(map) ~= "string" then
			warn(`{map} is not a valid map.`)
			warn(debug.traceback())
			return
		end

		local posType = typeof(pos)
		if posType ~= "UDim2" then
			warn(`Expected UDim2, got {posType}.`)
			warn(debug.traceback())
			return
		end

		local entry, prevMap, idx = getEntry(voteDict, plr)

		if entry then
			if map == prevMap then
				entry.clickPos = pos
			else
				table.remove(voteDict[prevMap], idx)
				table.insert(voteDict[map], { player = plr, clickPos = pos })
			end
		else
			table.insert(voteDict[map], { player = plr, clickPos = pos })
		end

		onRecvVote(plr, map, pos)
	end)

	return voteDict, voteCon
end

local function endVoting(chosenMap: string)
	votingEvents.VoteEnd:FireAllClients(chosenMap)
end

local function vote(): string
	local pickedMaps = pickRandomMaps(math.random(3, 5))
	local voteDict, con = initVoting(pickedMaps, votingTime.Value)

	local voteStartTime = os.time()

	local plrCon = Players.PlayerAdded:Connect(function(p)
		votingEvents.VoteStart:FireClient(
			p,
			nil,
			voteDict,
			(voteStartTime - os.time()) + votingTime.Value,
			os.time()
		)
	end)

	task.wait(votingTime.Value)

	con:Disconnect()
	plrCon:Disconnect()

	local max = 0
	local maxMaps = {}
	local chosenMap: string

	local freq: { [string]: number } = {}

	for map, plrs in pairs(voteDict) do
		local voteCount = #plrs

		freq[map] = voteCount

		if voteCount > max then
			max = voteCount
		end
	end

	--nobody voted
	if max == 0 then
		chosenMap = pickedMaps[math.random(1, #pickedMaps)]
	else
		for map, votes in pairs(freq) do
			if votes == max then
				table.insert(maxMaps, map)
			end
		end

		if #maxMaps == 1 then
			chosenMap = maxMaps[1]
		else
			chosenMap = maxMaps[math.random(1, #maxMaps)]
		end
	end

	return chosenMap
end

--Sets the text and image for a map's surfacegui
local function initMapButtonUI(ui: SurfaceGui, map: string)
	local main: CanvasGroup = ui.Main
	local data = rStore.Data.Maps[map]
	
	if not data then
		error(`No map data for map {map}.`)
	end
	
	main.MapName.Text = map
	main.MapImage.Image = data.Image.Value
	main.NumVotes.Text = '0'
end

--Counts how many votes a certian map has recived
local function countVotes(dict: {[Player]: string?}, map: string): number
	local votes = 0
	
	for p, name in dict do
		if name == nil then
			continue
		end
		
		if name == map then
			votes += 1
		end
	end
	
	return votes
end

local function updateCounts(dict: {[Player]: string?}, buttons: {Model})
	local freq: {[string]: number} = {}
	
	for p, name in dict do
		if name == nil then
			continue
		end
		
		if not freq[name] then
			freq[name] = 1
		else
			freq[name] += 1
		end
	end
	
	for _, mdl in pairs(buttons) do
		local map = mdl:GetAttribute("Map")
		
		local count = freq[map]
		
		if not count then
			count = 0
		end
		
		local gui: SurfaceGui = mdl.UI:FindFirstChildWhichIsA("SurfaceGui")
		local text: TextLabel = gui.Main.NumVotes
		local str = tostring(count)
		local lower = string.lower(str)
		if not (lower == "nan" or lower == "nil") then
			text.Text = str
		else
			warn(`NaN or nil value: {str}\n {debug.traceback()}`)
		end
	end
end

local function mapLoop(): never
	while true do
		playing.Value = false

		cleanUp()
		
		PhysicsService:CollisionGroupSetCollidable("Players", "Players", false)

		if #Players:GetPlayers() == 0 then
			Players.PlayerAdded:Wait()
		end
		
		--this code is horrible but this is cc so i dont care
		--to anybody else or future me debugging good luck
		local chosenLobby = lobbies[math.random(1, #lobbies)]:Clone()
		chosenLobby.Parent = workspace.MainMap
		local lData = require(lobbyData[chosenLobby.Name].LobbyData)
		
		evnt:FireAllClients(chosenLobby.Name, true)
		
		local allButtons = CollectionService:GetTagged("LobbyMapButton")
		local buttons: {Model} = {}
		
		for _, mdl in pairs(allButtons) do
			if mdl:IsDescendantOf(workspace.MainMap) then
				if mdl:FindFirstChild("UI") and mdl:FindFirstChild("Button") then
					table.insert(buttons, mdl)
				else
					warn(`Skipping button in lobby {chosenLobby.Name} because it does not have UI or Button part.`)
				end
			end
		end
		
		local buttonCons: {RBXScriptConnection} = {}
		
		local pickedMaps = pickRandomMaps(#buttons)
		local playerVotes: {[Player]: string?} = {}
		
		--explicitly set to nil because it makes me feel better :)
		for _, plr in pairs(Players:GetPlayers()) do
			playerVotes[plr] = nil
		end
		
		evnt:FireAllClients(chosenLobby.Name, true)
		
		--this code is kinda buggy considering connections are coroutines and technicly "parallel" but i dont care
		for i, mdl in ipairs(buttons) do
			local playersOnDebounce = {} :: {Player}
			
			local button: BasePart = mdl.Button
			local buttonMap = pickedMaps[i]
			mdl:AddTag(buttonMap)
			mdl:SetAttribute("Map", buttonMap)
			
			local ui: SurfaceGui = mdl.UI:FindFirstChildWhichIsA("SurfaceGui")
			if not ui then
				error(`Button in lobby {chosenLobby.Name} has no surfacegui or UI part`)
			end
			local text: TextLabel = ui.Main.NumVotes
			
			initMapButtonUI(ui, buttonMap)
			button.Color = lData.DefaultColor
			
			local c = button.Touched:Connect(function(part: BasePart)
				local plr = Players:GetPlayerFromCharacter(part.Parent)
				
				if not plr then
					return
				end
				
				if table.find(playersOnDebounce, plr) then
					return
				end
				
				local prevMap = playerVotes[plr]
				
				if buttonMap == prevMap then
					return
				end
				
				table.insert(playersOnDebounce, plr)
				task.delay(1, function()
					local idx = table.find(playersOnDebounce, plr)
					
					if not idx then 
						return
					end
					
					table.remove(playersOnDebounce, idx)
				end)
				
				
				local count = countVotes(playerVotes, buttonMap)
				if prevMap then
					count += 1
					votingEffectEvent:FireClient(plr, mdl, CollectionService:GetTagged(buttonMap))
				else
					votingEffectEvent:FireClient(plr, mdl, nil)
				end
				
				playerVotes[plr] = buttonMap
				updateCounts(playerVotes, buttons)
			end)
			
			table.insert(buttonCons, c)
		end
		
		local water = chosenLobby:FindFirstChild("Water")
		local fragmentable = chosenLobby:FindFirstChild("Fragmentable")

		if water then
			water.Parent = workspace
		end

		if fragmentable then
			fragmentable.Parent = workspace
		end
		
		for _, p in pairs(Players:GetPlayers()) do
			p:LoadCharacter()
		end
		
		local lobbyTime: number = chosenLobby:GetAttribute("LobbyTime") or 30
		
		local dtPassed = 0
		while true do
			local dt = task.wait()
			lobbyTime -= dt
			dtPassed += dt

			if dtPassed >= 1 then
				sendTime:FireAllClients(lobbyTime)
				dtPassed = 0
			end
			
			if lobbyTime <= 0 then
				break
			end
		end
		
		for _, con in pairs(buttonCons) do
			con:Disconnect()
		end
		
		buttonCons = nil
		
		local chosenMap: string
		local freq: {[string]: number} = {}
		local totalVotes = 0
		local max = 0
		for p, map in playerVotes do
			if map == nil then
				continue
			end
			
			if not freq[map] then
				freq[map] = 1
			else
				freq[map] += 1
			end
			
			local votes = freq[map]
			if votes > max then
				max = votes
			end
			
			totalVotes += 1
		end
		
		local maxMaps = {}
		for map, votes in pairs(freq) do
			if votes == max then
				table.insert(maxMaps, map)
			end
		end

		if #maxMaps == 0 then
			chosenMap = pickedMaps[math.random(1, #pickedMaps)]
		else
			chosenMap = maxMaps[math.random(1, #maxMaps)]
		end
		
		cleanUp(true)
	
		Players.CharacterAutoLoads = false
		
		mapChangedEvent:Fire(chosenMap)

		local mapModel: Model = mapFolder:FindFirstChild(chosenMap):Clone()

		local playTime = mapModel:GetAttribute("playTime")

		if not playTime or typeof(playTime) ~= "number" then
			warn(`Map {mapModel.Name} does not have a playtime attribute, or has one but is not a number.`)
			playTime = 360
		end

		mapModel.Parent = workspace.MainMap

		local water = mapModel:FindFirstChild("Water")
		local fragmentable = mapModel:FindFirstChild("Fragmentable")

		if water then
			water.Parent = workspace
		end

		if fragmentable then
			fragmentable.Parent = workspace
		end

		if chosenMap == "thirsty town" then
			local scr = mapModel:FindFirstChild("SunScript")
			
			if scr and scr:IsA("Script") then
				scr.Enabled = true
			end
		end
		
		Players.CharacterAutoLoads = true

		for _, v in pairs(Players:GetPlayers()) do
			evnt:FireAllClients(chosenMap, false)
			v:LoadCharacter()
		end

		playing.Value = true
		PhysicsService:CollisionGroupSetCollidable("Players", "Players", true)

		local dtPassed = 0
		while true do
			local dt = task.wait()
			playTime -= dt
			dtPassed += dt

			if dtPassed >= 1 then
				sendTime:FireAllClients(playTime)
				dtPassed = 0
			end

			if playTime <= 0 then
				break
			end
		end
	end
end

--> Module Functions

--> Loader Methods
function module.Start()
	PhysicsService:RegisterCollisionGroup("Players")
	PhysicsService:CollisionGroupSetCollidable("Players", "Players", false)
	
	Players.PlayerAdded:Connect(function(plr)
		local suc, has = pcall(function()
			return MarketplaceService:UserOwnsGamePassAsync(plr.UserId, panGP)
		end)
		
		plr.CharacterAppearanceLoaded:Wait()

		local map = workspace.MainMap:FindFirstChildWhichIsA("Model")

		if map then
			evnt:FireClient(plr, map.Name, not playing.Value)
		end
		
		if not playing.Value then
			if has then
				local clone = sStore.Assets.Items.Melee["frying pan"]:Clone()
				clone.Parent = plr.Backpack
			end
		end
		
		plr.CharacterAdded:Connect(function(char)
			if not playing.Value then
				if has then
					local clone = sStore.Assets.Items.Melee["frying pan"]:Clone()
					clone.Parent = plr.Backpack
				end
			end
			
			for _, part in pairs(char:GetChildren()) do
				if part:IsA("BasePart") then
					part.CollisionGroup = "Players"
				end
			end
		end)
	end)
	
	Players.PlayerRemoving:Connect(function(plr)
		local idx = table.find(playersWithLobbyGP, plr)
		
		if idx then
			table.remove(playersWithLobbyGP, idx)
		end
	end)

	mapLoop()
end

return module
