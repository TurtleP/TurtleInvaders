phoenix = class("phoenix")

function phoenix:init()
	self.x = 168
	self.y = 60

	self.width = 64
	self.height = 50

	self.quadi = 1
	self.timer = 0

	shakeValue = 20

	menuSong:stop()

	bossSong = nil
	collectgarbage()

	finalBossSong = love.audio.newSource("audio/finalboss.ogg")
	finalBossSong:setLooping(true)
	finalBossSong:play()

	local speeds = {-180, 180}
	self.speed = speeds[love.math.random(#speeds)]

	self.speedx = 0
	self.speedy = 0

	local health = 140
	if difficultyi > 1 then
		health = 140 + (difficultyi - 1) * 60
	end

	self.realHealth = health 
	self.realMaxHealth = self.realHealth

	self.health = self.realMaxHealth / 20
	self.maxHealth = self.health

	self.active = true
	self.gravity = 0

	self.initialize = false

	self.mask =
	{
		["barrier"] = true
	}

	self.shotTimer = love.math.random(1, 2)

	self.shield = nil
	self.shieldSpawnTimer = 3

	self.invincible = false
	self.invincibleTimer = 0
	self.shouldDraw = true

	self.killTimer = 3
end

function phoenix:update(dt)
	if not self.initialize then
		if math.floor(shakeValue) == 0 then
			self.speedx = self.speed
			self.initialize = true
		end
	end

	self.timer = self.timer + 8 * dt
	self.quadi = math.floor(self.timer % 3) + 1

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

	if self.shield then
		self.shield:update(dt)
		return
	end

	if not self.killBats then
		self.y = util.clamp(self.y + 120 * dt, -self.height, 60)
		if self.killTimer > 0 then
			self.killTimer = self.killTimer - dt
		else
			self.killTimer = love.math.random(4, 5)
			self.killBats = true
		end
	else
		self.y = util.clamp(self.y - 120 * dt, -self.height, 60)
		if self.y == -self.height then
			if self.killTimer > 0 then
				self.killTimer = self.killTimer - dt
			else
				self.killTimer = 3
				self.killBats = false
			end
		end
	end

	if self.realHealth < self.realMaxHealth / 2 then
		if self.shieldSpawnTimer > 0 then
			self.shieldSpawnTimer = self.shieldSpawnTimer - dt
		else
			self.shield = shield:new(self)
			self.shieldSpawnTimer = 3
		end
	end

	if self.shotTimer > 0 then
		self.shotTimer = self.shotTimer - dt
	else
		self:shoot()
		self.shotTimer = love.math.random(1, 2)
	end
end

function phoenix:draw()
	if not self.shouldDraw then
		return
	end
	love.graphics.draw(phoenixImage, phoenixQuads[self.quadi], self.x, self.y + math.sin(love.timer.getTime() * 6) * 8)

	if self.shield then
		self.shield:draw()
	end
end

function phoenix:shoot()
	table.insert(objects["fire"], fire:new(self.x + (self.width / 2) - 6, self.y + self.height, {-180, 180}))

	table.insert(objects["fire"], fire:new(self.x + (self.width / 2) - 6, self.y + self.height, {180, 180}))
end

function phoenix:leftCollide(name, data)
	if name == "barrier" then
		self.speedx = -self.speedx
		return
	end
end

function phoenix:rightCollide(name, data)
	if name == "barrier" then
		self.speedx = -self.speedx
		return
	end
end

function phoenix:getHealth()
	return self.health
end

function phoenix:getMaxHealth()
	return self.maxHealth
end

function phoenix:takeDamage(damageValue)
	if self.invincible or self.shield then
		if self.shield then
			self.shield:takeDamage(damageValue)
		end
		return
	end

	self.realHealth = util.clamp(self.realHealth + damageValue, 0, self.realMaxHealth)

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

function phoenix:removeShield()
	self.shield = nil
end

---------------------------------------

fire = class("fire", bullet)

function fire:init(x, y, velocity)
	self.x = x
	self.y = y

	self.width = 13
	self.height = 15

	self.speedx = velocity[1]
	self.speedy = velocity[2]

	self.quadi = 1

	self.active = true

	self.gravity = 0

	self.mask =
	{
		["player"] = true,
		["bullet"] = true
	}

	self.timer = 0
end

function fire:update(dt)
	self.timer = self.timer + 8 * dt
	self.quadi = math.floor(self.timer % 2) + 1
end

function fire:draw()
	love.graphics.draw(fireImage, fireQuads[self.quadi], self.x, self.y)
end

function fire:downCollide(name, data)
	if name == "player" then
		data:addLife(-1)
		return false
	end
end

function fire:upCollide(name, data)
	if name == "player" then
		data:addLife(-1)
		return false
	end
end

function fire:leftCollide(name, data)
	if name == "player" then
		data:addLife(-1)
		return false
	end
end

function fire:rightCollide(name, data)
	if name == "player" then
		data:addLife(-1)
		return false
	end
end

---------------------------------------

shield = class("shield")

function shield:init(phoenix)
	self.parent = phoenix

	self.width = 76
	self.height = 76

	self.colors = { Color.blue, Color.yellow, Color.red }

	self.shardTimer = 0.01
	self.shards = {}

	shieldSound:play()
end

function shield:update(dt)
	self.x, self.y = self.parent.x + self.parent.width / 2, self.parent.y + self.parent.height / 2

	if self.width < 36 and self.width > 0 then
		self.width = util.clamp(self.width - 80 * dt, 0, 76)

		if self.shardTimer > 0 then
			self.shardTimer = self.shardTimer - dt
		else
			local rand = love.math.random(#shieldShards)
			table.insert(self.shards, shard:new(self.x + (self.parent.width / 2) - shieldShards[rand]:getWidth() / 2, self.y + self.parent.height / 2 - shieldShards[rand]:getHeight() / 2, rand))
			self.shardTimer = 0.01
		end
	elseif self.width <= 0 then
		if #self.shards == 0 then
			self.parent:removeShield()
		end
	end

	for k, v in pairs(self.shards) do
		v:update(dt)
		if v.fade == 0 then
			table.remove(self.shards, k)
		end
	end
end

function shield:draw()
	if self.width > 50 then
		color = util.colorFade(self.width, 50, self.colors[2], self.colors[1])
	else
		color = util.colorFade(self.width, 49, self.colors[3], self.colors[2])
	end

	love.graphics.setColor(color[1], color[2], color[3], 180)
	love.graphics.circle("fill", self.x, self.y + math.sin(love.timer.getTime() * 6) * 8, self.width / 2)

	for k, v in pairs(self.shards) do
		love.graphics.setColor(color[1], color[2], color[3], 180 * v.fade)
		v:draw()	
	end

	love.graphics.setColor(255, 255, 255, 255)
end

function shield:takeDamage(damageValue)
	self.width = util.clamp(self.width + damageValue, 0, 76)
	
	local rand = love.math.random(#shieldShards)
	table.insert(self.shards, shard:new(self.x + (self.parent.width / 2) - shieldShards[rand]:getWidth() / 2, self.y + self.parent.height / 2 - shieldShards[rand]:getHeight() / 2, rand))
end

----------------------

shard = class("shard")

function shard:init(x, y, i)
	self.x = x
	self.y = y

	self.rotation = 0

	self.speedx = math.cos(love.math.random(math.pi * 2)) * 100
	self.speedy = math.sin(love.math.random(math.pi * 2)) * 100

	self.i = i

	self.fade = 1
end

function shard:update(dt)
	self.x = self.x + self.speedx * dt
	self.y = self.y + self.speedy * dt

	self.rotation = self.rotation + 12 * dt

	self.fade = math.max(self.fade - 0.6 * dt, 0)
end

function shard:draw()
	love.graphics.draw(shieldShards[self.i], self.x, self.y, self.rotation)
end