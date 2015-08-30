class "powerup" {
	x, y
}

function powerup:__init(x, y, t)
	self.x = x
	self.y = y
	self.t = t or "shotgun"
	self.width = 16
	self.height = 16
	self.kill = false
	self.draws = true

	self.speedy = 60
	self.speedx = 0

	self.graphic = powerupsimg
	self.quad = powerupquads
	self.quadno = self:getQuad(self.t)

	self.emancipateCheck = true
end

function powerup:update(dt)
	self.y = self.y + self.speedy*dt
	
	if self.y > love.graphics.getWidth() then
		self.kill = true
	end

	for k, v in pairs(objects["turtle"]) do
		if CheckCollision(self.x, self.y, self.width, self.height, v.ui.x, v.ui.y, v.ui.width, v.ui.height) then
			v.ui:FadeIn()
		else 
			v.ui:FadeOut()
		end
	end
end

function powerup:getQuad(types)
	local t = types:lower()

	if t == "none" then
		return 1
	elseif t == "shotgun" then
		return 2
	elseif t == "time" then
		return 3
	elseif t == "shoop" then
		return 4  
	elseif t == "shield" then
		return 5
	elseif t == "laser" then
		return 6
	elseif t == "oneup" then
		return 7
	elseif t == "freeze" then
		return 8
	elseif t == "antiscore" then
		return 9
	elseif t == "nobullets" then
		return 10
	elseif t == "remove" then
		return 11
	else
		return 12
	end
end

function powerup:draw()
	love.graphics.setColor(255, 255, 255, 255)
	love.graphics.draw(self.graphic, self.quad[self.quadno], self.x*scale, self.y*scale, 0, scale, scale)
	love.graphics.setColor(255, 255, 255)
end

class "shoop" {
	x, y, t
}

function shoop:__init(x, y, p)
	self.x = x
	self.y = 0
	self.parent = p
	self.kill = false
	self.quadnox = 1
	self.quadnoy = 1
	
	self.beamquadno = 0
	self.width = 22
	self.height = p.y
	self.timer = 0

	self.basex = 1
	self.basey = 1

	self.batskilled = 0
end

function shoop:onCollide(name, data)
	if data.emancipateCheck then
		--NEW EMANCIPATION!
		if self.quadnoy == 3 or self.quadnoy == 4 then
			if data.emancipate then
				data:emancipate()
			end
				
			earthquake = 40
			playsound("evaporate")

			addScore(100)
				
			table.insert(fizzles, fizzle:new(data))

			if name == "enemies" then
				self.batskilled = self.batskilled + 1
				if self.batskilled == 7 then
					unlockAchievement("forscience")
					self.batskilled = 0
				end
			end

			data.kill = true
		end
	end
end

function shoop:update(dt)
	self.x = (self.parent.x+(self.parent.width/2)-22/2)

	if self.parent.ui.megacannonthing then
		self.timer = self.timer + 18*dt
		if self.quadnox < 6 then
			self.quadnox = math.floor(self.timer%6)+1
		else
			if self.quadnoy < 3 then
				self.quadnoy = self.quadnoy + 1
			end
		end

		if self.timer > 5 then
			self.beamquadno = math.floor(self.timer%6)+1
			if self.basex < 6 then
				self.basex = math.floor(self.timer%6)+1
			else
				if self.basey < 2 then
					self.basey = self.basey + 1
					self.beamquadno = 1
				else 
					self.basey = 1
					self.beamquadno = 1
				end
			end
		end

		if self.beamquadno > 4 then
			self.beamquadno = 1
		end

		if self.basex > 1 and self.basey == 2 then
			self.basex = 1
			self.basey = 1
			self.beamquadno = 1
		end
	else
		self.kill = true
	end

	for k, v in pairs(objects["turtle"]) do
		if CheckCollision(self.x, self.y, self.width, self.height, v.ui.x, v.ui.y, v.ui.width, v.ui.height) then
			v.ui:FadeIn()
		else 
			v.ui:FadeOut()
		end
	end
end

function shoop:draw()
	love.graphics.setColor(255, 255, 255, 255)
	if self.parent.ui.megacannonthing and self.parent.ui.poweruptimer > 0 then
		love.graphics.draw(shoopcharge, shoopchargequads[self.quadnox][self.quadnoy], (self.parent.x+(self.parent.width/2)-80/2) * scale, (self.parent.y-60)*scale, 0, scale, scale)
		
		if self.timer > 5  then
			love.graphics.draw(shoopbase, shoopbasequads[self.basex][self.basey], (self.parent.x+(self.parent.width/2)-80/2) * scale, (self.parent.y-60)*scale, 0, scale, scale)
		end
		
		if self.beamquadno > 0 then
			for i = 1, math.floor(math.abs(self.y-self.height)/22) do
				love.graphics.draw(shoopbeam, shoopbeamquads[self.beamquadno], (self.parent.x+(self.parent.width/2)-22/2) * scale, ((self.parent.y-82)-(i-1)*22)*scale, 0, scale, scale)
			end
		end
	end
	love.graphics.setColor(255, 255, 255, 255)
