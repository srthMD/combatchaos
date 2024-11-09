local rStore = game:GetService("ReplicatedStorage")

return function(CoreUI: ScreenGui)
	local stamina = rStore.Assets.StaticInterface.Stamina:Clone()
	stamina.Parent = CoreUI
end