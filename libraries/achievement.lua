local achievement = class("achievement")

local hook = require 'libraries.hook'

local unlockSound = love.audio.newSource("audio/unlock.ogg", "static")
local trophyImage = love.graphics.newImage("data/achievements/trophy.png")
local TROPHY_COLORS =
{
	["bronze"] = {0.804, 0.498, 0.196},
	["silver"] = {0.753, 0.753, 0.753},
	["gold"] = {1, 0.843, 0}
}

function achievement:initialize()
	local items = love.filesystem.getDirectoryItems("data/achievements")

	self.achievements = {}
	self.queue = {}

	for i = 1, #items do
		local subItems = love.filesystem.getDirectoryItems("data/achievements/" .. items[i])
		local folderName = "data/achievements/" .. items[i]

		local info = love.filesystem.getInfo(folderName)

		if not info then
			return
		end

		if (info.type == "directory") then
			for j = 1, #subItems do
				local name = subItems[j]:gsub(".lua", "")
				if subItems[j]:sub(-4) == ".lua" then
					self:register("data/achievements/" .. items[i] .. "/" .. name, items[i])
				end
			end
		end
	end

	self.font = love.graphics.newFont("graphics/upheval.ttf", 20)
end

function achievement:register(name, tier)
	local v = require(name)
	
	if v.hook and v.source then
		local func =_G[v.source.class][v.source.func]
		_G[v.source.class][v.source.func] = hook.add(func, v.hook)
	end

	local struct = 
	{
		data = v, 
		unlocked = false, 
		whiteFade = 1, 
		generalFade = 1, 
		tier = tier,
		timer = 1
	}

	table.insert(self.achievements, struct)
end

function achievement:update(dt)
	for index, achievement in ipairs(self.achievements) do
		if not self.achievements[index].unlocked and achievement.data:isValid() then
			self.achievements[index].unlocked = true
			table.insert(self.queue, self.achievements[index])
		end
	end

	if #self.queue == 0 then
		return
	end

	local achievement = self.queue[1]

	if achievement.whiteFade == 1 then
		unlockSound:play()
	end
	achievement.whiteFade = math.max(achievement.whiteFade - dt / 0.7, 0)

	if achievement.whiteFade == 0 then
		achievement.timer = achievement.timer - dt

		if achievement.timer <= 0 then
			achievement.generalFade = math.max(achievement.generalFade - dt / 0.8, 0)

			if achievement.generalFade == 0 then
				table.remove(self.queue, 1)
			end
		end
	end
end

function achievement:draw()
	if #self.queue == 0 then
		return
	end

	local achievement = self.queue[1]
	if achievement.unlocked then
		love.graphics.setFont(self.font)

		local x, y, color = WINDOW_WIDTH - 240, WINDOW_HEIGHT - 60, TROPHY_COLORS[achievement.tier]

		love.graphics.setColor(color[1], color[2], color[3], 1 * achievement.generalFade)
		love.graphics.draw(trophyImage, x + 8, y + (60 - trophyImage:getHeight()) / 2)

		love.graphics.setColor(1, 1, 1, 1 * achievement.generalFade)
		love.graphics.print(achievement.data.name, x + (8 + trophyImage:getWidth()) + (184 - self.font:getWidth(achievement.data.name)) / 2, y + (60 - self.font:getHeight()) / 2)

		love.graphics.setColor(1, 1, 1, 1 * achievement.whiteFade)
		love.graphics.rectangle("fill", WINDOW_WIDTH - 240, WINDOW_HEIGHT - 60, 240, 60)
	end
end

return achievement:new()