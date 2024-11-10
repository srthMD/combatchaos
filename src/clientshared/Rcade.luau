--thanks to random devforum post bc this is nice util for OOP
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)

local Rcade = {}

function Rcade:__call(...)
	local object = {}
	setmetatable(object, self)
	if self.__init then
		self.__init(object, ...)
	end
	return object
end

function Rcade:__index(index)
	if rawget(self, "__super") then
		return self.__super[index]
	end

	return nil
end

function Rcade.class(newClass)
	if newClass.__super then
		for key, value in pairs(newClass.__super) do
			local sub = string.sub(key, 1, 2)
			if sub == "__" and key ~= "__super" and key ~= "__init" then
				newClass[key] = value
			end
		end
	end

	print(`making class {newClass}`)

	newClass.__index = newClass

	if newClass.Tag then
		local componentSettings = {}

		componentSettings["Tag"] = newClass.Tag

		if newClass["Ancestors"] then
			componentSettings["Ancestors"] = newClass.Ancestors
		end

		if newClass["Extensions"] then
			componentSettings["Extensions"] = newClass.Extensions
		end

		local classComponent = Component.new(componentSettings)

		if newClass.__super.Stop then
			classComponent.Stop = newClass.__super.Stop
		end

		newClass.Component = classComponent
	end

	return setmetatable(newClass, Rcade)
end

return Rcade
