--> Services
local rStore = game:GetService("ReplicatedStorage")

--> Variables
local module = {}

local r_respawn = rStore.Signals.Remote.Unreliable.RequestRespawn

local debounce = false

--> Private Functions
function respawn(plr: Player)
	if debounce then
		return
	end
	debounce = true

	task.delay(1, function()
		debounce = false
	end)

	plr:LoadCharacter()
	local leaderstats = plr:FindFirstChild("leaderstats")

	if leaderstats then
		local val = leaderstats:FindFirstChild("Wipeouts") :: IntValue?

		if val then
			val.Value += 1
		end
	end
end

--> Module Functions

--> Loader Methods
function module.Start()
	r_respawn.OnServerEvent:Connect(respawn)
end

return module
