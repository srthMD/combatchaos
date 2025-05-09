local sStore = game:GetService("ServerStorage")
local Players = game:GetService("Players")

local module = {}

local stats = { "Kills", "Wipeouts" }

local playing = sStore.Playing

local addKillEvent: BindableEvent = sStore.Signals.Event.AddKill
local dropWeaponEvent: BindableEvent = sStore.Signals.Event.DropWeapon

local rand = Random.new(os.time())

local function addKill(plr: Player, kills: number?)
	if not (typeof(plr) == "Instance" and plr:IsA("Player")) then
		return
	end

	if not kills then
		kills = 1
	elseif type(kills) ~= "number" then
		return
	end

	local leaderstats = plr:FindFirstChild("leaderstats")

	if not leaderstats then
		return
	end

	local killsValue = leaderstats:FindFirstChild("Kills")

	if killsValue and killsValue:IsA("IntValue") then
		killsValue.Value += kills
		local char = plr.Character

		if char then
			local humanoid = char:FindFirstChildWhichIsA("Humanoid")

			if humanoid and humanoid.Health > 0 then
				humanoid.Health += kills * 20
			end
		end
	end
end

local function dropWeapon(plr: Player)
	local char = plr.Character
	if not char then
		return
	end

	local hrp: BasePart = char:FindFirstChild("HumanoidRootPart")
	if not hrp then
		return
	end

	local hum = char:FindFirstChildWhichIsA("Humanoid")
	if not hum then
		return
	end

	local tools = {}
	for _, inst in pairs(plr.Backpack:GetChildren()) do
		if inst:IsA("Tool") and inst:FindFirstChild("Handle") and inst.RequiresHandle then
			table.insert(tools, inst)
		end
	end

	if #tools == 0 then
		return
	end

	local tool: Tool & { Handle: BasePart } = tools[math.random(1, #tools)]:Clone()

	tool.Parent = workspace.Debris
	tool:PivotTo(hrp.CFrame + Vector3.new(math.random(-3, 3), math.random(0, 3), math.random(-3, 3)))
	tool.Handle.AssemblyLinearVelocity = Vector3.new(math.random(-20, 20), math.random(10, 30), math.random(-20, 20))
	tool.Handle.AssemblyAngularVelocity = rand:NextUnitVector() * 3
	tool.Handle.CanTouch = false

	task.delay(1.5, function()
		tool.Handle.CanTouch = true
	end)

	task.delay(30, function()
		if not tool.Parent then
			return
		end

		if not tool.Parent:IsA("Backpack") or not Players:GetPlayerFromCharacter(tool.Parent) then
			tool:Destroy()
		end
	end)
end

local function onPlayerAdd(plr: Player)
	local l = Instance.new("Model")
	l.Parent = plr
	l.Name = "leaderstats"

	for _, v in pairs(stats) do
		local value = Instance.new("IntValue")
		value.Parent = l
		value.Name = v
	end

	plr.CharacterAdded:Connect(function(char)
		local humanoid = char:WaitForChild("Humanoid")

		local diedConnection
		diedConnection = humanoid.Died:Connect(function()
			if playing.Value then
				l.Wipeouts.Value += 1
			end
			diedConnection:Disconnect()
		end)
	end)
end

function module.Start()
	Players.PlayerAdded:Connect(onPlayerAdd)
	addKillEvent.Event:Connect(addKill)
	dropWeaponEvent.Event:Connect(dropWeapon)
end

return module
