--! rewrite by devwingfr 31.03.25
-- added more variables for configuration of the script
-- replaced logic
-- removed redundant parts of the script
-- lines: 113 (compared to original 131)

-->> Services
local runService = game:GetService("RunService")
local tweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")

-->> Variables
local module = {}

local MAX_PERCENT = 1
local MAX_JUMPS = 12
local COOLDOWN_TIME = 1.2
local COOLDOWN_LENGTH = 4

local plr = Players.LocalPlayer

local timeOfJump, timeSinceLastChange = os.time(), nil
local info = TweenInfo.new(0.8, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
local infoCooldown = TweenInfo.new(COOLDOWN_LENGTH, Enum.EasingStyle.Sine, Enum.EasingDirection.In)

local con = nil

-->> Functions
function onMultiplierChanged(humanoid: Humanoid, defaultJumpPower: number, val: number)
	local jfUi = plr.PlayerGui.CC_Core:WaitForChild("Stamina")

	if not jfUi.Visible then
		tweenService:Create(jfUi, info, { Position = UDim2.new(0, 0, 1, 0) }):Play()
		jfUi.Visible = true
	end

	jfUi.Text = `Jump Fatigue - {string.format("%.2f", val * 100)}%`
	jfUi.TextColor3 = Color3.fromHSV(1, math.max(val - 0.2, 0), 1)
	
	humanoid.JumpPower = defaultJumpPower * (1 - val)
	
end

function characterAdded(ch: Model)
	local humanoid = ch:WaitForChild("Humanoid")
	local defaultJumpPower = humanoid.JumpPower
	
	local coolingDown = false
	
	local cooldownMul = Instance.new("NumberValue")
	cooldownMul.Parent = ch
	cooldownMul.Value = 0
	cooldownMul.Name = "JumpFatigue"
	
	cooldownMul.Changed:Connect(function(v)
		onMultiplierChanged(humanoid, defaultJumpPower, v)
	end)
	
	local tween: Tween
	
	local jumpCon = humanoid.Jumping:Connect(function(jumping: boolean)
		if con then con:Disconnect() end
		
		if true then -- this (edit: doesn't) prevents the code from running if currently cooling down
			if jumping then -- on every jump
				timeOfJump = os.time()
			--	print("turkey hopping turkey jumping j")
				if not coolingDown then
					local multiplier = cooldownMul.Value
					local newMultiplier = math.min(MAX_PERCENT, (multiplier^(1/3) + 1/MAX_JUMPS)^3) -- Cubic

					cooldownMul.Value = newMultiplier
				else
					tween:Pause()
					--print("tweening has to stop")
					coolingDown = false
				end
			else
				con = runService.Heartbeat:Connect(function()
					if os.time() - timeOfJump > COOLDOWN_TIME then
						tween = tweenService:Create(cooldownMul, infoCooldown, { Value = 0 })
						tween:Play()
						
						coolingDown = true
						
						tween.Completed:Connect(function()
							con:Disconnect()
							--coolingDown = false
							cooldownEnded()
						end)
					end
				end)
				
			end
		end
		
	end)
	
	humanoid.Died:Once(function()
		cooldownMul:Destroy()
		jumpCon:Disconnect()
		con:Disconnect()
	end)
	
end

function cooldownEnded()
	local jfUi = plr.PlayerGui.CC_Core:WaitForChild("Stamina")
	
	jfUi.Visible = false
end

function module.Start()
	plr.CharacterAdded:Connect(characterAdded)
end

return module
