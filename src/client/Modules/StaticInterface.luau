local Players = game:GetService("Players")

local module = {}

local plr = Players.LocalPlayer

function module.Start()
	local BaseUi = Instance.new("ScreenGui")
	BaseUi.ResetOnSpawn = false
	BaseUi.Name = "CC_Core"
	BaseUi.IgnoreGuiInset = true
	BaseUi.Parent = plr.PlayerGui

	for _, v in pairs(script.Parent.Parent.StaticInterface:GetChildren()) do
		if v:IsA("ModuleScript") then
			local f = require(v)
			local suc, res = pcall(f, BaseUi)

			if not suc then
				warn(`Error in {v.Name}: \n{res}`)
			end
		end
	end
end

return module
