--[[
	16:24 PM - TurtleP: I'm thinking that it creates an electric forcefield around everyone
	16:24 PM - TurtleP: but anything that touches one is fizzled (including powerups that are dropped)
	16:28 PM - Polybius: thats a good idea
	16:29 PM - Polybius: its fair.
	16:29 PM - Polybius: if one gets hit by an enemy the energy dissipates
	16:29 PM - Polybius: and you can pick up a power up again?
	16:29 PM - Polybius: its kinda like a take a free hit thing?
	16:29 PM - TurtleP: good idea
--]]

local ability = {}

function ability:init(parent)
	objects.plasmashield = {}
	self.plasmaparticles = {}
	testr = 0

	self.start = false --clearly 
end

function ability:update(dt)
	if not self.start then
		for k = 1, #gameData do
			table.insert(objects["plasmashield"], newShield(objects["turtle"][k]))
			table.insert(self.plasmaparticles, newPlasma())
		end
		self.start = true
	end
	
	for i, v in ipairs(self.plasmaparticles) do
		
	end
	testr = testr + dt*(math.pi/4)
	if testr >= math.pi*2 then
		testr = testr-math.pi*2
	end
end

function ability:draw()
	love.graphics.setColor(255, 0, 0, 255)
	love.graphics.print(round(testr/math.pi*180, 2), 5, 105)
	for i, v in ipairs(objects["plasmashield"]) do
		love.graphics.push()
		love.graphics.translate(v.x, v.y)
		--love.graphics.rotate(testr)
		love.graphics.translate(-v.x, -v.y)
		love.graphics.ellipse("line", v.x, v.y, 20*scale, 40*scale, 32, testr)
		love.graphics.pop()
	end
end

function newPlasma()
	local plasma = {}
	
	local maxl = 8 --Number of orbits, basically
	local ell = 64 --Number of sides from ellipse
	local minS, maxS = .25, 2 --Minimum speed, maximum speed
	
	for i = 1, maxl do
		local t = {}
		t.angle = math.random(ell) --Starts at a random angle
		t.maxangle = ell
		t.maxTimer = math.random()*(maxS-minS) + minS --Starts at a random timer
		t.dir = (math.random(2)-1)*2-1 --Either -1 or 1, used to determine orientation (cw, ccw)
		table.insert(plasma, t)
	end

	return plasma
end

function newShield(turtle)
	local shield = {}

	shield.parent = turtle
	shield.sinTimer = 0
	shield.sinValue = 0

	shield.x = turtle.x
	shield.y = turtle.y
	shield.width = 40
	shield.height = 40

	function shield:onCollide(name, data)
		if data.emancipateCheck then
			playsound("evaporate")
				
			table.insert(fizzles, fizzle:new(data))

			data.kill = true

			if name == "enemies" then
				self.kill = true
			end
		end
	end

	function shield:update(dt)
		self.x, self.y = (self.parent.x + self.parent.width / 2) - self.width / 2, (self.parent.y + self.parent.height/ 2) - 40 / 2

		if self.sinTimer - dt < math.pi then
			self.sinTimer = self.sinTimer + dt 
		else
			self.sinTimer = 0
		end

		self.sinValue = math.sin(self.sinTimer)
	end

	function shield:draw()
		love.graphics.setColor(75, 153, 230, 255 * self.sinValue)
		love.graphics.rectangle("fill", self.x * scale, self.y * scale, self.width * scale, self.height * scale)
	end

	return shield
end

function love.graphics.ellipse(mode, x, y, w, h, segments, r)
	local pointstable = {}
	local segments = segments or 32
	local r = r or 0
	for i = 1, segments do
		local px = x + w/2
		local py = y + h/2
		local a = math.pi*2/segments*i + r
		px = px + math.cos(a)*w/2
		py = py + math.sin(a)*h/2
		table.insert(pointstable, px)
		table.insert(pointstable, py)
	end
	love.graphics.polygon(mode, pointstable)
end

return ability