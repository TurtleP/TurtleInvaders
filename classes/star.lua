star = class("star")

function star:init(x, y, layer)
	self.x = x
	self.y = y

	self.layer = layer

	self.speed = 15 * ((layer - 1) / 2)
	self.r = (layer / 2)

	local depth = -INTERFACE_DEPTH

	if layer == 2 then
		depth = NORMAL_DEPTH
	elseif layer == 3 then
		depth = INTERFACE_DEPTH
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

	love.graphics.setDepth(NORMAL_DEPTH)
end