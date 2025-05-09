local rStore = game:GetService("ReplicatedStorage")

local Component = require(rStore.Packages.Component)

local Cat = Component.new({ Tag = "Cat", Ancestors = { workspace } })

local bounce = rStore.Assets.ItemDeps.CatTube.bounce

function Cat:Constuct()
	self.hitDebounce = false
	self.touchedConnection = nil
end

function Cat:OnHit()
	if not self.hitDebounce then
		self.hitDebounce = true

		local boingClone = bounce:Clone()
		boingClone.Parent = self.Instance
		boingClone.PlaybackSpeed = math.random(2, 2.3)
		boingClone:Play()

		task.spawn(function()
			boingClone.Ended:Wait()
			boingClone:Destroy()
		end)

		task.wait(0.1)
		self.hitDebounce = false
	end
end

function Cat:Start()
	self.touchedConnection = self.Instance.Touched:Connect(function()
		self:OnHit()
	end)
end

function Cat:Stop()
	if self.touchedConnection.Connected then
		self.touchedConnection:Disconnect()
	end

	self.touchedConnection = nil
end

return Cat
