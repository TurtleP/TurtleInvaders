bullet = class("bullet", entity)

local bulletSound = love.audio.newSource("audio/bullet.ogg", "static")

function bullet:initialize(x, y)
	entity.initialize(self, x, y, 4, 4)

	self:setSpeedY(-600)

	self.mask = { false, false, true }

	self.category = 4

	bulletSound:play()

	local layer = state:get("objects")
	table.insert(layer["bullet"], self)
end

function bullet:update(dt)
	if self.y + self.height < 0 then
		self.remove = true
	end
end

function bullet:draw()
	love.graphics.setColor(1, 1, 0)
	love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)

	love.graphics.setColor(1, 1, 1, 1)
end

function bullet:upCollide(name, data)
	if name == "enemy" then
		data:die()
		self.remove = true
	end
end

function bullet:downCollide(name, data)
	if name == "enemy" then
		data:die()
		self.remove = true
	end
end

function bullet:rightCollide(name, data)
	if name == "enemy" then
		data:die()
		self.remove = true
	end
end

function bullet:leftCollide(name, data)
	if name == "enemy" then
		data:die()
		self.remove = true
	end
end