--> Services
local sStore = game:GetService("ServerStorage")
local Players = game:GetService("Players")

--> Variables
local module = {}

local stats = { "Kills", "Wipeouts" }

local playing = sStore.Playing

local addKillEvent: BindableEvent = sStore.Signals.Event.AddKill

--> Private Functions

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
	end
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

--> Module Functions

--> Loader Methods
function module.Start()
	Players.PlayerAdded:Connect(onPlayerAdd)
	addKillEvent.Event:Connect(addKill)
end

return module
