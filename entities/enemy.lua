class "enemy" {
	x,y
}

local batspeed = {love.math.random(80, 90), love.math.random(30, 60), love.math.random(61, 79)}
local batarm = {0, 1, 2, 3}
local batleadpatterns = {"v", "hor", "ver"}

local batpowerups = {"none", "shotgun",  "time", "laser", "freeze"}

local abilities = {"jackshit", "powerup", "leader", "shoot", "armor", "circle"}

local abiltable = 
{
	powerup = 3,
	leader = 5,
	shoot = 2,
	armor = 4,
	circle = 8,
	jackshit = 0,
}

function enemy:__init(x, y, id, leaderdata)
	self.x = x
	self.y = y
	self.dead = false
	self.quad = batquads
	self.graphic = graphics["bat"]
	self.width = 30
	self.height = 12
	self.direction = love.math.random(1, 2)
	self.timer = 0
	self.quadno = 1

	if objects then
		self.id = id
	end

	self.type = "enemy"
	self.poweruptimer = 2
	self.powerup = "none"
	self.rotation = 0

	self.pattern = ""
	self.shoots = false 
	self.leader = false 
	self.circle = false
	self.angle = 0
	self.armor = 0
	self.delay = 0
	self.ply = 0

	self.hor = 0
	self.ver = 0
	self.tl = 0
	self.md = 0
	self.tr = 0

	if players then
		if players > 1 then
			if #objects.turtle < players then
				if love.math.random(25) == 1 then
					self.ply = love.math.random(1, players)
				end
			end
		end
	end
	
	--Each will be different--mostly

	if not a and not b then
		self:setAbilities()

		if self.abilityA == self.abilityB then
			self.abilityB = "jackshit"
		end

		if not isFollow then
			self.speedx = love.math.random(-20, 30)
			self.speedy = batspeed[love.math.random(#batspeed)]
		else
			if leaderdata then
				self.speedx = leaderdata.speedx
				self.speedy = leaderdata.speedy
				self.abilityB = "jackshit"
				self.abilityA = "jackshit"
			end
		end

		if self.abilityA and self.abilityB ~= "" then
			if waven then
				if waven > abiltable[self.abilityB] + abiltable[self.abilityA] then
					self:setFlags(self.abilityA, self.abilityB, isFollow)
				else 
					self:setAbilities()
					self:setFlags()
				end
			end
		end

		if love.math.random(100) <= 25 then
			self.abilityB = "jackshit"
			self.abilityA = "jackshit"
			self:setFlags(self.abilityA, self.abilityB, isFollow)
		end
	else 
		self.abilityA = a
		self.abilityB = b 
	end

	self.eyecolor = getPowerColor(self.powerup or "none")

	self.phantomtime = love.math.random(0, 2.5)

	self.emancipateCheck = true
	self.shottedBy = nil
end

function enemy:setAbilities()
	self.abilityA = abilities[love.math.random(#abilities)]
	self.abilityB = abilities[love.math.random(#abilities)]
end

function enemy:setFlags(a, b, isFollow)
	if not objects then
		return
	end

	if not isFollow then
		if (a == "powerup" or b == "powerup") and self.ply == 0 then
			self.shoots = true 
			self.delay = self:getDelay(love.math.random(2))
			self.powerup = batpowerups[love.math.random(1, 5)]
		elseif (a == "powerup" or b == "powerup") and self.ply ~= 0 then
			self.powerup = "revive"
		end

		if a == "shoot" or b == "shoot" then
			self.shoots = true
			self.delay = self:getDelay(love.math.random(2))
		end

		if a == "armor" or b == "armor" then
			self.armor = batarm[love.math.random(#batarm)]
		end

		if not objects.boss[1] then
			if a == "circle" or b == "circle" then
				--Circle[T/F]: Circles around.. and stuff-ish
				self.circle = true
			end

			if a == "leader" or b == "leader" then
				--Leader:[T/F]: Leads a group of 2-6 bats that DON'T HAVE AN XSPEED in a V-formation
				self.leader = true
				if not isFollow and self.circle == "false" then
					if self.x >= 20 and self.x < 100 then
						self.pattern = batleadpatterns[love.math.random(#batleadpatterns)]
						if self.pattern == "v" then
							self.xspeed = 0
						end
						self:addFollowers(self.pattern)
					else 
						self.leader = false 
					end
				end
			end
		end
	end
	self.eyecolor = getPowerColor(self.powerup or "none")
end

function enemy:addFollowers(dir)
	if dir == "hor" then
		self.hor = love.math.random(4)
		for k = 1, self.hor do
			table.insert(objects.enemies, enemy:new(self.x+(k)*40, self.y, #objects.enemies+1, self))
		end
	elseif dir == "ver" then
		self.ver = love.math.random(4)
		for k = 1, self.ver do
			table.insert(objects.enemies, enemy:new(self.x, self.y-(k)*40, #objects.enemies+1, self))
		end
	else 
		self.tl = love.math.random(2)
		self.md = love.math.random(2)
		self.tr = love.math.random(2)


		for k = 1, self.tl do --top-left form
			table.insert(objects.enemies, enemy:new(self.x-(k)*40, self.y-(k)*40, #objects.enemies+1, self))
		end
		for k = 1, self.md do --middle
			table.insert(objects.enemies, enemy:new(self.x, self.y-(k)*40, #objects.enemies+1, self))
		end
		for k = 1, self.tr do --top-right form
			table.insert(objects.enemies, enemy:new(self.x+(k)*40, self.y-(k)*40, #objects.enemies+1, self))
		end
	end
end

function enemy:shotted(antiB, player, bullet)
	if self.armor then
		if self.armor > 0 then
			self.armor = self.armor - 1

			if clientonline then
				--client:sendArmor(self.armor)
			end
		else 
			self:die(antiB, false, false)
		end
	else 
		self:die(antiB,  false, false)
	end

	self.shottedBy = {player, bullet}
end

function enemy:Cycle(dt)
	self.xspeed = 0
	self.angle = self.angle + 5*dt

	self.x = self.x + math.cos(self.angle)*2
	self.y = self.y + math.sin(self.angle)*2
end

function enemy:getDelay(m)
	local d = enemybulletdelay1[love.math.random(#enemybulletdelay1)]
	
	if m == 2 then
		d = enemybulletdelay2[love.math.random(#enemybulletdelay2)]
	end
	
	return d
end

function enemy:draw()
	love.graphics.setColor(255, 255, 255)
	love.graphics.draw(self.graphic, self.quad[self.quadno], self.x*scale, self.y*scale, self.rotation, scale, scale)
	love.graphics.setColor(self.eyecolor[1], self.eyecolor[2], self.eyecolor[3], self.eyecolor[4])
	love.graphics.draw(graphics["bateyes"], self.quad[self.quadno], self.x*scale, self.y*scale, self.rotation, scale, scale)
	love.graphics.setColor(255, 255, 255)

	if self.armor then
		if self.armor > 0 then
			love.graphics.draw(graphics["batarmor"], batarmorquads[self.quadno][self.armor], self.x*scale, self.y*scale, 0, scale, scale)
		end
	end
end

function enemy:update(dt)
	

	if objects then
		for k, v in pairs(objects.turtle) do
			if v.powerup:lower() == "time" then
				dt = math.min(dt/2, dt)

				self.phantomtime = self.phantomtime - dt 

				if self.phantomtime < 0 then
					table.insert(phantoments, phantoment:new(self.graphic, self.quad[self.quadno], self.x, self.y, "bat"))
					self.phantomtime = love.math.random(0, 2.5)
				end
			end

			if CheckCollision(self.x, self.y, self.width, self.height, v.ui.x, v.ui.y, v.ui.width, v.ui.height) then
				v.ui:FadeIn()
			else 
				v.ui:FadeOut()
			end
		end
	end

	--Find ability pair to use
	if waven then
		if waven < abiltable[self.abilityB] + abiltable[self.abilityA] then
			self:setAbilities()
			self:setFlags()
		end
	end

	if self.powerup == "time" then
		self.poweruptimer = self.poweruptimer - dt
		if self.poweruptimer < 0 then
			self.poweruptimer = 2
			self.powerup = "none"
		end
	end

	self.timer = self.timer + 8*dt
	self.quadno = math.floor(self.timer%3)+1

	--AI STUFF!--
	if self.circle == true then
		self:Cycle(dt)
	end

	if (clientonline and isnetworkhost) or not clientonline then
		if self.shoots == true then
			self.delay = self.delay - dt
			if self.delay < 0 then
				self:shoot(self.powerup)

				self.delay = self:getDelay(love.math.random(2))
			end
		end
	end

	if objects then
		for j, c in pairs(objects.barrier) do
			if CheckCollision(self.x + self.speedx * dt, self.y, self.width, self.height, c.x, c.y, c.width, c.height) then
				self.speedx = -self.speedx
			end
		end
		
		if self.y > gameH then
			batsescaped = batsescaped + 1 

			table.insert(onlinetriggers, "batdied;" .. self.id .. ";false;false")

			self.kill = true
		end
	end

	self.x = self.x + (self.speedx) * dt

	self.y = self.y + (self.speedy) * dt
end

function enemy:shoot(power)
	local p = power

	if clientonline and isnetworkhost then
		client:sendUDP("batshot;" .. self.id .. ";" .. power)
	end

	if p ~= "shotgun" then
		table.insert(objects.bullets, bullet:new(self.x+(self.width/2)-(2)/2,self.y+self.height+(16*scale),150, 0, self.powerup, self)) 
	else 
		table.insert(objects.bullets, bullet:new(self.x+(self.width/2)-(2)/2,self.y+self.height+(16*scale),150, -70, self.powerup, self)) 
		table.insert(objects.bullets, bullet:new(self.x+(self.width/2)-(2)/2,self.y+self.height+(16*scale),150, 0, self.powerup, self)) 
		table.insert(objects.bullets, bullet:new(self.x+(self.width/2)-(2)/2,self.y+self.height+(16*scale),150, 70, self.powerup, self)) 
	end
end

function enemy:onCollide(name, data)
	if name == "bullets" then
		if data.parent.type == "player" then
			if data.powerup:lower() ~= "antiscore" then
				self:shotted(false, data.parent, data)
				if data.powerup:lower() ~= "laser" then
					if self.armor > 0 then
						data:destroy()
					else
						data:destroy()
					end
				else
					data.batskilled = data.batskilled + 1
					if data.batskilled == 2 then
						unlockAchievement("doublekill")
						data.batskilled = 0
					end
				end
			else 
				self:shotted(true, data.parent, data)
				if data.powerup:lower() ~= "laser" then
					data:destroy()
				end
			end

			data.parent.ui:addAbilityBar()
		end
	end
end

function enemy:die(antiB, emanced, relay, player)
	killcount = killcount + 1
	batskilled = batskilled + 1

	if not clientonline or (clientonline and isnetworkhost) then
		if batskilled%50 == 0 and batskilled ~= 0 then
			self:droppowerup(false, false, "oneup")
		else 
			if enemyspawnpowers == true then
				self:droppowerup(true)
			end
		end
	end

	if self.ply ~= 0 and not objects["turtle"][self.ply] then
		local k = self.ply

		local names = gameData

		if clientonline or netplay then
			names = nameData
		end

		table.remove(deadturtles, #deadturtles)

		objects.turtle[k] = turtle:new((25+(k-1)*80), 256, k, health[k], gameData[k], names[k])
	
		unlockAchievement("revivedmember")
	end

	if clientonline and not relay then
		table.insert(onlinetriggers, "batdied;" .. self.id .. ";" .. tostring(antiB) .. ";" .. tostring(emanced))
	end

	if self.shoots then
		if self.delay > 0 and self.delay < 1 then
			unlockAchievement("ceasefire")
		end
	end

	if objects then
		if not emanced then
			self:explode(antiB) --eeeyy lmao
		else
			self:emancipate()
		end
	end
end

function enemy:explode(antiBullet, dontScore)
	playsound("killbat")

	combotimeout = 0
	
	if not dontScore then
		combo = combo + 1

		if not antiBullet then
			addScore(10)
		else 
			addScore(-20)
		end
	end

	table.insert(objects.explosions, explosion:new(self.x+(self.width/2)-(16)/2, self.y+(self.height/2)-(14)/2, "bat"))

	if batskilled == 1000 then
		unlockAchievement("batskilled")
	end

	self.kill = true
end

function enemy:emancipate()
	unlockAchievement("spacelaser")
			
	addScore(100, "space laser")

	self.kill = true
end

function enemy:droppowerup(rand, p)
	local poweruptype = ""

	if not p then
		if rand then
			poweruptype = randompowerupchance(love.math.random(100))
		else
			poweruptype = "oneup"
		end
	else
		poweruptype = p
	end

	if poweruptype ~= "" then
		local x, y = self.x+(self.width/2)-(16)/2, self.y+(self.height/2)-(16/2)
		dropPowerup(x, y, poweruptype)
	end
end