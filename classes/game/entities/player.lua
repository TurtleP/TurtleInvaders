player = class("player", entity)

function player:initialize(x, y, character)
	entity.initialize(self, x, y - character.height, character.width, character.height)

	self.mask = { true, false, true, false }

	self.category = 2

	self.DEFAULT_SPEED = 400

	self.lives = 3

	for component, value in pairs(character) do
		self[component] = value
	end
end

function player:draw()
	love.graphics.draw(self.graphic, self.x, self.y)
end

function player:upCollide(name, data)
	if name == "enemy" then
		return false
	end
end

function player:downCollide(name, data)
	if name == "enemy" then
		return false
	end
end

function player:rightCollide(name, data)
	if name == "enemy" then
		return false
	end
end

function player:leftCollide(name, data)
	if name == "enemy" then
		return false
	end
end

function player:moveRight()
	self:setSpeedX(self.DEFAULT_SPEED)
end

function player:moveLeft()
	self:setSpeedX(-self.DEFAULT_SPEED)
end

function player:stopMoving()
	self:setSpeed(0, 0)
end

function player:addLife(amount)
	self.lives = math.max(self.lives - 1, 0)
end

function player:shoot()
	local center = self:getCenter()

	bullet:new(center.x - 3, self.y)
end