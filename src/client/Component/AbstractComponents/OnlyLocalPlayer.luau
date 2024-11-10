local player = game:GetService("Players").LocalPlayer

local OnlyLocalPlayer = {}

function OnlyLocalPlayer.ShouldConstruct(component)
	local char = player.Character

	if char then
		return component.Instance:IsDescendantOf(char)
	end

	return component.Instance.Parent == player.Backpack
end

return OnlyLocalPlayer
