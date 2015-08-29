class "hpbar" {
	x = 0, y = 0, hp = 0
}

function hpbar:__init(hpmax, bossName, parent)
	self.currfont = love.graphics.getFont()
	self.graphic = bosshpbarimg
	self.quad = bosshpquads
	self.x = 600/ 2 - (self.graphic:getWidth()) / 2
	self.y = 60
	self.width = 0
	self.height = 16
	self.name = bossName
	self.font = font2
	self.hp = hpmax
	self.hpmax = hpmax
	self.parent = parent

	self.start = false

	if state == "game" then
		love.audio.stop(audio["menu"])
	end
	playsound("hpfill")
end

function hpbar:damage(bDamage, relay)
	if not self.start or self.invincible or self.parent.invincible then
		return
	end
	
	self.hp = self.hp - bDamage
	self.width = math.max(216*scale*(self.hp/self.hpmax), 0)
	
	if not relay then
		table.insert(onlinetriggers, "bosshit;" .. bDamage .. ";")
	end

	if self.hp%60 == 0 and self.hp > 0 and self.hp < self.hpmax  then
		self.parent.invincible = true
	end
end

function hpbar:update(dt)
	if self.width < 0 then
		self.width = 0
	end
	
	if not self.start then
		if self.width < 216 then
			self.width = self.width + 120*dt
		else 
			self.start = true
		end
	end
end

function hpbar:draw()
	love.graphics.setFont(self.font)
	love.graphics.draw(self.graphic, self.quad[1], self.x * scale, self.y * scale, 0, scale, scale)

	love.graphics.setScissor(self.x * scale, self.y * scale, self.width * scale, self.height * scale)
	love.graphics.draw(self.graphic, self.quad[2], self.x * scale, self.y * scale, 0, scale, scale)
	love.graphics.setScissor()

	love.graphics.print(self.name, (600/2) * scale - self.font:getWidth(self.name) / 2, (self.y - 16) * scale)
	love.graphics.setFont(self.currfont)
end