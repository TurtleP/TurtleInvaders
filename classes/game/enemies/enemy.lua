enemy = class("enemy", entity)

local enemyImage = love.graphics.newImage("graphics/game/enemies/bat.png")
local enemyQuads = {}
for y = 1, 2 do
	enemyQuads[y] = {}
	for x = 1, 3 do
		enemyQuads[y][x] = love.graphics.newQuad((x - 1) * 90, (y - 1) * 42, 90, 42, enemyImage:getWidth(), enemyImage:getHeight())
	end
end

function enemy:initialize(x, y)
	entity.initialize(self, x, y, 90, 42)

	self.timer = 0
	self.quadi = 1

	self.mask = { true, true, false, true }

	self.category = 3

	self:setSpeed(math.random(-150, 150), 120)

	local layers = state:get("objects")
	table.insert(layers["enemy"], self)
end

function enemy:update(dt)
	self.timer = self.timer + 8 * dt
	self.quadi = math.floor(self.timer % 3) + 1

	if self.y > WINDOW_HEIGHT then
		self.remove = true
	end
end

function enemy:draw()
	love.graphics.setColor(1, 1, 1)
	love.graphics.draw(enemyImage, enemyQuads[1][self.quadi], self.x, self.y)
	love.graphics.draw(enemyImage, enemyQuads[2][self.quadi], self.x, self.y)
end

function enemy:upCollide(name, data)
	if name == "player" then
		return self:playerCollide(data)
	end

	if name == "bullet" then
		return false
	end
end

function enemy:downCollide(name, data)
	if name == "player" then
		return self:playerCollide(data)
	end

	if name == "bullet" then
		return false
	end
end

function enemy:rightCollide(name, data)
	if name == "barrier" then
		self:setSpeedX(-self.speed.x)
	end

	if name == "player" then
		return self:playerCollide(data)
	end

	if name == "bullet" then
		return false
	end
end

function enemy:leftCollide(name, data)
	if name == "barrier" then
		self:setSpeedX(-self.speed.x)
	end

	if name == "player" then
		return self:playerCollide(data)
	end
	
	if name == "bullet" then
		return false
	end
end

function enemy:die()
	state:call("addScore", 100)
	entity.die(self)
end

function enemy:playerCollide(player)
	player:addLife(-1)
	entity.die(self)

	return false
end