class "phoenixdeath"{
	
}

function phoenixdeath:__init(x, y)
	self.x = x
	self.y = y
	self.graphic = graphics["phoenixdeath"]
	self.quad = phoenixdeathquads
	self.quadnox = 1
	self.quadnoy = 1

	self.timer = 0
end

function phoenixdeath:update(dt)
	self.timer = self.timer + 8*dt

	if self.quadnox < 12 then
		self.quadnox = math.floor(self.timer%12)+1
	else 
		self.kill = true
	end
end

function phoenixdeath:draw()
	love.graphics.draw(self.graphic, self.quad[self.quadnox], self.x, self.y, 0, scale, scale)
end