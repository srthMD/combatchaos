--THIS SCRIPT IS NOT PORTABLE, IT IS ONLY MEANT TO BE USED IN COMBAT CHAOS

local BiasedRandom = {}

local function _initTable(tbl: { Tool | ObjectValue }): { string }
	local newTable = {} :: { string }

	for _, v in pairs(tbl) do
		if not typeof(v) == "Instance" then
			continue
		end
		
		local weight: number

		if v:IsA("Tool") then
			weight = v.GiveGear.BiasedRandomWeight.Value
		elseif v:IsA("ObjectValue") then
			local customWeight: NumberValue? = v:FindFirstChild("BiasedRandomWeight")

			if customWeight then
				weight = customWeight.Value
			else
				local folder = v:FindFirstChild("GiveGear")

				if folder then
					weight = folder.BiasedRandomWeight.Value
				end
			end
			
			local val = v.Value
			
			if val == nil then
				warn(`Tool {v.Name} has nil value.`)
				continue
			else
				v = v.Value
			end

		else
			error(
				`Instance {v.Name} in folder {v.Name.Parent} must be an objectvalue or tool, illegal type {typeof(v)}.`
			)
		end

		if weight == nil then
			weight = 10
			warn(`Tool {v.Name} does not have a weight, defaulting to 10.`)
		end
		
		if weight == 0 then
			continue
		end

		for count = 0, weight, 1 do
			table.insert(newTable, v.Name)
		end
	end

	return newTable
end

local function randomTools(tbl: {}, folder: Folder): { [string]: Tool }
	local chosenTools = {} :: { [string]: Tool }

	for name, f in pairs(tbl :: { [string]: { string } }) do
		if #f == 0 then
			continue
		end

		chosenTools[name] = folder[name][f[math.random(1, #f)]]
	end

	return chosenTools
end

function BiasedRandom.tools(itemFolder: Folder)
	local random = Random.new(os.time())

	local randTbl = {}

	for _, fold in pairs(itemFolder:GetChildren()) do
		if fold:IsA("Folder") then
			local ch = fold:GetChildren()
			
			if #ch == 0 then
				error(`Tools folder is empty for map {itemFolder.Parent.Name}`)
			end
			
			local t = _initTable(ch)
			random:Shuffle(t)
			randTbl[fold.Name] = t
		end
	end

	return randomTools(randTbl, itemFolder)
end

return BiasedRandom
