local module = {
	allowed = {},

	-- dont touch
	-- remoteEvents
	events = {
		server = {},
		player = {},
	},

	items = {},
}

local sStore = game:GetService("ServerStorage")
local rStore = game:GetService("ReplicatedStorage")
local dsServ = game:GetService("DataStoreService")

local admDs = dsServ:GetDataStore("ADM")

local items = sStore.Assets.Items
local sound = rStore.Assets.Admin.explod

--PLAYER EVENTS--

function module.events.player.Explode(plr: Player)
	local char = plr.Character

	if not char then
		return
	end

	local hrp = char:FindFirstChild("HumanoidRootPart")

	if not hrp then
		return
	end

	local soundclone = sound:Clone()
	soundclone.Parent = hrp
	soundclone:Play()

	local ex = Instance.new("Explosion")
	ex.BlastPressure = 900000
	ex.ExplosionType = Enum.ExplosionType.NoCraters
	ex.Position = hrp.Position
	ex.BlastRadius = 40
	ex.Parent = hrp
	ex.Hit:Connect(function(hit)
		local hum = hit.Parent:FindFirstChildOfClass("Humanoid")
		if hum then
			hum:TakeDamage(hum.Health + 1)
		end
	end)

	local hum = char:FindFirstChildWhichIsA("Humanoid")

	if hum then
		hum.Health = 0
	end

	task.wait(sound.TimeLength)
	soundclone:Destroy()
	ex:Destroy()
end

function module.events.player.GrantAdmin(plr: Player)
	local suc = pcall(function()
		return admDs:SetAsync(plr.UserId, true)
	end)

	if not suc then
		warn("adm grant failed")
	end
end

function module.events.player.RevokeAdmin(plr: Player)
	local suc = pcall(function()
		print("setasync")
		return admDs:SetAsync(plr.UserId, false)
	end)

	if not suc then
		warn("adm revoke failed")
	else
		table.remove(module.allowed, plr.UserId)

		local ui = plr.PlayerGui:FindFirstChild("Lah")

		if ui then
			ui:Destroy()
		end
	end
end

--PLAYER FUNCTIONS--

function module.events.player.GiveItem(plr: Player, item: string)
	local find = module.items[item]

	if find then
		local clone = find:Clone()
		clone.Parent = plr.Backpack

		local init = require(clone:WaitForChild("GiveGear").Init)

		coroutine.wrap(init.OnToolGranted)(plr)

		return
	end
end

--SERVER EVENTS--

--function module.events.server.ChangeGravity()
--	if workspace.Gravity == 75 then
--		workspace.Gravity = 10
--	else
--		workspace.Gravity = 75
--	end
--end

-- OTHER --
function module.Init(plr: Player)
	table.insert(module.allowed, plr.UserId)

	for _, item in pairs(items:GetDescendants()) do
		if item:IsA("Tool") then
			module.items[item.Name] = item
		end
	end

	return true
end

return module
