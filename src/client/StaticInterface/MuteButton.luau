local rStore = game:GetService("ReplicatedStorage")
local ContentProvider = game:GetService("ContentProvider")
local SoundService = game:GetService("SoundService")

local onID = "rbxassetid://126559015953039"
local offID = "rbxassetid://3892149263"

return function(CoreUI: ScreenGui)
	ContentProvider:PreloadAsync({
		onID,
		offID,
	})

	local muteIcon: ImageButton = rStore.Assets.StaticInterface.Mute:Clone()
	muteIcon.Parent = CoreUI

	local musicSoundGroup: SoundGroup? = SoundService:FindFirstChild("Music")

	local muted = false
	if musicSoundGroup then
		muteIcon.MouseButton1Click:Connect(function()
			if muted then
				muted = false
				muteIcon.Image = onID
				musicSoundGroup.Volume = 1
			else
				muted = true
				muteIcon.Image = offID
				musicSoundGroup.Volume = 0
			end
		end)
	else
		warn("MuteButton: Could not find music sound group.")
	end
end
