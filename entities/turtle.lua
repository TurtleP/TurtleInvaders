class "turtle" {
	x = 0, y = 0, lives = 3
}

function turtle:__init(x, y, i, hp, char, name)
	self.x = x
	self.y = y
	self.dead = false
	self.bullets = {}
	self.num = i or 1

	
	--custom character shit
	self.char = characters[char]

	self.img = characters[char].graphic
	self.deathimg = characters[char].deathgraphic
	self.deathquads = characters[char].deathquads

	self.maxshieldquads = characters[char].shieldquadcount
	self.shieldimg = characters[char].shieldimg
	self.shieldquads = characters[char].shieldquads

	self.width = (characters[char].width or 40)
	self.height = (characters[char].height or 40)

	self.name = char
	
	self.type = "player"
	self.powerup = "none"
	self.bullettype = "none"

	self.poweruptimer = 8
	self.score = 0
	self.lives = 3
	self.combo = 0
	self.combotimeout = 0
	self.bulletsshot = 0
	self.shouldupdate = true
	self.highestcombo = 0
	self.playsound = false
	self.xspeed = 200
	self.speed = 0
	self.start = false 
	self.health = hp
	self.powerupanimtimer = 0
	self.powerupquad = 1

	self.rightkey = false 
	self.leftkey = false 

	self.invincible = false

	self.ui = shipui:new(self.num, self.health, name, characters[char])
	self.batskilled = 0

	self.blinktimer = 0
	self.invis = 1

	self.phantomtime = love.math.random(0, 2.5)
	
	self.shieldAnimSpeed = characters[char].shieldAnimSpeed
	
	self.shieldin = characters[char].shieldin
	self.shieldinquads = characters[char].shieldinquads
	self.shieldinquadcount = characters[char].shieldinquadcount
	self.shieldInSpeed = characters[char].shieldInSpeed
	self.shieldout = characters[char].shieldout
	self.shieldoutquads = characters[char].shieldoutquads
	self.shieldoutquadcount = characters[char].shieldoutquadcount
	self.shieldOutSpeed = characters[char].shieldOutSpeed
	
	if characters[char].isAnimated then
		self.isAnimated = characters[char].isAnimated
		self.animationQuad = 1
		self.animationQuads = characters[char].animationQuads
		self.animationTimer = 0
		self.animationSpeed = characters[char].animationSpeed
	end

	self.ability = characters[char].ability
	if self.ability then
		if self.ability.init then
			self.ability:init(self) --gg me
		end
		
		if self.ability.passive then
			if self.ability.reset then
				self.ability:reset()
			end
		end
	end
end

function turtle:powerupupdate(dt, name)
	local t = name:lower()
	local b = self.bullettype:lower()

	self.ui:updateHUD(dt)

	if t == "shield" then
		if not self.playsound then
			self.shield = shield:new(self)
			self.playsound = true 
		end

		self.shield:update(dt)
	elseif t == "freeze" then
		self.shouldupdate = false
	elseif t == "remove" then
		self.powerup = "remove"
	elseif t == "special" then
		if self.ability then
			if self.ability.update then
				self.ability:update(dt)
			end
		end
	end

	if self.ability then
		if self.ability.update and ((t ~= "special" and self.ability.passive) or (t == "special" and not self.ability.passive)) then
			self.ability:update(dt)
		end
	end	
	
	if self.ui.poweruptimer <= 0 then
		self.powerupanimtimer = 0
		self.powerup = "none"
		self.bullettype = "none"

		self.playsound = false
		self.shouldupdate = true

		if self.ability then
			if self.ability.reset then
				self.ability:reset()
			end
		end

		self.ui:resetData()
	end
end

function turtle:specialUp(relay)
	if self.ui:isAbilityFull() then

		if self.ability then
			self.ability:init(self)
			self:setPowerup("special", false)
			self.ui:useSpecial()

			if clientonline then
				if not relay then
					table.insert(onlinetriggers, "specialability;" .. self.num .. ";")
				end
			end
		end
		
	else

		if self.ability then
			if self.powerup == "special" then
				if self.ability.keypress then
					self.ability:keypress()

					if clientonline and not relay then
						table.insert(onlinetriggers, "specialabilitykeypress;" .. self.num .. ";")
					end
				end
			end
		end

	end
end

function turtle:moveright()
	self.rightkey = true
	self.speed = self.xspeed
end

