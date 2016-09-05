powerup = class("powerup")

function powerup:init(x, y)
	self.x = x
	self.y = y

	self.width = 14
	self.height = 14

	self.active = true
	self.passive = true

	self.gravity = 0

	self.speedx = 0
	self.speedy = 100

	self.t = "oneup"
end

function powerup:draw()
	love.graphics.draw(heartImage, self.x * scale, self.y * scale)
end