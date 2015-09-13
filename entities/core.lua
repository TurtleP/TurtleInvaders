class "core" {
	
}

local corepos = {-24, 576}
local coreypos = {-24, 126, 276}

function core:__init()
	local posx = 0
	local posy = 0

	self.x = posx
	self.y = posy
	self.width = 24
	self.height = 24

	self.startx = posx
	self.starty = posy

	self.rotation = 0
	self.shot = false 
	self.maxspeed = 180
	if posx > (600 * scale) / 2 then
		self.maxspeed = -180
	end

	self.dir = math.atan( (self.starty - 300) / (self.startx - 600) )

	self.emancipateCheck = true

	self.speedx, self.speedy = self.maxspeed, self.maxspeed
end

function core:draw()
	love.graphics.setColor(255, 255, 255)
	love.graphics.draw(graphics["SPAAAAAAAAAAAACE!"], (self.x+12)*scale, (self.y+12)*scale, self.rotation, scale, scale, 12, 12)
	love.graphics.setColor(255, 255, 255)
end

function core:shotPrize(ply)
	if not self.shot then
		addScore(1500)
		ply:addLife(3)
		
		unlockAchievement("coreshot")
		
		self.shot = true 
	end
end

function core:update(dt)
	
	self.x = self.x + math.cos(self.dir) * self.maxspeed * dt
	self.y = self.y + math.sin(self.dir) * self.maxspeed * dt

	self.rotation = self.rotation + 2*dt

	for k, v in pairs(objects["turtle"]) do
		if CheckCollision(self.x, self.y, self.width, self.height, v.ui.x, v.ui.y, v.ui.width, v.ui.height) then
			v.ui:FadeIn()
		else 
			v.ui:FadeOut()
		end
	end
end