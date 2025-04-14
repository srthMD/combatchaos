local BaseGun = {}

local rStore = game:GetService("ReplicatedStorage")

local ProjectileData = require(rStore.Data.Projectiles.Loader)

function BaseGun.Constructing(component)
	local backendName = component.Instance:GetAttribute("backendProjectileName")

	if backendName == nil or typeof(backendName) ~= "string" then
		error(`{component.Instance.Name} does not have attribute backendProjectileName, or is not of type string.`)
		return
	end

	local data = ProjectileData(backendName)

	if data == nil then
		error(`Failed to get projectile data for {component.Instance.Name}`)
		return
	else
		component["Data"] = data
	end

	component["Event"] = rStore.Signals.Client.CreateProjectile
end

function BaseGun.Starting(component)
	component.Instance.Activated:Connect(function()
		component:OnActivate()
	end)

	component.Instance.Equipped:Connect(function()
		if component["OnEquip"] ~= nil and type(component["OnEquip"]) == "function" then
			component:OnEquip()
		end
	end)
end

function BaseGun.Stopping(component)
	component.Data = nil
	component.Event = nil
end

return BaseGun