function turtle:moveleft()
	self.leftkey = true 
	self.speed = -self.xspeed
end

function turtle:stopleft()
	self.leftkey = false
	self.speed = 0
end

function turtle:stopright()
	self.rightkey = false
	self.speed = 0
end

function turtle:onCollide(name, data)
	if name == "enemies" then
		if self.powerup:lower() ~= "shield" then 
			self:addLife(-1)
		end 

		data:explode(false, true)
	end

	if name == "powerups" then
		if data.t ~= "oneup" then
			if self:checkforBulletType(data.t) then
				self:setPowerup(data.t, true)
			else
				self:setPowerup(data.t, false)
			end
		elseif data.t == "oneup" then
			self:setPowerup(data.t)
		end

		data.kill = true
	end

	if name == "boss" then
		self:addLife(-1)
	end

	if name == "bullets" then
		if data.parent.type == "enemy" then
			if self.powerup:lower() ~= "shield" then 
				self:addLife(-1)
			end 

			if data.powerup == "freeze" then
				self:setPowerup(data.powerup, false)
			end
		end
	end
end

function turtle:update(dt)
	if self.isAnimated then
		self.animationTimer = self.animationTimer + dt
		if self.animationTimer >= self.animationSpeed then
			self.animationTimer = 0
			self.animationQuad = self.animationQuad + 1
			if self.animationQuad > #self.animationQuads then
				self.animationQuad = 1
			end
		end
	end
	
	for k, v in pairs(objects.enemies) do
		if v.powerup == "time" then
			dt = math.min(dt/2, dt)

			self.phantomtime = self.phantomtime - dt 

			if self.phantomtime < 0 then
				
				local quad = nil
				if self.isAnimated then
					quad = self.animationQuad[1]
				end

				table.insert(phantoments, phantoment:new(self.img, quad, self.x, self.y, "turtle"))
				self.phantomtime = love.math.random(0.5, 2.5)
			end
		end
	end
	
	if self.shouldupdate then
		if self.lives == 0 then
			self.dead = true
		end

		if not self.start then
			if self.y > 300 - self.height - 22 then
				self.y = self.y - 120*dt
			else 
				self.start = true
			end
		end

		if clientonline then
			client:sendUDP("speedx;" .. playerid .. ";" .. self.speed .. ";")
		end

		self.x = self.x + self.speed * dt
		
		self:checkBarriers()

		if combo > 0 then
			if combotimeout < 2 then
				combotimeout = math.min(combotimeout + dt, 2)
			else 
				combo = 0
				combotimeout = 0
			end
		end
	end

	self:powerupupdate(dt, self.powerup)
	
	if self.invincible then
		self.blinktimer = self.blinktimer + 12 * dt
		
		self.invis = math.floor(self.blinktimer%2)
		
		if self.blinktimer > 24 then
			self.invis = 1
			self.invincible = false
			self.blinktimer = 0
		end
	end
end

function turtle:checkBarriers()
	if self.x <= 0 then
		self.x = 0
	elseif self.x + self.width >= 600 then
		self.x = 600 - self.width
	end
end

function turtle:addLife(n, relay, dontSound)
	if type(n) == "number" then
		if not self.invincible then
			self.health = self.health + n
			if n < 0 then
				noliveslost = nil

				if not dontSound then
					playsound(injurysounds[love.math.random(3)])
					self.invincible = true
				end

				if self.health == 0 then
					self:die("")
				end
			end

			self.ui.maxhp = self.health

			if clientonline and not relay and not dontSound then
				table.insert(onlinetriggers, "health;" .. n .. ";" .. playerid)
			end
		end
	end
end

function turtle:setPowerup(powerup, isBullet, relay)
	if not self.ui.megacannonthing and self.powerup:lower() ~= "remove" then
		if isBullet then
			if clientonline and not relay then
				table.insert(onlinetriggers, "bullettype;" .. powerup .. ";" .. self.num .. ";")
			end

			self.bullettype = powerup --should prevent some bugs with the timer resetting while using it
			self.ui:setBullet(powerup)
		else
			if powerup:lower() ~= "oneup" then
				if clientonline and not relay then
					table.insert(onlinetriggers, "powerup;" .. powerup .. ";" .. self.num .. ";")
				end

				self.powerup = powerup
				self.ui:setPowerup(powerup)
			else
				self:addLife(1)
				playsound("1up")
			end
		end
	end
