--> Services
local rStore = game:GetService("ReplicatedStorage")
local sStore = game:GetService("ServerStorage")
local Players = game:GetService("Players")

local SharedTypes = require(rStore.Data.SharedType)

--> Variables
local votingTime = sStore.VotingTime

local module = {}

local terrain = workspace.Terrain
local mapfolder = workspace:WaitForChild("MainMap")

local evnt = rStore.Signals.Remote.OnMapChange
local votingEvents = rStore.Signals.Remote.Voting
local mapChangedEvent = sStore.Signals.Event.MapChanged

local playing = game.ServerStorage.Playing

local rand = Random.new(os.time())

local mapFolder = sStore.Assets.Maps
local maps = mapFolder:GetChildren()

--> Private Functions
local function newVoteDict(maps: { string }): SharedTypes.VoteDict
	local voteDict = {} :: SharedTypes.VoteDict

	for _, map in pairs(maps) do
		voteDict[map] = {}
	end

	return voteDict
end

local function cleanUp()
	rand:Shuffle(maps)

	playing.Value = false

	terrain:Clear()
	mapfolder:ClearAllChildren()
	Players.CharacterAutoLoads = false

	if workspace:FindFirstChild("Fragmentable") then
		workspace.Fragmentable:Destroy()
	end

	workspace.Debris:ClearAllChildren()

	for _, plr in Players:GetPlayers() do
		if plr.Character then
			plr.Character:Destroy()
		end
	end
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

local function mapLoop(): never
	while true do
		playing.Value = false

		cleanUp()

		if #Players:GetPlayers() == 0 then
			Players.PlayerAdded:Wait()
		end

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

		endVoting(chosenMap :: string)
		mapChangedEvent:Fire(chosenMap)

		task.wait(5)

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

		Players.CharacterAutoLoads = true

		for _, v in pairs(Players:GetPlayers()) do
			evnt:FireAllClients(chosenMap)
			v:LoadCharacter()
		end

		playing.Value = true

		task.wait(playTime or 360)
	end
end

--> Module Functions

--> Loader Methods
function module.Start()
	Players.PlayerAdded:Connect(function(plr)
		plr.CharacterAppearanceLoaded:Wait()

		local map = workspace.MainMap:FindFirstChildWhichIsA("Model")

		if map then
			evnt:FireClient(plr, map.Name)
		end
	end)

	mapLoop()
end

return module
