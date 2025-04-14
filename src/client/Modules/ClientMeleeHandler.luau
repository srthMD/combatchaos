--> Services
local rStore = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Debris = game:GetService("Debris")
local tServ = game:GetService("TweenService")

--> Module Stuff
local module = {}

--> Variables
local SharedTypes = require(rStore.Data.SharedType)
local MeleeData = require(rStore.Data.Melee.Loader)

local assets = rStore.Assets.MeleeSys

local indicatorInfo = TweenInfo.new(0.1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
local indicatorPart = rStore.Assets.MeleeSys.HitInd
local iColor = indicatorPart.BillboardGui.TLabel.TextColor3
local sound = rStore.Assets.MeleeSys.Hit

local positivePrimary = Color3.fromRGB(21, 171, 19)
local positiveSecondary = Color3.fromRGB(19, 38, 24)

local eventFolder = rStore.Signals

local rev_DoCast = eventFolder.Remote.MeleeActivated
local ev_OnActivate = eventFolder.Client.HandleMelee
local urev_VisualizeHitbox = eventFolder.Remote.Unreliable.VisualizeHitbox
local urev_HitIndicator = eventFolder.Remote.Unreliable.HitIndicator
local rev_ReplicateRagdoll = eventFolder.Remote.ReplicateRagdoll
local ev_CreateCooldownUi = eventFolder.Client.CreateCooldownUI

local LocalPlayer = Players.LocalPlayer

local ColorHitRange = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
	ColorSequenceKeypoint.new(1 / 5, Color3.fromRGB(179, 255, 0)),
	ColorSequenceKeypoint.new(2 / 5, Color3.fromRGB(98, 255, 0)),
	ColorSequenceKeypoint.new(3 / 5, Color3.fromRGB(0, 255, 51)),
	ColorSequenceKeypoint.new(4 / 5, Color3.fromRGB(0, 255, 183)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 255, 255)),
})

--> Private Functions
function onActivate(melee: string, origin: CFrame, animation: string?, sound: string?): ()
	local char = LocalPlayer.Character
	if not char then
		return
	end

	local pHum = char:FindFirstChildWhichIsA("Humanoid")
	if not pHum or pHum.Health == 0 then
		return
	end
	
	local data = MeleeData(melee)
	
	if not data then
		return
	end
	
	if data.Cooldown > 3 then
		ev_CreateCooldownUi:Fire(data.MeleeName, data.Cooldown, Color3.fromRGB(255, 107, 107))
	end

	task.spawn(playAttackAnimation, pHum, melee, animation)

	local clock = os.clock()

	local new: SharedTypes.MeleePacket = {
		ClientTime = clock,
		Origin = origin,
		MeleeType = melee,
		Owner = LocalPlayer, -- trollface
	}

	if sound then
		new["Sound"] = sound
	end

	rev_DoCast:FireServer(new)
end

