class "spacephoenix" {
   x = 0, y = 0
}

--[[NOTES
	Phase 1:
   Attack the phoenix for 20HP, bats come down after the phoenix goes up off screen
   Kill all bats, he comes back and repeats
   {DO 3 TIMES FOR -60 HP || 120 HP LEFT}
   
   Phase 2:
   Phoenix moves up away from the center of the sceen by 180 pixels, and moves around in a circle
   Dive bombs ship periodically
   {DO THRICE FOR -60 HP || 60HP LEFT}
   
   Phase 3:
   The phoenix generates a shield made up of 5 bats. Each bat rotates around the phoenix
   After 3 seconds of any bats dying, the shield regenerates. After a random 3-4 second
   duration, then the bat closest to the player dives forward towards the turtle. Other
   bats will shoot bullets randomly  every 1-2 seconds.
]]--

function spacephoenix:__init(hp)
   self.graphic = phoeniximg
   self.quad = phoenixquads
   
   self.x = 300 - (66 / 2)
   self.y = 150 - (50 / 2)
   self.width = 66
   self.height = 50
   
   self.animationtimer = 0
   self.quadno = 1
   self.firetimeroptions = {{2, 3}, {2, 2}, {1, 2}}
   self.firetimer = self.firetimeroptions[1][math.random(#self.firetimeroptions[1])]
   self.pitch = 2*scale
   self.dist = 0
   self.timer = 0

   self.maxhp = hp
   self.hp = self.maxhp
   
   self.hpbar = hpbar:new(self.hp, "Space Phoenix", self)
  
   maxbatsonscreen = 0
   self.fade = 1

   self.invis = 1
   self.blinktimer = 0
   self.state = "normal"
   self.batsleft = 0
   self.oldy = self.y
   
   enemyspawnpowers = false
   playsound("finalboss");audio["finalboss"]:setLooping(true)
   self.type = "phoenix"

   self.angle = 0
   self.oldx = self.x
   self.attacktimer = 1
   self.donemoving = false
   self.animate = true
   self.rate = 8
   self.xspeed = 0
   self.speedy = 0
   self.batsprotecting = 0
   
   self.part = 1
   self.phase = 1
   
   earthquake = 55

   self.chargeattack = false
   self.init = true
   self.quady = 1
   self.cycling = false
end

function spacephoenix:addBats(n)
	if self.batsleft >= 0 then
		self.batsleft = self.batsleft + n
	end
end

function spacephoenix:piston(dt)
	self.dist = self.dist + self.pitch * dt
end

function spacephoenix:update(dt)
	if earthquake == 0 then
		self.init = false
	end

 	if self.animate then 
	   self.animationtimer = math.min(self.animationtimer + self.rate*dt)
	   self.quadno = math.floor(self.animationtimer%3)+1
	   
		if self.firetimer < 0.3 then
			self.quady = 2
		else 
			self.quady = 1
		end
	
    else
    	self.quadno = 4
    	self.animationtimer = 0
   	end
	
   self.hpbar:update(dt)
   self.hp = self.hpbar.hp
   
	if self.fade > 0 then
		self.fade = math.max(0, self.fade-dt/0.8) --fade out
	end
	
	if self.invincible then
		self.blinktimer = self.blinktimer + 12 * dt
		
		self.invis = math.floor(self.blinktimer%2)
		
		if self.blinktimer > 24 then
			self.invis = 1

			if self.hp > self.maxhp / 2 then
				self.state = "bats"

				self:addBats(2 * self.part + love.math.random(3))
				self.part = self.part + 1
			end

			self.blinktimer = 0

			self.invincible = false
		end
	end
	
	if self.y > gameH then
		self.x = self.oldx
		if self:getPhase() == 1 then
			self.x = self.oldx
			self.state = "appear"
			self.xspeed = 0
			self.speedy = 0
			self.y = -self.height
			self.donemoving = false
		elseif self:getPhase() == 2 then
			self.y = -self.height
			self.state = "appear"
			self.attacktimer = love.math.random(3, 5)
			self.rotation = 0
			self.xspeed = 0
			self.speedy = 0
			self.animate = true
			self.angle = 0
		end
	end
	
	if not self.cycling then
		self.x = self.x + self.xspeed * dt 
		self.y = self.y + self.speedy * dt
	end

	self:checkAppear(dt, self.oldy)

	if self.hp > self.maxhp / 2 then
		self:PhaseOne(dt)
	end

	if (self.hp <= self.maxhp / 2) and (self.hp > self.maxhp / 3) then
		self:PhaseTwo(dt)
	end

	if self.hp <= self.maxhp / 3 then
		self:PhaseThree(dt)
	end
end

function spacephoenix:setPhase(p)
	self.phase = p
end

function spacephoenix:checkAppear(dt, y)
	if self:getState() == "appear" then
		if self.y < y then
			self.y = self.y + 120*dt
			self.donemoving = true
		else
			if not self.init then
				earthquake = 0
			end
			self.state = "normal"
			self.chargeattack = false
		end
	end
end

function spacephoenix:getPhase()
	if self.hp > self.maxhp / 2 then
		return 1
	elseif self.hp <= self.maxhp / 2 and self.hp > self.maxhp  / 3 then
		return 2
	else
		return 3
	end
end

function spacephoenix:FlameAttack(dt)
	if (isnetworkhost and clientonline) or not clientonline then
		self.firetimer = self.firetimer - dt
	end

	if self.firetimer < 0 then
		self:flameYo()

		if (clientonline and isnetworkhost) or not clientonline then
			self.firetimer = self.firetimeroptions[self.phase][math.random(#self.firetimeroptions[self.phase])]

			if clientonline then
				client:sendUDP("phoenixshot;")
			end
		end
	end
end

--lol references
function spacephoenix:flameYo()
	table.insert(objects.phoenixfire, phoenixfire:new(self.x+(self.width/2)-(16)/2, self.y+(22)+math.sin(self.dist)*10, 0, 0, 140)) --forward

	table.insert(objects.phoenixfire, phoenixfire:new(self.x+(self.width/2)-(16)/2, self.y+(22)+math.sin(self.dist)*10, math.pi/4, -140, 140, -3, 10)) --left
	
	table.insert(objects.phoenixfire, phoenixfire:new(self.x+(self.width/2)-(16)/2, self.y+(22)+math.sin(self.dist)*10, -math.pi/4, 140, 140, 8, -4)) --right
end

function spacephoenix:moveup( targetY, dt )
	if self.y > (targetY or 0) then
		self.y = self.y - 120*dt
		return false
	else 
		return true
	end
end

local done = false
local pass = false 
local set = false 
local init = false

function spacephoenix:cycle(doit, dt)
	self.cycling = doit

	if self.cycling then
		self.angle = self.angle + 5*dt

		self.x = self.oldx + math.cos(self.angle)*30
		self.y = self.oldy + math.sin(self.angle)*30
	end
end

local angofattk

function spacephoenix:ChargeAtPlayer(dt)
	if self.state == "normal" then

		if (isnetowrkhost and clientonline) or not clientonline then
			self.attacktimer = self.attacktimer - dt
		end

		if self.attacktimer < 0 then
			self:charge()
		end
	else 

	end
end

function spacephoenix:charge()
	self:cycle(false)

	self.quady = 1

	local closestDistance = 0
	for i, v in pairs(objects.turtle) do
	  	local dx = v.x-self.x
		local dy = v.y-self.y
		local distance = math.sqrt(dx^2+dy^2)
		if distance < closestDistance then
			self.nearestply = i
			closestDistance = distance
		end
	end

	if not self.nearestply then
		self.nearestply = 1
	end

	if (clientonline and isnetworkhost) then
		client:sendUDP("phoenixply;" .. self.nearestply .. ";")
	end

	if not self.chargeattack then
		local near = objects["turtle"][self.nearestply]
		angofattk = math.atan2((near.y+near.height / 2 +self.height) - self.y, near.x - self.x)
		self.animate = false
		playsound("phoenixattack-temp")
		self.chargeattack = true
	end

	self.rotation = angofattk-(math.pi)/2
	self.xspeed = math.cos(angofattk) * phoenixspeed
	self.speedy = math.sin(angofattk) * phoenixspeed
	earthquake = 25
	self.state = "charging"
end

function spacephoenix:PhaseOne(dt)
	if self:getState() ~= "bats" and self:getState() ~= "appear" then
		self:FlameAttack(dt)
	end

	self:piston(dt)
	
	if self.state == "bats" then
		if self.y > 0-self.height-40 then
			self.y = self.y - 120*dt
		else
			maxbatsonscreen = 5
		end

		if self.batsleft <= 0 then
			maxbatsonscreen = 0
			self.batsleft = 0
			self.state = "appear"
			self.blinktimer = 0
		end
	end
end

function spacephoenix:PhaseTwo(dt)
	self.dist = 0

	if self.attacktimer > 0 and self.state == "normal" then
		
		self:cycle(true, dt)
		self:FlameAttack(dt)

	end

	self:ChargeAtPlayer(dt)
end

local pass = false
local time = 6
local init = false
local shieldup = false

function spacephoenix:PhaseThree(dt)
	self.rotation = 0

	self.x = self.oldx
	self.y = self.oldy 

	if not shieldup and self.y == self.oldy then
		table.insert(objects.phoenixshield, phoenixshield:new(self.x+(self.width/2)-(140)/2, self.y+(self.height/2)-(140)/2, self))
		shieldup = true
	end

	maxbatsonscreen = 5

	if not objects.phoenixshield[1] then
		self:FlameAttack(dt)

		if time > 0 then
			time = time - dt
		else
			if self.y == self.oldy then
				shieldup = false 
				time = 6
			end
		end
	end

	self.dist = self.dist + self.pitch * dt
end

function spacephoenix:addProtection(n)
	self.batsprotecting = self.batsprotecting + n
end	

function spacephoenix:getState()
	return self.state
end

function spacephoenix:draw()
   love.graphics.setColor(255, 255, 255, 255*self.invis)
   love.graphics.draw(self.graphic, self.quad[self.quadno][self.quady], self.x*scale, (self.y*scale)+math.sin(self.dist)*10*scale, self.rotation or 0, scale, scale)
   
   love.graphics.setColor(255, 255, 255, 255)
   self.hpbar:draw()
   
   if self.batsleft > 0 then
		love.graphics.setFont(font5)
		love.graphics.print("Bats remaining: " .. self.batsleft, love.window.getWidth()/2-font5:getWidth("Bats remaining: " .. self.batsleft)/2, 60*scale)
   end
end

function spacephoenix:die()
	addScore(3000)
	maxbatsonscreen = 0
	time = 3
	love.audio.stop(audio["menu"])
	love.audio.stop(audio["finalboss"])

	unlockAchievement("phoenixkilled") 

	unlockAchievement("gamecleared" .. difficultytypes[difficultyi])

	if noliveslost then
		unlockAchievement("noliveslost")
	end
	
	bossrushmode = true

	playsound("phoenixattack-temp")
	table.insert(objects.phoenixdeath, phoenixdeath:new(self.x-8*scale, (self.y+math.sin(self.dist)*10)-10*scale))
	
	saveData("settings")

	self.kill = true
end