explosion = class("explosion")

function explosion:init(x, y)
	self.x = x
	self.y = y

	self.timer = 0
	self.quadi = 1
end

function explosion:update(dt)
	if self.quadi < 6 then
		self.timer = self.timer + 8 * dt
		self.quadi = math.floor(self.timer % 6) + 1
	else
		self.remove = true
	end
end

function explosion:draw()
	love.graphics.setDepth(-0.25)

	love.graphics.draw(explosionImage, explosionQuads[self.quadi], self.x, self.y)

	love.graphics.setDepth(0)
end