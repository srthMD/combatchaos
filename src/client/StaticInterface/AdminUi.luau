if true then
	return function() end
end

local rStore = game:GetService("ReplicatedStorage")
local tServ = game:GetService("TweenService")

local info = TweenInfo.new(1.2, Enum.EasingStyle.Quint, Enum.EasingDirection.InOut)
local rfunc_getStats = rStore.Signals.Remote.getStats

local db = false

function getStats(ui: Folder)
	local panel = ui:FindFirstChild("Panel")

	if not panel then
		return
	end

	if panel.Visible then
		local serverText = panel.TopBar.ServerInfo

		local data = rfunc_getStats:InvokeServer()

		serverText.FPS.Text = `Server Physics FPS {string.format("%d", data.FPS)}`
		serverText.Instances.Text = `Server Instances  {data.Instances}`
		serverText.Physics.Text = `Server Physics    ↑{string.format("%.2f", data.Physics.Send)} ↓{string.format(
			"%.2f",
			data.Physics.Recv
		)} (KBPS)`
		serverText.Memory.Text = `Server Memory Load {string.format("%.2f", data.Memory)} MB`
	end
end

function toggleUi(ui: Folder)
	local panel = ui:FindFirstChild("Panel")

	if not panel then
		return
	end

	if db then
		return
	end

	db = true

	task.delay(1.2, function()
		db = false
	end)

	if not panel.Visible then
		tServ:Create(panel, info, { Position = UDim2.new(0.5, 0, 0.5, 0) }):Play()
		panel.Visible = true
		panel.Active = true
	else
		local t = tServ:Create(panel, info, { Position = UDim2.new(0.5, 0, -0.5, 0) })
		t:Play()
		t.Completed:Wait()
		panel.Visible = false
		panel.Active = false
	end
end

return function(CoreUI: ScreenGui)
	local adminUI = rStore.Assets.StaticInterface.Admin
	adminUI.Parent = CoreUI
	adminUI.Panel.Position = UDim2.new(0.5, 0, -0.5, 0)
	adminUI.Panel.Visible = false
	adminUI.Panel.Active = false

	adminUI.Toggle.MouseButton1Click:Connect(function()
		toggleUi(adminUI)
	end)

	adminUI.Panel.TopBar.Close.MouseButton1Click:Connect(function()
		toggleUi(adminUI)
	end)

	task.spawn(function()
		while task.wait(1) do
			getStats(adminUI)
		end
	end)
end
