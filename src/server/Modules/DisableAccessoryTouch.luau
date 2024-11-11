-- @title: Server Projectile Handler
-- @author: qweekertom
-- @date: 2.29.2024

--> Services
local Players = game:GetService("Players")

--> Variables
local module = {}

--> Private Functions
function onCharacterAdd(char: Model, plr: Player)
	plr.CharacterAppearanceLoaded:Wait()

	local hum = char:FindFirstChild("Humanoid")

	if not hum then
		return
	end

	local animator = Instance.new("Animator")
	animator.Parent = hum

	for _, a in pairs(char:GetChildren()) do
		if a:IsA("Accessory") then
			local handle = a:FindFirstChild("Handle")
			handle.CanTouch = false
			handle.CanQuery = false
		end
	end

	--local hrp = char:WaitForChild("HumanoidRootPart") :: BasePart?

	--if hrp then
	--local diedSound = hrp:WaitForChild("Died") :: Sound?

	--if diedSound then
	--	diedSound.SoundId = 0
	--end
	--end
end

--> Module Functions

--> Loader Methods
function module.Start()
	Players.PlayerAdded:Connect(function(plr)
		plr.CharacterAdded:Connect(function(char)
			onCharacterAdd(char, plr)
		end)
	end)
end

return module
