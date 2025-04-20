local module = {}

local Players = game:GetService("Players")

local plr = Players.LocalPlayer

function module.Start()
	plr.CharacterAdded:Connect(function(char: Model)
		-- @type Humanoid
		local hum = char:WaitForChild("Humanoid")

		if not hum then
			warn("Could not find humanoid.")
			return
		end

		hum.Jumping:Connect(function(state: boolean)
			if not state then
				hum:SetStateEnabled(Enum.HumanoidStateType.Jumping, false)

				task.delay(1, function()
					hum:SetStateEnabled(Enum.HumanoidStateType.Jumping, true)
				end)
			end
		end)
	end)
end

return module
