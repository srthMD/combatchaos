local BaseMelee = {}

local rStore = game:GetService("ReplicatedStorage")

local MeleeData = require(rStore.Data.Melee.Loader)

function BaseMelee.Constructing(component)
	print(component.Instance)
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

function BaseMelee.Stopping(component)
	component.Data = nil
	component.Event = nil
end

return BaseMelee
