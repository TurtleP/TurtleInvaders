player = class("player")

function player:init(characterData)
	self.name = characterData.name

	self.width = characterData.width
	self.height = characterData.height

	self.graphic = characterData.graphic

	self.x = 200 - self.width / 2
	self.y = util.getHeight()

	self.initialize = false

	self.active = true

	self.speedx = 0
	self.speedy = 0

	self.maxSpeedx = 200

	self.gravity = 0

	self.shootingTimer = 1/2

	self.mask =
	{
		["barrier"] = true,
		["bat"] = true
	}

	self.maxHealth = 3
	self.health = self.maxHealth

	self.ability = dofile("characters/" .. self.name .. "/" .. characterData.ability .. ".lua")

	if self.ability.passive then
		self.ability:init(self)
	end

	self.powerup = "none"

	self.invincible = false
	self.invincibleTimer = 0
	self.shouldDraw = true

	self.isAnimated = characterData.animated
	self.animationTimer = 0
	self.animationQuadi = 1
end

function player:update(dt)
	if not self.initialize then
		if self.y > util.getHeight() - self.height then
			self.speedy = - 120
			return
		else
			self.initialize = true
			self.speedy = 0
		end
	end

	self.shootingTimer = math.max(self.shootingTimer - dt, 0)

	local speed = 0
	if self.leftkey then
		speed = -self.maxSpeedx
	elseif self.rightkey then
		speed = self.maxSpeedx
	end
	self.speedx = speed

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
end

function player:draw()
	love.graphics.setDepth(-0.25)

	if not self.shouldDraw then
		return
	end

	love.graphics.draw(self.graphic, self.x, self.y)

	love.graphics.setDepth(0)
end

function player:upCollide(name, data)
	if name == "bat" then
		return true
	end
end

function player:downCollide(name, data)
	if name == "bat" then
		return true
	end
end

function player:leftCollide(name, data)
	if name == "bat" then
		return true
	end
end

function player:rightCollide(name, data)
	if name == "bat" then
		return true
	end
end

function player:moveLeft(move)
	self.leftkey = move
end

function player:moveRight(move)
	self.rightkey = move
end

function player:shoot()
	if self.shootingTimer == 0 then
		if self.powerup == "shotgun" then
			table.insert(objects["bullet"], bullet:new(self.x + (self.width / 2) - 1, self.y - 1, "normal", {-100, -100}))

			table.insert(objects["bullet"], bullet:new(self.x + (self.width / 2) - 1, self.y - 1, "normal", {100, -100}))
		end
		table.insert(objects["bullet"], bullet:new(self.x + self.width / 2 - 1, self.y - 1, "normal", {0, -180}))

		self.shootingTimer = 1/2
	end
end

function player:setPowerup(powerup)
	self.powerup = powerup
end

function player:addLife(add)
	if add < 0 then
		if self.invincible then
			return
		end
		self.invincible = true
	end

	self.health = self.health + add

	if self.health == 0 then
		self.remove = true

		gameCreateExplosion(self)

		gameOver = true
	end
end

function player:getMaxHealth()
	return self.maxHealth
end

function player:getHealth()
	return self.health
end

function player:getPowerup()
	return self.powerup
end