end

class "shield" {}

function shield:__init(parent)
	playsound("shield")

	self.x = parent.x
	self.y = parent.y

	self.parent = parent

	self.shieldimg = parent.char.shieldimg
	self.shieldin = parent.char.shieldin

	self.shieldoutquadcount = parent.char.shieldoutquadcount
	self.shieldinquadcount = parent.char.shieldinquadcount

	self.shieldInSpeed = parent.char.shieldInSpeed

	self.shieldOutSpeed = parent.char.shieldOutSpeed
	self.shieldout = parent.char.shieldout

	self.shieldinquads = parent.char.shieldinquads
	self.shieldoutquads = parent.char.shieldoutquads

	self.state = "normal"

	self.width = self.shieldimg:getHeight()
	self.height = self.shieldimg:getHeight()

	self.shieldquads = parent.char.shieldquads
	self.maxshieldquads = self.parent.char.shieldquadcount or 1
	self.shieldAnimSpeed = self.parent.char.shieldAnimSpeed

	if self.shieldquads then
		if self.shieldin and self.shieldout then
			self.state = "in"
			self.width = self.parent.char.shieldinwidth
			self.height = self.parent.char.shieldinheight
			self.maxshieldquads = self.parent.char.shieldinquadcount
		else
			if self.parent.char.shieldAnimSpeed then
				self.width = self.parent.char.shieldwidth
				self.height = self.parent.char.shieldheight
			end
		end
	else
		self.width = self.shieldimg:getWidth()
		self.height = self.shieldimg:getHeight()
	end

	self.offset = 0

	self.powerupanimtimer = 0
	self.powerupquad = 1
end

function shield:update(dt)
	self.x, self.y = (self.parent.x + (self.parent.width / 2)) - self.width / 2, (self.parent.y + (self.parent.height / 2)) - self.height / 2

	if self.state == "in" then
		if self.parent.ui.poweruptimer < self.shieldOutSpeed*self.shieldoutquadcount then
			if self.state == "normal" then
				self.width = self.parent.char.shieldoutwidth
				self.height = self.parent.char.shieldoutheight
				self.maxshieldquads = self.parent.char.shieldoutquadcount
				self.state = "out"
			end
		else
			if state == "in" then
				self.width = self.parent.char.shieldinwidth
				self.height = self.parent.char.shieldinheight
				self.maxshieldquads = self.parent.char.shieldinquadcount
				self.state = "normal"
			end
		end
	end

	self.powerupanimtimer = self.powerupanimtimer + dt
	local off = 0
	if self.shieldin then
		off = self.shieldInSpeed*self.shieldinquadcount
	end
	self.powerupquad = math.floor(((self.powerupanimtimer+off)/self.shieldAnimSpeed)%self.maxshieldquads)+1

	if self.x < 0 then
		self.offset = 600
	elseif self.x + self.width > 600 then
		self.offset = -600
	end
end

function shield:draw()
	self:drawProper(0)
	if self.offset ~= 0 then
		self:drawProper(self.offset)
	end
end

function shield:drawProper(offset)
	if not self.shieldimg or not (self.shieldin and self.shieldout) then
		--return
	end

	if self.shieldin and self.powerupanimtimer < self.shieldInSpeed*self.shieldinquadcount then
		love.graphics.draw(self.shieldin, self.shieldinquads[math.floor(self.powerupanimtimer/self.shieldInSpeed)+1], (self.x + offset) * scale, self.y * scale, 0, scale, scale)
	elseif self.shieldout and self.parent.ui.poweruptimer < self.shieldOutSpeed*self.shieldoutquadcount then
		local ntimer = self.shieldOutSpeed*self.shieldoutquadcount - self.parent.ui.poweruptimer
		love.graphics.draw(self.shieldout, self.shieldoutquads[math.floor(ntimer/self.shieldOutSpeed)+1], (self.x + offset) * scale, self.y * scale, 0, scale, scale)
	else
		if self.shieldquads then
			love.graphics.draw(self.shieldimg, self.shieldquads[self.powerupquad], (self.x + offset) * scale, self.y * scale, 0, scale, scale)
		else
			love.graphics.draw(self.shieldimg, (self.x + offset) * scale, self.y * scale, 0, scale, scale)
		end
	end
end