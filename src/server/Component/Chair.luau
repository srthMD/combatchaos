local rStore = game:GetService("ReplicatedStorage")

local Component = require(rStore.Packages.Component)
local Chair = Component.new({ Tag = "Chair", Ancestors = { workspace } })

function Chair:HeartbeatUpdate()
	self.Instance.Moving.Volume = math.clamp(self.Instance.AssemblyLinearVelocity.Magnitude / 25, 0, 0.5)
end

return Chair
