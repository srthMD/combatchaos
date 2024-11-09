--> Services
local rStore = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

--> Component Framework Dependencies
local Rcade = require(rStore.Libs.Rcade)

--abstract
local SETTINGS = {
	Tag = "__absBM",
}

--> Class Definition
local BaseMelee = Rcade.class({ Tag = SETTINGS.Tag })

--> Variables
local MeleeData = require(rStore.Data.Melee.Loader)

--> Constructor
function BaseMelee:__init(inst: Tool)
	if not inst.Parent then
		return
	end

	local backendName = inst:GetAttribute("backendName")

	if backendName == nil or typeof(backendName) ~= "string" then
		error(`{inst.Name} does not have attribute backendName, or is not of type string.`)
		return
	end

	local data = MeleeData(backendName)

	if data == nil then
		error(`Failed to get melee data for {inst.Name}`)
		return
	else
		self["Data"] = data
	end

	self["Instance"] = inst
	self["_initalized"] = false
	self["_spawned"] = self.Instance.Parent:IsA("Backpack")
		or self.Instance.Parent:FindFirstChildOfClass("Humanoid") ~= nil
	self["Debounce"] = false
	self["LocalPlayer"] = Players.LocalPlayer
	self["Mouse"] = self.LocalPlayer:GetMouse()
	self["Event"] = rStore.Signals.Client.HandleMelee
	self["EquipDB"] = false

	self:__backendInit()
end

--> Backend Constructor
function BaseMelee:__backendInit(): ()
	if self._spawned == false then
		return
	end
	if self._initalized == true then
		return
	end
	self._initalized = true

	self.Instance.Activated:Connect(function()
		self:OnActivate()
	end)

	self.Instance.Destroying:Once(function()
		self:Destroy()
	end)
end

--> Private Functions
-- not inheritable

--> Module Functions
function BaseMelee:OnActivate(): ()
	if self.Debounce then
		return
	end
	self.Debounce = true

	local hrp: BasePart = self.Instance.Parent:FindFirstChild("HumanoidRootPart")
	local hCFrame = hrp.CFrame

	self.Event:Fire(self.Data.MeleeName, hCFrame)

	task.delay(self.Data.Cooldown, function()
		self.Debounce = false
	end)
end

function BaseMelee:Destroy(): ()
	self.Instance = nil
	self.Data = nil
	self.LocalPlayer = nil
	self.Mouse = nil
	self.Event = nil
end

return BaseMelee
