local module = {}

local Players = game:GetService("Players")
local rStore = game:GetService("ReplicatedStorage")

local rand = Random.new(os.time())

local sounds = rStore.Assets.RandomDeathSounds:GetChildren() :: { Sound }

local function onCharacterAdded(char: Model, plr: Player)
	local humanoid = char:WaitForChild("Humanoid")

	if not humanoid or not humanoid:IsA("Humanoid") then
		return
	end

	local function playSound()
		local head = char:FindFirstChild("Head")

		if not head or not head:IsA("BasePart") then
			return
		end

		local sound = sounds[rand:NextInteger(1, #sounds)]

		if not sound:IsA("Sound") then
			warn(`{sound.Name} is not a sound.`)
			return
		end

		local clone = sound:Clone()
		clone.Parent = head
		clone:Play()

		clone.Ended:Wait()
	--	clone:Destroy()
	end

	humanoid.Died:Once(playSound)
end

local function onPlayerAdded(plr: Player)
	plr.CharacterAdded:Connect(function(char: Model)
		onCharacterAdded(char, plr)
	end)
end

function module.Start()
	Players.PlayerAdded:Connect(onPlayerAdded)
end

return module
