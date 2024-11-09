local ReplicatedStorage = game:GetService("ReplicatedStorage")

local loader = require(ReplicatedStorage.Loader)
local Component = require(ReplicatedStorage.Loader.Utils.Component)

loader.InitModules(script.Parent.Modules)
loader.Start()

for _, v in pairs(script.Parent.Component:GetChildren()) do
	if v.Name == "AbstractComponents" then
		continue
	end
	Component.Load(v)
end
