--> Services
local runServ = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local tServ = game:GetService("TweenService")
local Players = game:GetService("Players")

--> Variables
local module = {}

local plr = Players.LocalPlayer

local timeSinceLastJump, timeSinceLastChange = os.time(), nil

local info = TweenInfo.new(0.8, Enum.EasingStyle.Quint, Enum.EasingDirection.In)

local MAX_PERCENT = 1

--> Private Functions
function onCharAdded(char: Model)
	local hum = char:WaitForChild("Humanoid")
	local defaultJP = hum.JumpPower

	local cooldownMul = Instance.new("NumberValue")
	cooldownMul.Parent = char
	cooldownMul.Value = 0
	cooldownMul.Name = "StaminaFautige"

	--cooldownMul.Changed:Connect(multiplierChanged)

	local jumpCon = UIS.JumpRequest:Connect(function()
		local diff = defaultJP * cooldownMul.Value

		hum.JumpPower = defaultJP - diff
	end)

	local humJumpCon = hum.Jumping:Connect(function(jumping: boolean)
		if con then
			con:Disconnect()
		end
		if jumping then
			timeSinceLastJump = os.time()
			--math.pow(cooldownMul.Value + 0.0875, 1.08)
			local result = -math.log10(-math.pow(cooldownMul.Value, 2.5) + 1.1) + 0.0875

			cooldownMul.Value = math.clamp(cooldownMul.Value + result, 0, MAX_PERCENT)

			multiplierChanged(cooldownMul.Value)
		else
			con = runServ.Heartbeat:Connect(function(dt)
				if os.time() - timeSinceLastJump >= 1.35 then
					local diff: number

					if cooldownMul.Value <= 0.2 then
						diff = cooldownMul.Value / 15 + 0.0005
					else
						diff = (cooldownMul.Value / 2 + 0.0025) * dt
					end

					cooldownMul.Value = math.max(cooldownMul.Value - diff, 0)

					multiplierChanged(cooldownMul.Value)
				end

				if cooldownMul.Value <= 0 then
					con:Disconnect()
				end
			end)
		end
	end)

	hum.Died:Once(function()
		cooldownMul:Destroy()
		jumpCon:Disconnect()
		humJumpCon:Disconnect()
	end)
end

function multiplierChanged(val: number)
	local jfUi = plr.PlayerGui.CC_Core:WaitForChild("Stamina")

	if not jfUi.Visible then
		tServ:Create(jfUi, info, { Position = UDim2.new(0, 0, 1, 0) }):Play()
		jfUi.Visible = true
	end

	if tweenCon then
		tweenCon:Disconnect()
	end

	timeSinceLastChange = os.time()

	jfUi.Text = `Jump Fatigue - {string.format("%.2f", val * 100)}%`

	jfUi.TextColor3 = Color3.fromHSV(1, math.max(val - 0.2, 0), 1)

	tweenCon = runServ.Heartbeat:Connect(function(dt)
		if os.time() - timeSinceLastChange >= 1.5 then
			local t = tServ:Create(jfUi, info, { Position = UDim2.new(0, 0, 1.1, 0) })
			t:Play()
			t.Completed:Wait()
			jfUi.Visible = false
		end
	end)
end

--> Module Functions

--> Loader Methods

function module.Start()
	plr.CharacterAdded:Connect(onCharAdded)
end

return module
