local rStore = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local BASE_HUE = 0.35
local BASE_SAT = 0.75
local BASE_VALUE = 0.85

local WAIT_UNTIL_REGEN = 2
local REGEN_TIME = 1.25
--to make this work good this should be larger then the time on depleteBarInfo idk might screw up the tweens
local JUMP_COOLDOWN_TIME = 0.35

local info = TweenInfo.new(0.08, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
local depleteBarInfo = TweenInfo.new(0.15, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out)

local lPlr: Player = game.Players.LocalPlayer

local events = rStore.Signals
local assets = rStore.Assets

local mapChangedEvent = rStore.Signals.Remote.SendMapName
local sendTime = events.Remote.Unreliable.SendTime

local ui: CanvasGroup

local mapName: string?

local regenThread: thread?
local regenTween: Tween?
local depleteTween: Tween?
local __t: thread?

local function characterAdd(char: Model)
	local hum = char:WaitForChild("Humanoid", 6)

	if not hum then
		return
	end

	if not hum:IsA("Humanoid") then
		return
	end

	if con then
		con:Disconnect()
		con2:Disconnect()
		con3:Disconnect()
	end
	if __t then
		task.cancel(__t)
	end

	if regenThread then
		task.cancel(regenThread)
	end

	--health stuff
	--reset stuff to defaults
	local health = hum.Health
	local max = hum.MaxHealth

	ui.Health.Bar.BackgroundColor3 = Color3.fromHSV(BASE_HUE, BASE_SAT, BASE_VALUE)
	ui.Health.Info.Numbers.Text = string.format(" %d/%d", health, max)
	ui.Health.Bar.Size = UDim2.fromScale(1, 1)

	con = hum.Changed:Connect(function(property: string)
		if property == "Health" then
			local health = hum.Health
			local max = hum.MaxHealth

			local scale = health / max
			local hue = scale * BASE_HUE
			ui.Health.Bar.BackgroundColor3 = Color3.fromHSV(math.max(hue, 0), BASE_SAT, BASE_VALUE)

			ui.Health.Info.Numbers.Text = string.format(" %d/%d", health, max)
			TweenService:Create(ui.Health.Bar, info, { Size = UDim2.fromScale(scale, 1) }):Play()
		elseif property == "MaxHealth" then
			local health = hum.Health
			local max = hum.MaxHealth

			ui.Health.Info.Numbers.Text = string.format(" %d/%d", health, max)
		end
	end)

	--stamina stuff
	local staminaBar = ui.Stamina.InnerBars :: CanvasGroup

	if regenTween then
		regenTween:Cancel()
		regenTween = nil
	end

	for _, frame in pairs(staminaBar:GetChildren()) do
		if frame:IsA("Frame") then
			frame.BackgroundTransparency = 0
		end
	end

	local charges = 5

	con2 = hum.Jumping:Connect(function(state: boolean)
		if state then
			hum:SetStateEnabled(Enum.HumanoidStateType.Jumping, false)

			if __t then
				task.cancel(__t)
				__t = nil
			end

			local doubleDeplete = false
			if regenThread then
				task.cancel(regenThread)
				regenThread = nil

				if regenTween then
					regenTween:Pause()
					regenTween = nil
				end

				if charges > 5 then
					return
				end

				local oob = (charges + 1) > 5

				if not oob then
					local prevBar = staminaBar[tostring(charges + 1)] :: Frame
					local transparency = prevBar.Transparency
					local t_modifier = math.abs(prevBar.BackgroundTransparency - 1)
					TweenService:Create(
						prevBar,
						TweenInfo.new(
							depleteBarInfo.Time * t_modifier,
							depleteBarInfo.EasingStyle,
							depleteBarInfo.EasingDirection
						),
						{ BackgroundTransparency = 1 }
					):Play()

					--if the charge was almost regenerated just use that charge instead
					if transparency < 0.35 then
						return
					end

					doubleDeplete = true
				end
			end

			if charges > 0 then
				local barToDeplete = staminaBar[tostring(charges)] :: Frame
				depleteTween = TweenService:Create(barToDeplete, depleteBarInfo, { BackgroundTransparency = 1 })

				if doubleDeplete then
					task.wait(0.075)
				end

				(depleteTween :: Tween):Play()

				charges = math.clamp(charges - 1, 0, 5)
			end
		end
	end)

	con3 = hum.StateChanged:Connect(function(old: Enum.HumanoidStateType, new: Enum.HumanoidStateType)
		if
			new == Enum.HumanoidStateType.Swimming
			or new == Enum.HumanoidStateType.Climbing
			or new == Enum.HumanoidStateType.Running
		then
			if regenThread then
				return
			end

			if charges > 0 and not __t then
				__t = task.delay(JUMP_COOLDOWN_TIME, function()
					hum:SetStateEnabled(Enum.HumanoidStateType.Jumping, true)
					__t = nil
				end)
			end

			if charges > 5 then
				charges = 5
				return
			end

			regenThread = task.spawn(function()
				local t = WAIT_UNTIL_REGEN

				--getting up from ragdoll
				if old == Enum.HumanoidStateType.GettingUp then
					t *= 1.5
				--swimming
				elseif new == Enum.HumanoidStateType.Swimming then
					t *= 1.2
				end

				task.wait(t)

				local chargesAdded = 0
				while charges < 5 do
					local barToRegen: Frame = staminaBar[tostring(charges + 1)]

					local bonus = 0
					if chargesAdded > 0 then
						bonus = math.pow(chargesAdded + 0.2, 0.5) - 1
					end

					regenTween = TweenService:Create(
						barToRegen,
						TweenInfo.new(REGEN_TIME - bonus, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
						{ BackgroundTransparency = 0 }
					)

					regenTween:Play()

					task.wait(REGEN_TIME - bonus)

					charges = math.clamp(charges + 1, 0, 5)
					chargesAdded += 1

					hum:SetStateEnabled(Enum.HumanoidStateType.Jumping, true)
				end

				regenThread = nil
			end)
		elseif new == Enum.HumanoidStateType.Ragdoll then
			if regenThread then
				task.cancel(regenThread)
				regenThread = nil
			end
		end
	end)
end

local function setTime(t: number)
	local label: TextLabel = ui.Info1.MapName

	local str = mapName

	if not mapName then
		str = "???"
	end

	label.Text = string.format("%s - %d", str, t)
end

local function changeMapName(name: string)
	mapName = name
end

return function(CoreUI: ScreenGui)
	local main = assets.StaticInterface.Main

	main.Parent = CoreUI
	ui = main
	sendTime.OnClientEvent:Connect(setTime)
	mapChangedEvent.OnClientEvent:Connect(changeMapName)

	if lPlr.Character then
		characterAdd(lPlr.Character)
	end

	lPlr.CharacterAdded:Connect(characterAdd)
end
