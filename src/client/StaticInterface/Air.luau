local rStore = game:GetService("ReplicatedStorage")

return function(CoreUI: ScreenGui)
	local air = rStore.Assets.StaticInterface.Air:Clone()
	air.Parent = CoreUI
end