local rStore = game:GetService("ReplicatedStorage")

local assets = rStore.Assets

return function(CoreUI: ScreenGui)
	local cg = assets.StaticInterface.cg:Clone()
	cg.Parent = CoreUI
end
