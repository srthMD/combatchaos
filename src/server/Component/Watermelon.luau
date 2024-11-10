local rStore = game:GetService("ReplicatedStorage")

local Component = require(rStore.Packages.Component)
local Watermelon = Component.new({ Tag = "Watermelon", Ancestors = { workspace } })

function Watermelon:HeartbeatUpdate()
	self.Instance.Moving.PlaybackSpeed = math.clamp(self.Instance.AssemblyLinearVelocity.Magnitude / 35, 0.85, 2)
end

return Watermelon