end

function turtle:die(reason)
	table.insert(objects.explosions, explosion:new(self.x+(self.width/2)-((16)/2), self.y+(self.height/2)-((16)/2), false, true))
	
	table.insert(deadturtles, reason)

	if #deadturtles == players then
		gameover = true
	end

	self.dead = true
end

function turtle:joystickpressed(joystick, button)
	local shoot = controls[self.num][3]:split(":")
	local special = controls[self.num][4]:split(":")

	local joyid, name = joystick:getID()

	if joyid == self.num then
		if button == shoot[2] then
			self:shootbullet(self.bullettype)
		end

		if button == special[2] then
			self:specialUp()
		end

		self:specialPressed(special[2])
	end
end

function turtle:joystickaxis(joystick, axis, value)
	local ctrlleft = controls[self.num][1]:split(":")
	local ctrlright = controls[self.num][2]:split(":")

	local joyid, name = joystick:getID()

	if joyid == self.num then
		if axis == ctrlleft[1] then
			if ctrlleft[2] == "neg" then
				if value < -gamepaddeadzone then
					self:moveleft()
				else
					self:stopleft()
				end
			else
				if value > gamepaddeadzone then
					self:moveleft()
				else
					self:stopleft()
				end
			end
		end

		if axis == ctrlright[1] then
			if ctrlright[2] == "pos" then
				if value > gamepaddeadzone then
					self:moveright()
				else
					self:stopright()
				end
			else
				if value < -gamepaddeadzone then
					self:moveright()
				else
					self:stopright()
				end
			end
		end
	end
end

function turtle:draw()
	if self.dead then
		return 
	end

	love.graphics.setColor(255, 255, 255, 255*self.invis)



	if self.isAnimated then
		love.graphics.draw(self.img, self.animationQuads[self.animationQuad], self.x*scale, self.y*scale, 0, scale, scale)
	else
		love.graphics.draw(self.img, self.x*scale, self.y*scale, 0, scale, scale)
	end
end

function turtle:drawAbility()
	if self.ability then
		if self.ability.draw then
			if (self.powerup == "special" and not self.ability.passive) or (self.powerup ~= "special" and self.ability.passive) then
				self.ability:draw()
			end
		end
	end
end

function turtle:drawShield()
	love.graphics.setColor(255, 255, 255, 255)
	if self.powerup:lower() == "shield" then
		self.shield:draw()
	else
		return
	end
end

function turtle:keypressed(k)
	if k == controls[self.num][3] and self.shouldupdate then
		local p = self.bullettype
		
		self:shootbullet(p)
	end

	self:specialPressed(key)
end

function turtle:specialPressed(key)
	if self.powerup ~= "special" then
		return
	end

	if self.ability then
		if self.ability.keypressed then
			self.ability.keypressed(controls[self.num][4])
		end
	end
end

function turtle:shootbullet(p, relay)
	if clientonline and not relay then
		client:sendUDP("shoot;" .. playerid .. ";" .. p)
	end

	if p ~= "nobullets" then
		if p ~= "shotgun" and p ~= "shoop" then
			table.insert(objects.bullets, bullet:new(self.x+(self.width/2),self.y-(3),-300, 0, p, self) )
		elseif p == "shotgun" then
			table.insert(objects.bullets, bullet:new(self.x+(self.width/2)-(2*scale)/2,self.y-(6*scale),-300, 0, p, self) )
			table.insert(objects.bullets, bullet:new(self.x+(self.width/2)-(2*scale)/2,self.y-(3*scale),-300, -70, p, self) )
			table.insert(objects.bullets, bullet:new(self.x+(self.width/2)-(2*scale)/2,self.y-(3*scale),-300, 70, p, self) )
		elseif p == "shoop" then
			if not self.ui.megacannonthing then

				playsound("megacannon")

				table.insert(objects.powerup, shoop:new(self.x, self.y, self))

				for i,v in ipairs(love.joystick.getJoysticks()) do
					if v:isVibrationSupported( ) and v:getID() == self.num then
						v:setVibration(0.2, 0.2, 8)
					end
				end

				self.ui.megacannonthing = true
			end
		end
	end
end

function turtle:checkforBulletType(t)
	local types = {"laser", "antiscore", "nobullets", "shoop", "shotgun"}
	for k = 1, #types do
		if t == types[k] then
			return true 
		end
	end
	return false
end