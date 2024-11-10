--> Services
local rStore = game:GetService("ReplicatedStorage")

--> Deps
local Rcade = require(rStore.Shared.Rcade)
local tagData = require(script.Parent.Tags)

--> Class Definition
local ACPlayer = Rcade.class({})

--> Constructor
function ACPlayer:__init(plr: Player, acservice)
	self["Player"] = plr
	self["Tags"] = {}
end

--> Module Functions
function ACPlayer:AddOrIncrementTag(category: string, tag: string)
	if self.Tags[tag] then
		local tagCategoryData = tagData[category]
		local _t: number = self.Tags[tag]
		warn(self.Player.Name, tag, _t)

		local specificTagData = tagCategoryData[tag]

		if _t + 1 >= specificTagData.Limit then
			self.Player:Kick(specificTagData.KickMessage or tagData.DefaultKickMessage)
			self:Destroy()
		else
			self.Tags[tag] += 1
			if specificTagData.DecayTime then
				task.delay(specificTagData.DecayTime, function()
					self.Tags[tag] -= 1
				end)
			end
		end
	else
		self.Tags[tag] = 1
	end
end

function ACPlayer:Destroy()
	self.Player = nil
end

return ACPlayer
