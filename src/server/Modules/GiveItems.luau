--> Services
local rStore = game:GetService("ReplicatedStorage")
local sStore = game:GetService("ServerStorage")
local Players = game:GetService("Players")

--> Variables
local module = {}

local itemsFolder = sStore.Assets.Items
local mapDataFolder = rStore.Data.Maps

local mapChangedEvent = sStore.Signals.Event.MapChanged

local BiasedRandom = require(sStore.Libs.BiasedRandom)

local playing = game.ServerStorage.Playing

local vanillaSlots = {} :: { string }
local currentItemPool: Folder? = nil

--> Private Functions

-- children in f1 override children in f2 with the same name
local function createUnion(f1: Folder, f2: Folder): Folder
	local union = Instance.new("Folder")

	for _, slot in pairs(f1:GetChildren()) do
		slot:Clone().Parent = union
	end

	for _, slot in pairs(f2:GetChildren()) do
		if not union:FindFirstChild(slot.Name) then
			slot:Clone().Parent = union
		end
	end

	return union
end

local function giveSingle(tool: Tool | ObjectValue, plr: Player)
	local clone: Tool

	if tool:IsA("Tool") then
		clone = tool:Clone()
	elseif tool:IsA("ObjectValue") then
		if not tool.Value then
			error(`ObjectValue {tool.Name}.Value is nil.`)
		end

		if not tool.Value:IsA("Tool") then
			error(`ObjectValue {tool.Name}.Value is not a tool.`)
		end

		clone = tool.Value:Clone()
	else
		error(`Passed tool is not a tool, type is {typeof(tool)}`)
	end

	clone.Parent = plr.Backpack

	local giveGearFolder = clone:FindFirstChild("GiveGear")

	if not giveGearFolder then
		return
	end

	local dat: ModuleScript? = giveGearFolder:FindFirstChild("Init")

	if dat then
		local init = require(dat)

		task.spawn(function()
			init.OnToolGranted(plr)

			if dat.Parent then
				dat.Parent:Destroy()
			end
		end)
	end
end

local function giveItemsInOrder(tools: { [string]: Tool }, plr: Player)
	--this just ensures that all the items are given in order, if an item is not present
	--then nothing happens and the pcall handles it
	pcall(function()
		giveSingle(tools["Melee"], plr)
	end)

	pcall(function()
		giveSingle(tools["Ranged"], plr)
	end)

	pcall(function()
		giveSingle(tools["Util"], plr)
	end)

	pcall(function()
		giveSingle(tools["Extra"], plr)
	end)
end

local function giveItems(plr: Player)
	if not playing.Value then
		return
	end

	plr.Backpack:ClearAllChildren()

	local pool: Folder = nil

	if currentItemPool then
		local override = currentItemPool:GetAttribute("override")
		if override and typeof(override) == "boolean" then
			for _, tool in pairs(currentItemPool:GetChildren()) do
				giveSingle(tool, plr)
			end

			return
		else
			pool = currentItemPool
		end
	else
		pool = itemsFolder
	end

	local tools = BiasedRandom.tools(pool)

	giveItemsInOrder(tools, plr)

	for slot, tool: Tool in pairs(tools) do
		if typeof(tool) == "Instance" and tool:IsA("ObjectValue") then
			tool = tool.Value
		end

		if table.find(vanillaSlots, slot) then
			continue
		end

		giveSingle(tool, plr)
	end
end

--> Module Functions

--> Loader Methods
function module.Start()
	for _, f in pairs(itemsFolder:GetChildren()) do
		if f:IsA("Folder") then
			table.insert(vanillaSlots, f.Name)
		end
	end

	Players.PlayerAdded:Connect(function(plr)
		plr.CharacterAdded:Connect(function()
			giveItems(plr)
		end)
	end)

	mapChangedEvent.Event:Connect(function(map: string)
		local mapData: Folder? = mapDataFolder:FindFirstChild(map)

		if mapData ~= nil then
			local toolsFolder = mapData:FindFirstChild("Tools")
			if toolsFolder and not (#toolsFolder:GetChildren() == 0) then
				local additive: boolean? = toolsFolder:GetAttribute("additive")

				if additive then
					--i think this is a memory leak but honestly i dont really care, mabye the gc deals with this idk
					currentItemPool = createUnion(toolsFolder, itemsFolder)
				else
					currentItemPool = toolsFolder
				end
			else
				currentItemPool = nil
			end
		else
			error(`{map} does not have a data folder.`)
		end
	end)
end

return module
