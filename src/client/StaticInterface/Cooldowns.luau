local rStore = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local plr = Players.LocalPlayer

local assets = rStore.Assets

return function(CoreUI: ScreenGui)
	local cg = assets.StaticInterface.cg:Clone()
	cg.Parent = CoreUI

	plr.CharacterRemoving:Connect(function(_: Model)
		for _, frame: Instance in pairs(cg:GetChildren()) do
			if frame:IsA("Frame") then
				frame:Destroy()
			end
		end
	end)
end
