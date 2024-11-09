--> Services
local rStore = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local sStore = game:GetService("ServerStorage")
local ssServ = game:GetService("ServerScriptService")
local Debris = game:GetService("Debris")
local runServ = game:GetService("RunService")

local isStudio = runServ:IsStudio()

--> Module Stuff
local module = {}

--> Variables
local NUMACTORS = 4

local SharedTypes = require(rStore.Data.SharedType)

local assets = rStore.Assets.MeleeSys

local rev_DoCast = rStore.Signals.Remote.MeleeActivated
local urev_OnEquip = rStore.Signals.Remote.Unreliable.OnEquipMelee
local ev_OnHit = sStore.Signals.Event.OnHitMelee
local ev_OnAttack = sStore.Signals.Event.OnAttackMelee

local actor = ssServ.Server.Actors.MeleeHandler

local AF: Folder

local currentActor = 1

--> Private Functions
-- all of the return functions should be turned into calls to the ACService later
function validate(plr: Player, packet: SharedTypes.MeleePacket)
	local new: SharedTypes.MeleePacket = {
		ClientTime = packet.ClientTime,
		Origin = packet.Origin,
		MeleeType = packet.MeleeType,
		Owner = packet.Owner,
		Time = os.clock(),
	}

	if packet["Sound"] then
		new["Sound"] = packet.Sound
	end

	local ac = AF:FindFirstChild(tostring(currentActor))

	if not ac then
		warn(`{ac} is not a valid actor number.`)
		return
	end

	ac:SendMessage("MeleeCast", plr, new)

	if currentActor >= NUMACTORS then
		currentActor = 1
	end

	currentActor += 1
end

function initalizeActors(): Folder
	local actorFolder = Instance.new("Folder")
	actorFolder.Name = "MeleeActors"
	actorFolder.Parent = ssServ

	for i = 1, NUMACTORS do
		local a = Instance.new("Actor")
		a.Parent = actorFolder
		a.Name = tostring(i)

		local c = actor:Clone()
		c.Parent = a
		c.Enabled = true
	end

	return actorFolder
end

function onEquip(plr: Player, melee: string, inst: Tool)
	local meleeAssets = assets:FindFirstChild(melee)

	if not meleeAssets then
		if isStudio then
			warn(`assets for {melee} not found`)
			return
		end
	end

	local hasEquipAssets = meleeAssets:FindFirstChild("Sounds") ~= nil
		or meleeAssets.Sounds:FindFirstChild("Equip") ~= nil

	if hasEquipAssets == false then
		return
	end

	local parent = inst.Parent

	if not parent then
		return
	end

	local handle = inst:FindFirstChild("Handle")
	if handle == nil then
		local hrp = parent:FindFirstChild("HumanoidRootPart")

		if hrp == nil then
			return
		end

		handle = hrp
	end

	if parent:IsA("Model") and parent:FindFirstChildWhichIsA("Humanoid") then
		local sounds = meleeAssets.Sounds.Equip:GetChildren()
		local s: Sound

		if #sounds == 1 then
			s = sounds[1]:Clone()
		else
			s = sounds[math.random(1, #sounds)]:Clone()
		end

		if s.Looped then
			local a = handle:FindFirstChild(s.Name)
			if a then
				a:Destroy()
			end
		end

		s.Parent = handle
		s:Play()

		Debris:AddItem(s, s.TimeLength)

		inst.Unequipped:Once(function()
			s:Destroy()
		end)
	end
end

function onAttack(melee: string, inst: Tool, sound: string?)
	if inst == nil or inst.Parent == nil then
		return
	end

	if not (inst.Parent:IsA("Model") and Players:GetPlayerFromCharacter(inst.Parent)) then
		return
	end

	local soundAssets: Folder? = assets[melee]:FindFirstChild("Sounds")
	if not soundAssets then
		return
	end

	local attackSounds = soundAssets:FindFirstChild("Attack")
	if not attackSounds or not attackSounds:IsA("Folder") then
		return
	end

	local handle = inst:FindFirstChild("Handle")
	if handle == nil then
		local hrp = inst.Parent:FindFirstChild("HumanoidRootPart")

		if hrp == nil then
			return
		end

		handle = hrp
	end

	local s: Sound

	if sound then
		local requestedSound: Sound? = attackSounds:FindFirstChild(sound)
		if not requestedSound then
			warn(`requested sound {sound} from melee assets {melee} does not exist`)
			return
		end

		s = requestedSound
	else
		local sounds = attackSounds:GetChildren()
		s = sounds[math.random(1, #sounds)]
	end

	local clone = s:Clone()
	clone.Parent = handle
	--everybody forgets to change rolloff
	clone.RollOffMaxDistance = math.clamp(clone.RollOffMaxDistance, 0, 528)
	--if theres reverb or echo idk
	Debris:AddItem(clone, clone.TimeLength * 1.2)
	clone:Play()
end

function onHit(melee: string, hum: Humanoid, inst: Tool)
	if hum.Parent == nil then
		return
	end

	if not assets[melee].Sounds:FindFirstChild("Hit") then
		return
	end

	local sounds = assets[melee].Sounds.Hit:GetChildren()
	local s: Sound

	if #sounds == 1 then
		s = sounds[1]:Clone()
	else
		s = sounds[math.random(1, #sounds)]:Clone()
	end

	local handle = inst:FindFirstChild("Handle")
	if not handle then
		s.Parent = hum.Parent:FindFirstChild("HumanoidRootPart")
	else
		s.Parent = handle
	end

	Debris:AddItem(s, s.TimeLength)
	s:Play()
end
--> Module Functions

--> Loader Functions
function module.Start()
	task.delay(1, function()
		AF = initalizeActors()
	end)

	ev_OnHit.Event:Connect(onHit)
	ev_OnAttack.Event:Connect(onAttack)
	rev_DoCast.OnServerEvent:Connect(validate)
	urev_OnEquip.OnServerEvent:Connect(onEquip)
end

return module
