local star = class ("star")

function star:initialize(x, y, layer)
	self.x = x
	self.y = y

	self.speed = 45 * ((layer - 1) / 2)
	self.r = (layer / 2) * 2
end

function star:update(dt)
	self.y = self.y + self.speed * dt

	if self.y > WINDOW_HEIGHT then
		self.y = -self.r
	end
end

function star:draw()
	love.graphics.setColor(255, 255, 255)

	love.graphics.circle("fill", self.x, self.y, self.r)

	love.graphics.setColor(255, 255, 255)
end

return star