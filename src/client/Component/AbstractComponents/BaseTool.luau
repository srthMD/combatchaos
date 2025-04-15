local BaseTool = {}

function BaseTool.Starting(component)
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

return BaseTool
