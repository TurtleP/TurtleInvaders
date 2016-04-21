star = class("star")

function star:init(x, y, layer)
	self.x = x
	self.y = y

	self.layer = layer

	self.speed = 15 * ((layer - 1) / 2)
	self.r = (layer / 2)

	local depth = 2

	if layer == 2 then
		depth = 1
	elseif layer == 3 then
		depth = 0
	end

	self.depth = depth
end

function star:update(dt)
	self.y = self.y + self.speed * dt

	if self.y > util.getHeight() then
		self.y = -4
	end
end

function star:draw()
	love.graphics.setDepth(self.depth)

	love.graphics.setColor(255, 255, 255)

	love.graphics.rectangle("fill", self.x, self.y, self.r, self.r)

	love.graphics.setColor(255, 255, 255)

	love.graphics.setDepth(0)
end