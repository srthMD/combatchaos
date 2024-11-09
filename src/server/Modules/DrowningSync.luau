--> Services
local rStore = game:GetService("ReplicatedStorage")

--> Variables
local module = {}

local syncEvent = rStore.Signals.Remote.SyncDrowning

--> Private Functions
function sync(plr: Player, hp: number)
	if type(hp) ~= "number" then
		return
	end

	local char = plr.Character

	if not char then
		return
	end

	local hum = char:FindFirstChildWhichIsA("Humanoid")

	if hum then
		--funny trickery
		hum.Health -= math.abs(hp)
	end
end

--> Module Functions

--> Loader Methods
function module.Start()
	syncEvent.OnServerEvent:Connect(sync)
end

return module
