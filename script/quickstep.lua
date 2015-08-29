local ability = {}

function ability:init(turtle)
	self.parent = turtle

	--init a particle thingy, max 100 squares das gud
	self:initSystem()

	--doin' it like Hugo donnit
	self.lastPos = {false, false}

	self.phantom = nil

	self.coolDown = 3
	self.coolDownMax = self.coolDown
	self.coolDownTriggered = false
end

function ability:initSystem()
	self.system = love.graphics.newParticleSystem(love.graphics.newImage("gfx/particles/coon/otherSquare.png"), 100)
	self.system:setParticleLifetime(2, 5)
	self.system:setEmissionRate(40)

	--make sure they're the same?
	local g, b = love.math.random(124, 255), love.math.random(225, 255)
	self.system:setColors(0, g, b, 255, 0, g, b, 0)
	self.system:setAreaSpread("uniform", 10, 16)
	self.system:setLinearAcceleration(-20, -20, 20, 20)
	self.system:setEmitterLifetime(1)
end

function ability:update(dt)
	if self.lastPos[1] and self.lastPos[2] then
		self.system:update(dt)
	end

	if self.phantom then
		self.phantom:update(dt)
	end

	if self.coolDownTriggered then
		if self.coolDown > 0 then
			self.coolDown = self.coolDown - dt
		else
			self.coolDown = self.coolDownMax
			self.coolDownTriggered = false
		end
	end

	if self.phantom then
		if self.phantom.kill then
			self.system:stop()
			self.phantom = nil
		end
	end
end

function ability:keypress()
	--there's gonna be a cooldown, cool? okay.

	if not self.coolDownTriggered then
		if self.parent.speed < 0 then
			self:doStep(-100)
		elseif self.parent.speed > 0 then
			self:doStep(100)
		end
	end
end

function ability:draw()
	if self.phantom then
		self.phantom:draw()
	end

	if self.lastPos[1] and self.lastPos[2] then
		love.graphics.draw(self.system, self.lastPos[1] * scale, self.lastPos[2] * scale, 0, scale, scale)
	end
end

function ability:doStep(playerSpeed)
	self.system:start()

	local quad = nil
	if self.isAnimated then
		quad = self.animationQuad[1]
	end

	self.phantom = phantoment:new(self.parent.img, quad, self.parent.x, self.parent.y, "turtle")

	self.lastPos = {self.parent.x + self.parent.width / 2 - 2, self.parent.y + self.parent.height / 2 - 2}

	local maths = math.min
	local maxSpot = gameW
	if playerSpeed < 0 then
		maths = math.max
		maxSpot = 0
	end

	self.parent.x = maths(maxSpot, self.parent.x + playerSpeed)

	self.coolDownTriggered = true
end

return ability