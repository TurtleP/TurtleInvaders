megabat = class("megabat")

function megabat:init()
	self.x = 170
	self.y = -bossImage:getHeight()

	self.width = 60
	self.height = 30

	self.active = true

	self.mask =
	{
		["bullet"] = true,
		["barrier"] = true
	}

	local speeds = {-120, 120}
	self.speedx = speeds[love.math.random(#speeds)]
	self.speedy = 0

	self.gravity = 0

	self.timer = 0
	self.quadi = 1

	menuSong:stop()
	menuSong = nil

	createSong("boss")
	bossSong:play()

	local health = 60
	if difficultyi > 1 then
		health = 60 + (difficultyi - 1) * 40
	end

	self.realHealth = health 
	self.realMaxHealth = self.realHealth

	self.health = self.realMaxHealth / 20
	self.maxHealth = self.health

	self.initialize = false

	displayInfo:setEnemyData(self)

	self.invincible = false
	self.invincibleTimer = 0

	self.shouldDraw = true

	self.shootTimer = love.math.random(3)
	self.deathDelay = 0.05

	self.fade = 1
end

function megabat:update(dt)
	if self.dead then
		if self.fade > 0 then
			if self.deathDelay > 0 then
				self.deathDelay = self.deathDelay - dt
			else
				table.insert(explosions, explosion:new(love.math.random(self.x, self.x + self.width), love.math.random(self.y, self.y + self.height)))
				self.deathDelay = 0.05
			end
			self.fade = math.max(self.fade - 0.6 * dt, 0)
		else
			bossSong:stop()
			bossSong = nil

			createSong("menu")
			menuSong:play()

			gameAddScore(1000)

			gameDropPowerup(self.x + self.width / 2 - 9, self.y + (self.height / 2) - 9, true, true)

			enemyTimer:setTimeLimit(1)

			self.remove = true
		end
		return
	end

	self.timer = self.timer + 8 * dt
	self.quadi = math.floor(self.timer % #bossQuads) + 1

	if not self.initialize then
		if self.y + (self.height / 2) < util.getHeight() / 2 then
			self.speedy = 100
		else
			self.speedy = 0
			self.initialize = true
		end
	end

	if self.invincible then
		self.invincibleTimer = self.invincibleTimer + 8 * dt

		if math.floor(self.invincibleTimer % 2) == 0 then
			self.shouldDraw = false
		else
			self.shouldDraw = true
		end

		if self.invincibleTimer > 16 then
			self.shouldDraw = true
			self.invincibleTimer = 0
			self.invincible = false
		end
	end

	if self.shootTimer > 0 then
		self.shootTimer = self.shootTimer - dt
	else
		self:shoot()
		self.shootTimer = love.math.random(3)
	end
end

function megabat:leftCollide(name, data)
	if name == "barrier" then
		self.speedx = -self.speedx
		return false
	end
end

function megabat:rightCollide(name, data)
	if name == "barrier" then
		self.speedx = -self.speedx
		return false
	end
end

function megabat:draw()
	if not self.shouldDraw then
		return
	end
	love.graphics.setColor(255, 255, 255, 255 * self.fade)

	love.graphics.draw(bossImage, bossQuads[self.quadi], self.x, self.y)

	love.graphics.setColor(255, 255, 255, 255)
end

function megabat:shoot()
	table.insert(objects["bullet"], bullet:new(self.x + (self.width / 2) - 1, self.y + self.height + 1, "normal", {-100, 100}))

	table.insert(objects["bullet"], bullet:new(self.x + (self.width / 2) - 1, self.y + self.height + 1, "normal", {0, 100}))

	table.insert(objects["bullet"], bullet:new(self.x + (self.width / 2) - 1, self.y + self.height + 1, "normal", {100, 100}))
end

function megabat:getHealth()
	return self.health
end

function megabat:getMaxHealth()
	return self.maxHealth
end

function megabat:takeDamage(damageValue)
	self.realHealth = util.clamp(self.realHealth + damageValue, 0, self.realMaxHealth)

	print(self.realHealth)

	if self.realHealth > 0 then
		if self.realHealth % 20 == 0 then
			self.health = self.health - 1
			self.invincible = true
		end
	else
		self.speedx = 0
		self.dead = true
	end
end