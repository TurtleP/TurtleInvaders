rocket = class("rocket", bullet)

function rocket:initialize(x, y, speed)
	bullet.initialize(self, x, y, speed)
    
    self.category = 7
    self.mask = {true, true, false, false, false}

    self.destroyTimer = 0
    self.delay = 0.2
    self.target = state:get("player")
end

function rocket:update(dt)
    if self.delay > 0 then
        self.delay = self.delay - dt
        return
    end

	if self.target then
		local spinfactor = math.pi / 60
				
		local a = math.atan2(self.speed.y, self.speed.x)
		local a2 = math.atan2((self.target.y + (self.target.height / 2)) - self.y, self.target.x - self.x)
		if a < a2 and a2 - a > math.pi then 
			spinfactor = spinfactor * (-1)
		elseif a > a2 and a - a2 <= math.pi then 
			spinfactor = spinfactor * (-1) 
		end
					
		a = a + spinfactor
		
		if a < 0 then 
			a = a + math.pi * 2
		elseif a >= math.pi * 2 then 
			a = a - math.pi * 2 
		end
					
		local speed = 400
		self.speed.x = speed * math.cos(a)
		self.speed.y = speed * math.sin(a)
	end

	self.destroyTimer = self.destroyTimer + dt
	if self.destroyTimer > 2 then
		explosion:new(self.x, self.y)
		self.remove = true
	end
end

function rocket:draw()
	bullet.draw(self)
end

function rocket:passiveCollide(name, data)
	if name == "player" then
		return
	end
	
	bullet.passiveCollide(self, name, data)
end