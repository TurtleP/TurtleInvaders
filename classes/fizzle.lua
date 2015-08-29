class "fizzle" {
	x, y
}

function fizzle:__init(data)
	--general data
	self.entityData = data 
	self.rotation = math.random()*(math.pi*2)
	self.rotdir = (math.random(2)-1)*2-1 --Results in either -1 or 1

	--specifics
	self.x = data.x
	self.y = data.y

	self.eyecolor = data.eyecolor

	self.speedx = (data.speedx * emanceSpeed) or 50
	self.speedy = (data.speedy * emanceSpeed) or 50

	self.graphic = data.graphic
	self.quad = data.quad
	self.quadno = data.quadno

	self.time = 0
	self.maxTime = 1
	self.fizzleInsertion = 0.1

	self.defaultColor = {255, 255, 255}
	self.blackendColor = {48, 48, 48}

	self.offsetX = data.width / 2
	self.offsetY = data.height / 2
end

function fizzle:update(dt)
	self.x = self.x + self.speedx * dt
	self.y = self.y + self.speedy * dt
	
	self.rotation = self.rotation + dt*self.rotdir
	if self.rotation >= math.pi*2 then
		self.rotation = self.rotation - math.pi*2
	elseif self.rotation < 0 then
		self.rotation = self.rotation + math.pi*2
	end

	if self.time < self.maxTime then
		self.time = self.time + dt
	else
		self.kill = true
	end
end

function fizzle:draw()
	love.graphics.setColor(colorfade(self.time, self.maxTime, self.defaultColor, self.blackendColor))
	if self.graphic and self.quad then
		love.graphics.draw(self.graphic, self.quad[self.quadno], (self.x + self.offsetX) * scale, (self.y + self.offsetY) * scale, self.rotation, scale, scale, self.offsetX, self.offsetY)
		if self.entityData.type == "enemy" then
			love.graphics.setColor(colorfade(self.time, self.maxTime, self.eyecolor, self.blackendColor))
			love.graphics.draw(graphics["bateyes"], self.quad[self.quadno], (self.x + self.offsetX) * scale, (self.y + self.offsetY) * scale, self.rotation, scale, scale, self.offsetX, self.offsetY)
		end
	elseif not self.graphic and not self.quad then
		love.graphics.push()
		
		love.graphics.translate(self.x+self.entityData.width/2, self.y+self.entityData.height/2)
		love.graphics.rotate(self.rotation)
		love.graphics.translate(-self.x-self.entityData.width/2, -self.y-self.entityData.height/2)
		
		love.graphics.setColor(colorfade(self.time, self.maxTime, self.entityData.color, self.blackendColor))
		love.graphics.rectangle("fill", self.x * scale, self.y * scale, self.entityData.width * scale, self.entityData.height * scale)

		love.graphics.pop()
	elseif self.graphic and not self.quad then
		love.graphics.draw(self.graphic, self.quad[self.quadno], (self.x + self.offsetX) * scale, (self.y + self.offsetY) * scale, self.rotation, scale, scale, self.offsetX, self.offsetY)
	end

	love.graphics.setColor(255, 255, 255)
end