achievements = {}

achievementsquads = {}

function loadAchievementsData()
	achievementsData = 
	{
		{name = "Spacing out", description = "Defeat the giant Space Bat", internal = "batbosskilled"},
		{name = "Risky battle", description = "Defeat Risky Jacques", internal = "raccoonkilled"},
		{name = "Phoenix fizzler", description = "Defeat the Space Phoenix", internal = "phoenixkilled"},
		{name = "Easy as pie", description = "Clear the game on Easy", internal = "gameclearedeasy"},
		{name = "Average gamer", description = "Clear the game on Medium", internal = "gameclearedmedium"},
		{name = "Hardship trial", description = "Clear the game on Hard", internal = "gameclearedhard"},
		{name = "Murder time, fun time!", description = "Kill 1000 bats", internal = "batskilled"},
		{name = "Combo madness", description = "Get a 7-hit combo", internal = "combomadness"},
		{name = "Super Turtle", description = "Do not lose a life", internal = "noliveslost"},
		{name = "Spaaaaace", description = "Shoot the space core", internal = "coreshot"},
		{name = "Healing helper", description = "Revive a team mate", internal = "revivedmember"},
		{name = "Two bats, one laser", description = "Kill two bats with one laser", internal = "doublekill"},
		{name = "For science, you monster", description = "Kill 7 bats with one space laser", internal = "forscience"},
		{name = "Cease fire", description = "Kill a bat before they can shoot", internal = "ceasefire"},
	}

	for k = 1, #achievementsData do
		local v = achievementsData[k]
		achievements[v.internal] = achievementUI:new(k, v.name, v.internal, false, v.description, v.count)
	end

	if love.filesystem.exists("saveData.txt") then
		loadData("achievements")
	end
end

class "achievementUI" {}

function achievementUI:__init(quadi, text, name, loaded, describe)
	self.oldfont = love.graphics.getFont()
	self.spacing = 2
	self.graphicWxH = 32
	self.graphicoutlineWxH = 32

	self.x = 600 - self.spacing - self.spacing - self.graphicWxH - self.spacing - self.spacing - self.spacing
	self.y = 300 - self.spacing - self.spacing - self.graphicWxH - self.spacing
	
	self.width = self.spacing + self.graphicWxH + self.spacing + self.spacing + self.spacing + self.spacing
	self.height = self.spacing + self.graphicWxH + self.spacing

	self.rectColor = {255, 255, 255, 255}

	self.graphic = love.graphics.newImage("gfx/achievement/achievements.png")

	self.name = name
	self.text = text
	self.flashytimer = 0 --gonna do a Sine function for this
	self.color = {255, 255, 255, 255}
	self.unlocked = false

	self.scrollx = 0
	self.scrolly = -(self.height)

	self.imgGray = love.graphics.newImage(makeImageGray(love.image.newImageData("gfx/achievement/achievements.png")))
   	self.timer = 0
   	self.fade = 1
   	self.quad = achievementsquads
   	self.quadi = quadi
   	self.loaded = loaded
   	self.description = describe
   	self.unlockDate = "" 
   	self.offset = 0
   	self.i = 0
end

function unlockAchievement(identifier)
	if achievements[identifier] then
		local self = achievements[identifier]

		if not self.unlocked then
			self.unlockDate = os.date("%x %X")
		
			self.unlocked = true

			saveData("achievements")

			self.i = self.i + 1

			
		end
	end
end

function achievementUI:update(dt)
	if self.unlocked and not self.loaded then
		if self.scrolly < 0 then
			self.scrolly = math.min(300-self.height, self.scrolly + 200 * dt)
		else
			self.scrolly = 0
		end

		if self.scrolly == 0 and self.scrollx == 0 then
			self.timer = self.timer + dt 

			if self.timer > 2 then
				self:fadeout(dt)
			end
		end

		if self.fade == 0 then
			return
		end

		if self then
			for k, v in pairs(achievements) do
				if v.unlocked then
					if v.fade == 0 then
						self.i = self.i - 1
					end
				end
			end
			self.offset = math.max(0, self.height*(self.i-1))
		end
	else 
		return
	end
end

function achievementUI:fadeout(dt)
	self.fade = math.max(0, self.fade-dt/0.3)
end

function achievementUI:draw()
	if self.unlocked and not self.loaded then
		local text = self.text

			--FONT STUFF
		love.graphics.setFont(font3)

		love.graphics.push()

		love.graphics.translate(-self.scrollx, -self.scrolly-self.offset)
				
			--background
		love.graphics.setColor(32, 32, 32, 255*self.fade)
		love.graphics.rectangle("fill", self.x * scale - font3:getWidth(text), self.y * scale, self.width * scale + font3:getWidth(text), self.height * scale)

			--image!
		if self.graphic then
			love.graphics.setColor(255, 255, 255, 255*self.fade)
			love.graphics.draw(self.graphic, self.quad[self.quadi], (self.x+self.spacing) * scale - font3:getWidth(text), (self.y+self.spacing) * scale, 0, scale, scale)
		end

		--[[love.graphics.setColor(self.color[1], self.color[2], self.color[3], self.color[4]*self.fade)
		love.graphics.rectangle("line", (self.x+self.spacing) * scale, (self.y+self.spacing) * scale, self.graphicoutlineWxH * scale, self.graphicoutlineWxH * scale)
]]
			--draw text
		love.graphics.setColor(255, 255, 255, 255*self.fade)
		love.graphics.print(self.text, (self.x+self.spacing+self.graphicWxH+self.spacing+self.spacing) * scale - font3:getWidth(text), (self.y+(self.height/2)+self.spacing) * scale - (font3:getHeight(self.text)/2))

			--white border thingy
		love.graphics.rectangle("line", self.x * scale - font3:getWidth(text), self.y * scale, self.width * scale + font3:getWidth(text), self.height * scale)

		love.graphics.pop()

		--more font stuff
		love.graphics.setFont(self.oldfont)
	else 
		return
	end
end