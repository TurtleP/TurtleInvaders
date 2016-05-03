local batAbilities =
{
	{"shoot", 2},
	{"powerup", 8},
	{"circle", 14}
}

local batPowerups =
{
	{"none", 2},
	{"shotgun", 6},
	{"laser", 10},
	{"freeze", 14}
}

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

	if not objects then
		return
	end

	local health = 1
	if currentWave > 3 then
		health =  love.math.random(2)
	elseif currentWave > 6 then
		health = love.math.random(3)
	end

	local ability = batAbilities[love.math.random(#batAbilities)]
	if currentWave >= ability[2] then
		self.ability = ability[1]
	end

	self.bulletTimer = love.math.random(1, 2)
	self.angle = 0
	
	if self.ability == "shoot" then
		local powerup = batPowerups[love.math.random(#batPowerups)]

		if currentWave >= powerup[2] then
			self.powerup = powerup[1]

			if self.powerup == "laser" then
				self.powerupColor = {255, 73, 56}
			elseif self.powerup == "freeze" then
				self.powerupColor = {44, 130, 201}
			end
		end
	end

	if self.ability == "circle" then
		self.mask["barrier"] = false
	end

	self.maxHealth = health
	self.health = self.maxHealth

	self.setSpeeds = false
end

function bat:update(dt)
	if objects then
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

		if self.ability == "shoot" then
			if self.bulletTimer > 0 then
				self.bulletTimer = self.bulletTimer - dt
			else
				self:shoot()
			end
		end

		if self.ability == "circle" then
			self.angle = self.angle + 5 * dt

			self.x = self.x + math.cos(self.angle) * 2
			self.y = self.y + math.sin(self.angle) * 2
		end
	end
	
	self.timer = self.timer + 8 * dt
	self.quadi = math.floor(self.timer % 3) + 1

	if self.y > util.getHeight() then
		self.remove = true
	end
end

function bat:draw()
	love.graphics.setColor(255, 255, 255)
	love.graphics.draw(batImage, batQuads[self.quadi][1], self.x, self.y)

	love.graphics.setColor(unpack(self.powerupColor))
	love.graphics.draw(batImage, batQuads[self.quadi][2], self.x, self.y)
	
	love.graphics.setColor(255, 255, 255)
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

function bat:shoot()
	if self.powerup == "shotgun" then
		table.insert(objects["bullet"], bullet:new(self.x + (self.width / 2) - 1, self.y + self.height, "normal", {-100, 120}))
		
		table.insert(objects["bullet"], bullet:new(self.x + (self.width / 2) - 1, self.y + self.height, "normal", {0, 120}))
		
		table.insert(objects["bullet"], bullet:new(self.x + (self.width / 2) - 1, self.y + self.height, "normal", {100, 120}))
	else
		table.insert(objects["bullet"], bullet:new(self.x + (self.width / 2) - 1, self.y + self.height, self.powerup, {0, 120}))
	end

	self.bulletTimer = love.math.random(1, 2)
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

	self.remove = true

	if not objects["player"][1].ability.passive then
		abilityKills = util.clamp(abilityKills + 1, 0, objects["player"][1]:getMaxHealth() * 2)
	end

	gameCreateExplosion(self)

	if player then
		player:addLife(-1)
		return
	end

	batKillCount = batKillCount + 1

	comboValue = comboValue + 1
	comboTimeout = 0

	gameAddScore(10)

	if self.bulletTimer > 0 and self.bulletTimer < 0.2 then
		achievements[9]:unlock(true)
	end

	local oneup = false
	if batKillCount % 20 == 0 then
		oneup = true
	end

	gameDropPowerup(self.x + (self.width / 2) - 9, self.y + (self.height / 2) - 9, oneup)
end