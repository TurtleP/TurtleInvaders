class "spaceraccoon" {}

function spaceraccoon:__init(hp)
	self.x = (600)/2-(50)/2
	self.y = love.window.getHeight() / scale /2-(50)/2
	self.width = 50
	self.height = 50

	self.appear = love.graphics.newParticleSystem(love.graphics.newImage("gfx/particles/coon/square.png"), 1000)
	self.appear:setEmissionRate(100)
	self.appear:setSpeed(300, 400)
	self.appear:setLinearAcceleration(0, 0)
	self.appear:setPosition(400, 300)
	self.appear:setEmitterLifetime(1)
	self.appear:setParticleLifetime(1)
	self.appear:setDirection(0)
	self.appear:setSpread(360)
	self.appear:setRadialAcceleration(-2000)
	self.appear:setTangentialAcceleration(1000)
	self.appear:stop()
	self.quad = coonquads
	self.quadi = 1
	self.scale = scale 

	self.spawnedyet = false
	enemyspawnpowers = false
	
	self.timer = 0
	self.fade = 255
	self.appearfade = 0
	playsound("transformation")

	self.hp = hp
	self.maxhp = self.hp
	self.hpbar = hpbar:new(self.hp, "Risky Jacques", self)

	self.graphic = graphics["risky"]

	self.pitch = 10
	self.dist = 0

	self.type = "coon"
	self.animtimer = 0

	self.flashtimer = 0
	self.xspeed = 100
	self.ySpeed = 0
	self.static = false
	self.statictimer = love.math.random(10)
	self.teleporttimer = love.math.random(4)
	self.tpvalue = 0
	self.invis = 1

	playsound("boss")
	audio["boss"]:setLooping(true)
	audio["menu"]:stop()
	self.time = 0.3
	maxbatsonscreen = 20
end

function spaceraccoon:update(dt)
	self.dist = self.dist + self.pitch * dt

	if self.invincible then
		self.appearfade = 255

		self.flashtimer = self.flashtimer + 12 * dt
		
		self.invis = math.floor(self.flashtimer%2)
		
		if self.flashtimer > 24 then
			self.flashtimer = 0
			self.invincible = false
			self.invis = 1
		end
	end

	self.hpbar:update(dt)
    self.hp = self.hpbar.hp

	self.timer = self.timer + dt 

	if not self.spawnedyet then
		if self.timer < 3 then
			self.appear:setPosition((self.x+(self.width/2)) * scale, (self.y+(self.height/2)) * scale)
			self.appear:start()
			self.appear:update( dt )
		else 
			self.appear:stop()
			self.appear:reset()
			self.spawnedyet = true
		end

		if self.timer > 1.5 then
			self.fade = math.max(0, self.fade-180*dt)
			self.appearfade = math.min(255, self.appearfade+180*dt)
		end
	else 
		self:AISchedule(dt)

		self.animtimer = self.animtimer + dt 
		self.quadi = math.floor(self.animtimer%2)+1
	end

	for k, v in pairs(objects["turtle"]) do
		if CheckCollision(self.x, self.y, self.width, self.height, v.ui.x, v.ui.y, v.ui.width, v.ui.height) then
			v.ui:FadeIn()
		else 
			v.ui:FadeOut()
		end
	end

	for k, v in pairs(objects.barrier) do
		if CheckCollision(self.x + self.xspeed * dt, self.y, self.width, self.height, v.x, v.y, v.width, v.height) then
			self.xspeed = -self.xspeed
		end
	end

	self.x = self.x + self.xspeed * dt
end

function spaceraccoon:fadein(dt)
	self.appearfade = math.min(255, self.appearfade+180*dt)
end

function spaceraccoon:fadeout(dt)
	self.appearfade = math.max(0, self.appearfade-180*dt)
end

function spaceraccoon:AISchedule(dt)

	if self.invincible then
		return
	end

	if not self.dead then
		if not self.static then
			if self.teleporttimer > 0 then
				self.teleporttimer = self.teleporttimer - dt 
			else 
				self:checkTeleport(dt)
			end
		end

		if self.teleporttimer < 2 then
			self:fadeout(dt)
		else 
			self:fadein(dt)
		end
	else 
		self:fadein(dt)
	end
end

function spaceraccoon:checkTeleport(dt)
	self.tpvalue = love.math.random(200)

	local v = objects.barrier
	if self.xspeed > 0 then
		if self.x + self.width + self.tpvalue < v[2].x then
			self.x = self.x + self.tpvalue
		else 
			self.x = self.x - self.tpvalue
		end
	else 
		if self.x - self.tpvalue > v[1].x then
			self.x = self.x - self.tpvalue
		else 
			self.x = self.x + self.tpvalue
		end
	end

	table.insert(phantoments, phantoment:new(self.graphic, self.quad[self.quadi], self.x, self.y, "coon"))
	self.teleporttimer = love.math.random(5)
end

function spaceraccoon:draw()
	if not self.dead then
		love.graphics.setColor(255, 255, 255, self.appearfade*self.invis)
		love.graphics.draw(self.graphic, self.quad[self.quadi], self.x*scale, self.y*scale, 0, self.scale, self.scale)
		love.graphics.setColor(255, 255, 255, 255)
	end

	self.appear:setColors(255, 255, 255, self.fade)
	love.graphics.draw(self.appear, 0, 0)

	self.hpbar:draw()
end

function spaceraccoon:die()

	table.insert(objects.food, food:new(self.x+self.width, self.y+self.height, (math.pi)/4))

	table.insert(objects.food, food:new(self.x+(self.width/2), self.y, (math.pi)/2))

	table.insert(objects.food, food:new(self.x+(self.width/2), self.y+self.height, (math.pi*3)/2))

	table.insert(objects.food, food:new(self.x+self.width, self.y+(self.height/2), 0))

	table.insert(objects.food, food:new(self.x, self.y+(self.height/2), math.pi))

	table.insert(objects.food, food:new(self.x, self.y+self.height, (math.pi*3)/4))

	table.insert(objects.food, food:new(self.x, self.y, (math.pi*5)/4))

	table.insert(objects.food, food:new(self.x+self.width, self.y, (math.pi*7)/4))

	table.insert(objects.explosions, explosion:new(self.x+(self.width/2)-(48*scale)/2, self.y+(self.height/2)-(48*scale)/2, "coon"))
	
	unlockAchievement("raccoonkilled")
	
	self.dead = true 
	self.kill = true 
	earthquake = 40
end

foodgraphics = love.filesystem.getDirectoryItems("gfx/particles/coon/food/")

foodimages = {}
for k = 1, #foodgraphics do
	if foodgraphics[k]:sub(-4) == ".png" then
		foodimages[k] = love.graphics.newImage("gfx/particles/coon/food/" .. foodgraphics[k])
	end
end

class "food" {}

function food:__init(x, y, a)
	self.x = x
	self.y = y
	self.ang = a
	self.rotation = 0
	self.graphic = foodimages[love.math.random(#foodimages)]

	self.emancipateCheck = true
end

function food:update(dt)
	self.x = self.x + math.cos(self.ang)
	self.y = self.y + math.sin(self.ang)

	self.rotation = self.rotation + 2*dt

	if self.x < 0 or self.y < 0 or self.x > love.window.getWidth() or self.y > love.window.getHeight() then
		self.kill = true
	end
end

function food:draw()
	love.graphics.draw(self.graphic, self.x + 5, self.y + 5, self.rotation, scale, scale, 5, 5)
end