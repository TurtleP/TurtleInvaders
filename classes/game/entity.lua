entity = class("entity")

function entity:initialize(x, y, width, height)
	self.x = x
	self.y = y

	self.width = width
	self.height = height

	self.speed = vector(0, 0)
	self.active = true

	self.gravity = 0
end

function entity:update(dt)
	--TEMPLATE
end

function entity:draw()
	--TEMPLATE
end

function entity:setSpeed(x, y)
	local speed = vector(x, y)

	if self.speed == speed then
		return
	end

	self.speed = speed
end

function entity:setSpeedX(velocityX)
	self.speed.x = velocityX
end

function entity:setSpeedY(velocityY)
	self.speed.y = velocityY
end

function entity:unlock()
	self.freeze = false
	self.active = true
end

function entity:getCenter()
	return vector(self.x + (self.width / 2), self.y + (self.height / 2))
end

function entity:die(reason)
	local whois = tostring(self)

	local center = self:getCenter()
	explosion:new(center.x - 24, center.y - 24)

	if whois ~= "player" then
		self.remove = true
		return
	else
		self.active = false
	end
end

function entity:isMoving()
	return (self.speed.x ~= 0 or self.speed.y ~= 0)
end

local oldString = entity.__tostring
function entity:__tostring()
	return oldString(self):gsub("instance of class ", "")
end