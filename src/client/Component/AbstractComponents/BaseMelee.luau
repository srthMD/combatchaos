local BaseMelee = {}

--> Services
local rStore = game:GetService("ReplicatedStorage")

--> Variables
local MeleeData = require(rStore.Data.Melee.Loader)

--> Constructor
function BaseMelee.Constructing(component)
	local backendName = component.Instance:GetAttribute("backendName")

	if backendName == nil or typeof(backendName) ~= "string" then
		error(`{component.Instance.Name} does not have attribute backendName, or is not of type string.`)
		return
	end

	local data = MeleeData(backendName)

	if data == nil then
		error(`Failed to get melee data for {component.Instance.Name}`)
		return
	else
		component["Data"] = data
	end

	component["Event"] = rStore.Signals.Client.HandleMelee
end

function BaseMelee.Starting(component)
	component.Instance.Activated:Connect(function()
		component:OnActivate()
	end)

	component.Instance.Equipped:Connect(function()
		if component["OnEquip"] ~= nil and type(component["OnEquip"]) == "function" then
			component:OnEquip()
		end
	end)

	component.Instance.Unequipped:Connect(function()
		if component["OnUnequip"] ~= nil and type(component["OnUnequip"]) == "function" then
			component:OnUnequip()
		end
	end)
end

--> Module Functions
function BaseMelee.Stopping(component)
	component.Data = nil
	component.Event = nil
end

return BaseMelee
