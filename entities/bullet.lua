class "bullet" {
	x = 0, y = 0, speed = 300
}

function bullet:__init(x, y, speed, xspeed, powerup, parent, dontSound)
	self.x = x
	self.y = y
	self.speedy = speed
	self.id = i
	
	self.speedx = (xspeed or 0)
	self.powerup = powerup or "none"
	self.parent = parent

	local v = powerup

	self.color = {255, 255, 0}
	self.width = 2
	self.height = 2

	if v == "laser" then
		self.width = 2
		self.height = 6
		self.color = {255, 0, 0}
	elseif v == "power" then
		self.width = 9
		self.height = 9
		self.color = {62, 255, 255}
	elseif v == "antiscore" then
		self.color = {178, 0, 255}
	elseif v == "freeze" then
		self.color = {0, 148, 255}
	end
	
	self.rotation = 0
	
	local s = "shoot"
	if v == "laser" then
		s = "laser"
	elseif v == "power" then
		s = "powershot"
	end

	if not dontSound then
		playsound(s)
	end

	self.emancipateCheck = true

	self.batskilled = 0
end

function bullet:onCollide(name, data)
	if name == "bullets" then
		data:destroy()
		self:destroy()
	end

	if self.parent.type == "player" then
		if name == "phoenixfire" then
			self:destroy()
		end

		if name == "core" then
			data:shotPrize(self.parent)
			self:destroy()
		end

		if name == "boss" then
			if not data.invincible then
				data.hpbar:damage(2)
			end

			if self.powerup ~= "laser" then
				self:destroy()
			end
		end

		if name == "phoenixshield" then
			if data.quadno == #shieldanims then
				data:shotted()
			end
			
			if data.hits == 0 then
				self:dissolveShield(data, dt)
			end
			
			self:destroy()
		end
	end

	if self.parent.type == "boss" then
		if name == "turtle" then
			if data.powerup:lower() ~= "shield" then
				data:addLife(-1)
				self:destroy()
			else 
				self:destroy()
			end
		end
	end
end

function bullet:draw()
	love.graphics.setColor(self.color)

	if self.powerup:lower() ~= "power" then
		love.graphics.rectangle("fill",self.x*scale,self.y*scale, self.width*scale, self.height*scale)
	else
		love.graphics.circle("fill",self.x*scale,self.y*scale, 9*scale)
	end
	
	love.graphics.setColor(255, 255, 255)
end

function bullet:update(dt)
	if self.parent.type == "enemy" then
		for k, v in pairs(objects.turtle) do
			if v.powerup:lower() == "time" then
				dt = math.min(dt/2, dt)
			end
		end
	end
	
	self.y = self.y + (self.speedy * dt )
	
	self.x = self.x + (self.speedx * dt )
	
	if self.y > gameH or self.y < 0 then
		if self.parent.type == "player" and (self.powerup ~= "laser" and self.powerup ~= "shotgun") then
			combo = 0
		end
		self:destroy()
	end

	for k, v in pairs(objects["turtle"]) do
		if CheckCollision(self.x, self.y, self.width, self.height, v.ui.x, v.ui.y, v.ui.width, v.ui.height) then
			v.ui:FadeIn()
		else 
			v.ui:FadeOut()
		end
	end
end

function dist(x1, y1, x2, y2, ab)
	local ab = ab or "absolute" --true by default
	local width = x2-x1
	local height = y2-y1
	if ab == "absolute" then
		width = math.abs(width)
		height = math.abs(height)
	end
	return math.sqrt(width^2+height^2)
end

function bullet:dissolveShield(shield, dt)
	local shieldX = shield.x+shield.width/2
	local shieldY = shield.x+shield.height/2
	local shieldSize = math.max(shield.width/2, shield.height/2)
	local lastDist = dist(self.x, self.y, shieldX, shieldY)
	local x = self.x
	local y = self.y
	
	local loop = true
	local can = 0
	while loop == true do
		can = can + 1/60
		local newx, newy = x+self.xspeed*dt, y+self.speed*dt
		currentDist = dist(newx, newy, shieldX, shieldY)
		if currentDist <= shieldSize or currentDist > lastDist then --or inside or as close as possible
			x = newx
			y = newy
			loop = false
		end
		lastDist = currentDist
	end
	
	shield.shieldAnim.time = shieldAnim.maxtime --A test with timers...
	shield.shieldAnim.alive = true
	shield.shieldAnim.x = x
	shield.shieldAnim.y = y
end

function bullet:destroy(data)
	self.kill = true
end