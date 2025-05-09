local rStore = game:GetService("ReplicatedStorage")

local module = {}

local syncEvent = rStore.Signals.Remote.SyncDrowning

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

function module.Start()
	syncEvent.OnServerEvent:Connect(sync)
end

return module
