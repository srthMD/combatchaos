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

	local musicPlayer: AudioPlayer? = SoundService:FindFirstChild("Music")

	local muted = false
	if musicPlayer then
		muteIcon.MouseButton1Click:Connect(function()
			if muted then
				muted = false
				muteIcon.Image = onID
				musicPlayer.Volume = 1
			else
				muted = true
				muteIcon.Image = offID
				musicPlayer.Volume = 0
			end
		end)
	else
		warn("MuteButton: Could not find music AudioPlayer.")
	end
end
