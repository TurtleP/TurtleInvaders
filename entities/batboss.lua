class "boss" {
	x, y
}

function boss:__init(hp)
	self.x = (600)/2-(bossimg:getWidth())/2
	self.y = -60

	self.graphic = bossimg
	self.quad = bossquads
	self.quadno = 1
	self.timer = 0
	self.width = 60
	self.height = 30
	self.deathstart = 0

	playsound("boss")
	audio["boss"]:setLooping(true)
	audio["menu"]:stop()

	self.maxhp = hp
	self.hp = self.maxhp
	
	self.kill = false
	self.direction = math.random(1, 2)
	self.xspeed = math.random(50, 100)
	self.bullets = {}
	self.shottimer = batsshotdelay[math.random(2)]
	self.currdelay = batsshotdelay

	self.invincible = false
	self.animationtimer = 0
	self.maneuver = 1
	self.active = false
	self.initial = true

	self.hpbar = hpbar:new(self.hp, "Mega Space Bat", self)
	maxbatsonscreen = 0
	self.type = "boss"
	self.scale = scale

	self.invis = 1
end

function boss:update(dt)	
	self.maneuver = math.random(1, 2)

	if self.invincible then
		self.animationtimer = self.animationtimer + 12 * dt
		
		self.invis = math.floor(self.animationtimer%2)
		
		if self.animationtimer > 24 then
			self.animationtimer = 0
			self.invis = 1
			self.invincible = false
		end
	end
	
	if self.y < 140 then
		self.y = self.y + 90*dt
	else
		self.active = true
	end

	self.hp = self.hpbar.hp
	
	if self.hp <= 0 then
		self:die()
	end
	
	self.hpbar:update(dt)

	--AI--
	
	if (clientonline and isnetworkhost) or not clientonline then
		self.shottimer = self.shottimer - dt
		
		if self.shottimer <= 0 then
			self:shoot()
			self.shottimer = self.currdelay[math.random(2)]

			if clientonline then
				client:sendUDP("bossshot;" .. self.maneuver .. ";")
			end
		end
	end
	
	for j, c in pairs(objects.barrier) do
		if CheckCollision(self.x + self.xspeed * dt, self.y, self.width, self.height, c.x, c.y, c.width, c.height) then
			self.xspeed = -self.xspeed
		end
	end

	self.x = self.x + self.xspeed * dt
				
	self.timer = math.min(self.timer + 8*dt)
	self.quadno = math.floor(self.timer%3)+1

	for k, v in pairs(objects["turtle"]) do
		if CheckCollision(self.x, self.y, self.width, self.height, v.ui.x, v.ui.y, v.ui.width, v.ui.height) then
			v.ui:FadeIn()
		else 
			v.ui:FadeOut()
		end
	end
end

function boss:onCollide(name, data)
	if name == "barrier" then
		self.xspeed = -self.xspeed
	end
end

function boss:shoot()
	if self.maneuver == 1 and self.hp < self.maxhp/2 then
		table.insert(objects.bullets, bullet:new(self.x+30,self.y-3,300, 0, "power", self))
		table.insert(objects.bullets, bullet:new(self.x+30,self.y-3,300, -70, "power", self))
		table.insert(objects.bullets, bullet:new(self.x+30,self.y-3,300, 70, "power", self))
	elseif self.maneuver == 2 then
		table.insert(objects.bullets, bullet:new(self.x+30,self.y-3,300, -50, "none", self))
		table.insert(objects.bullets, bullet:new(self.x+30,self.y-3,300, 50, "none", self))
	end
end

function boss:draw()
	love.graphics.setColor(255, 255, 255, 255 * self.invis)
	love.graphics.draw(self.graphic, self.quad[self.quadno], self.x * scale, self.y * scale, 0, self.scale, scale)

	love.graphics.setColor(255, 255, 255)
	self.hpbar:draw()
end

function boss:die()
	addScore(1000)
	earthquake = 40
	maxbatsonscreen = 20
	
	unlockAchievement("batbosskilled")

	table.insert(objects.explosions, explosion:new(self.x+(self.width/2)-(48*scale)/2, self.y+(self.height/2)-(48*scale)/2, "coon"))
	self.kill = true
end