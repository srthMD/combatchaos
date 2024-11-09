local ReplicatedStorage = game:GetService("ReplicatedStorage")

local loader = require(ReplicatedStorage.Loader)
local Component = require(ReplicatedStorage.Loader.Utils.Component)

loader.InitModules(script.Parent.Modules)
loader.Start()

Component.Load(script.Parent.Component)