function playAttackAnimation(pHum: Humanoid, melee: string, animation: string?)
	if not pHum.Parent then
		return
	end

	local data = MeleeData(melee)

	local tool = pHum.Parent:FindFirstChild(data.MeleeName)

	if not tool or not tool:IsA("Tool") then
		return
	end

	local animator = pHum:FindFirstChildWhichIsA("Animator")

	local anim: Animation

	local __a = assets[melee].Animations:FindFirstChild("Attack") :: Folder?
	if not __a then
		return
	end

	if animation ~= nil then
		local reqAnim = __a:FindFirstChild(animation) :: Animation?
		if not reqAnim then
			return
		end

		anim = reqAnim
	else
		local animations = __a:GetChildren()

		anim = animations[math.random(1, #animations)]
	end

	local a = animator:LoadAnimation(anim)
	--a:AdjustSpeed(2)
	a:Play()

	local c = tool.Unequipped:Once(function()
		a:Stop(0.15)
	end)

	a.Ended:Wait()

	if c.Connected then
		c:Disconnect()
	end
end

function visualizeHitbox(cframe: CFrame, size: Vector3, isSphere: boolean, validHits: number?)
	local part = Instance.new("Part")
	part.Anchored = true
	part.Transparency = 0.7
	part.Material = Enum.Material.ForceField
	part.CanCollide = false
	part.CanTouch = false
	part.CanQuery = false
	part.CastShadow = false
	part.CFrame = cframe

	if isSphere then
		part.Shape = Enum.PartType.Ball
		part.Size = size
	else
		part.Size = size
	end

	if validHits == nil then
		part.Color = Color3.fromRGB(143, 145, 130)
	else
		part.Color = ColorHitRange.Keypoints[math.clamp(validHits + 1, 1, #ColorHitRange.Keypoints)].Value
	end

	part.Parent = workspace
	Debris:AddItem(part, 2)
end

function handleHitIndicator(dmg: number, pos: Vector3, newPos: Vector3?, plr: Model)
	if dmg < 0 then
		indicator = indicatorPart:Clone()
		indicator.Handler.Enabled = true
		indicator.Parent = plr
		indicator.Position = pos

		local c = sound:Clone()
		c.Parent = game.SoundService
		c:Play()

		task.spawn(function()
			c.Ended:Wait()
			c:Destroy()
		end)

		local ui = indicator:FindFirstChildWhichIsA("BillboardGui")
		local text: TextLabel = ui.TLabel
		local str = string.format("%.1f", -dmg)
		text.Text = "+" .. str
		text.TextColor3 = Color3.fromRGB(177, 255, 148)
		text.UIStroke.Color = positiveSecondary

		t = tServ:Create(text, indicatorInfo, { TextColor3 = positivePrimary })
		t2 = tServ:Create(indicator, indicatorInfo, { Position = newPos })

		t:Play()
		t2:Play()
		
		return
	end
	
	local indicator = plr:FindFirstChild("HitInd")
	
	if indicator then
		if t then
			t:Destroy()
			t2:Destroy()
		end
		
		local iDmg: number = indicator:GetAttribute("Damage")
		iDmg += dmg
		
		local ui = indicator:FindFirstChildWhichIsA("BillboardGui")
		local pitchVal = indicator:FindFirstChild("Pitch")
		indicator:FindFirstChild("Transparency").Value = 0

		pitchVal.Value = math.clamp((pitchVal.Value + 0.1), 1, 2)

		local c = sound:Clone()
		c.Parent = game.SoundService
		c.PitchShiftSoundEffect.Octave = pitchVal.Value
		c:Play()

		task.spawn(function()
			c.Ended:Wait()
			c:Destroy()
		end)

		indicator.Position = pos

		local text: TextLabel = ui.TLabel
		
		local str = string.format("%.1f", iDmg)
		text.Text = "-" .. str
		text.TextColor3 = Color3.fromRGB(255, 172, 172)

		t = tServ:Create(text, indicatorInfo, { TextColor3 = iColor })

		if newPos then
			t2 = tServ:Create(indicator, indicatorInfo, { Position = newPos })
		else
			local p = pos + Vector3.new(0, 1, 0)
			t2 = tServ:Create(indicator, indicatorInfo, { Position = p })
		end
		
		indicator:SetAttribute("Damage", iDmg)

		t:Play()
		t2:Play()
	else
		indicator = indicatorPart:Clone()
		indicator.Handler.Enabled = true
		indicator.Parent = plr
		indicator.Position = pos
		indicator:SetAttribute("Damage", dmg)

		local pitchVal = indicator:FindFirstChild("Pitch")

		math.clamp(math.pow(pitchVal.Value + 0.02, 1.3), 1.0, 2.0)

		local c = sound:Clone()
		c.Parent = game.SoundService
		c.PitchShiftSoundEffect.Octave = pitchVal.Value
		c:Play()

		task.spawn(function()
			c.Ended:Wait()
			c:Destroy()
		end)

		local ui = indicator:FindFirstChildWhichIsA("BillboardGui")
		local text: TextLabel = ui.TLabel
		local str = string.format("%.1f", dmg)
		text.Text = "-" .. str
		text.TextColor3 = Color3.fromRGB(255, 172, 172)

		t = tServ:Create(text, indicatorInfo, { TextColor3 = iColor })
		t2 = tServ:Create(indicator, indicatorInfo, { Position = newPos })

		t:Play()
		t2:Play()
	end
end

--> Module Functions

--> Loader Functions
function module.Start()
	ev_OnActivate.Event:Connect(onActivate)
	urev_VisualizeHitbox.OnClientEvent:Connect(visualizeHitbox)
	urev_HitIndicator.OnClientEvent:Connect(handleHitIndicator)
end

return module
