--TODO: remove when 100% sure its not needed
--rn the button is disabled and dosent show up

if true then
	return function() end
end

local rStore = game:GetService("ReplicatedStorage")

local r_respawn = rStore.Signals.Remote.Unreliable.RequestRespawn
local lPlr = game.Players.LocalPlayer
local res = rStore.Assets.StaticInterface

return function(CoreUI: ScreenGui)
	local respawn = res.Respawn:Clone()
	respawn.Parent = CoreUI

	respawn.MouseButton1Click:Connect(function()
		local char = lPlr.Character

		if char then
			local hum = char:FindFirstChildWhichIsA("Humanoid")

			if hum then
				if hum.Health == 0 then
					return
				end
			end
		end

		r_respawn:FireServer()
	end)
end
