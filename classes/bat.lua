bat = class("bat")

function bat:init(x, y)
	self.x = x
	self.y = y

	self.width = 30
	self.height = 14

	self.speedx = love.math.random(-30, 30)
	self.speedy = love.math.random(30, 90)

	self.staticSpeed = {self.speedx, self.speedy}

	self.powerupColor = {255, 255, 0}

	self.active = true

	self.timer = 0
	self.quadi = 1

	self.gravity = 0

	self.mask =
	{
		["player"] = true,
		["barrier"] = true
	}

	self.maxHealth = love.math.random(2)
	self.health = self.maxHealth

	self.setSpeeds = false
end

function bat:update(dt)
	if objects["player"][1] then
		if objects["player"][1]:getPowerup() == "time" then
			dt = dt / 4

			self.speedx = self.staticSpeed[1] / 2
			self.speedy = self.staticSpeed[2] / 2

			if self.setSpeeds then
				self.setSpeeds = false
			end
		else
			if not self.setSpeeds then
				self.speedx = self.staticSpeed[1]
				self.speedy = self.staticSpeed[2]

				self.setSpeeds = true
			end
		end
	end

	self.timer = self.timer + 8 * dt
	self.quadi = math.floor(self.timer % 3) + 1

	if self.y > util.getHeight() then
		self.remove = true
	end
end

function bat:draw()
	love.graphics.setDepth(0.25)

	love.graphics.setColor(255, 255, 255)
	love.graphics.draw(batImage, batQuads[self.quadi][1], self.x, self.y)

	love.graphics.setColor(unpack(self.powerupColor))
	love.graphics.draw(batImage, batQuads[self.quadi][2], self.x, self.y)
	
	love.graphics.setColor(255, 255, 255)

	love.graphics.setDepth(0)
end

function bat:leftCollide(name, data)
	if name == "barrier" then
		self.speedx = -self.speedx
		return false
	end

	if name == "player" then
		self:die(data)
		return false
	end
end

function bat:rightCollide(name, data)
	if name == "barrier" then
		self.speedx = -self.speedx
		return false
	end

	if name == "player" then
		self:die(data)
		return false
	end
end

function bat:downCollide(name, data)
	if name == "player" then
		self:die(data)
		return false
	end
end

function bat:upCollide(name, data)
	if name == "player" then
		self:die(data)
		return false
	end
end

function bat:getMaxHealth()
	return self.maxHealth
end

function bat:getHealth()
	return self.health
end

function bat:die(player)
	if not player then
		if self.health > 1 then
			self.health = self.health - 1
			return
		end
	end
	
	if displayInfo:getEnemyData() == self then
		displayInfo:setEnemyData(nil)
	end

	explodeSound:play()

	self.remove = true

	gameCreateExplosion(self)

	if player then
		player:addLife(-1)
		return
	end

	batKillCount = batKillCount + 1

	gameAddScore(10)

	local oneup = false
	if batKillCount % 50 == 0 then
		oneup = true
	end

	gameDropPowerup(self.x + (self.width / 2) - 9, self.y + (self.height / 2) - 9, oneup)
end