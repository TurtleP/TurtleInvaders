entity = class("entity")

function entity:initialize(x, y, width, height)
    self.x = x
    self.y = y

    self.width = width
    self.height = height

    self.speed = vector(0, 0)
    self.active = true

    self.gravity = 0

    self.health = 0
    self.maxHealth = self.health

    self.locked = false
end

function entity:update(dt)
    --TEMPLATE
end

function entity:draw()
    --TEMPLATE
end

function entity:getWidth()
    return self.width
end

function entity:getHeight()
    return self.height
end

function entity:resize(width, height)
	if not width then
		return
	end
	self.width = width

	if not height then
		return
	end

	self.height = height
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

function entity:offset(x, y)
    if not x then
        x = 0
    end

    self.x = self.x + x
    
    if not y then
        y = 0
    end
    self.y = self.y + y
end

function entity:getCenter()
    return vector(self.x + (self.width / 2), self.y + (self.height / 2))
end

function entity:freeze()
    self.locked = true
    self:setSpeed(0, 0)
end

function entity:unFreeze()
    self.locked = false
end

function entity:isFrozen()
    return self.locked
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

function entity:setMask(index, value)
    assert(self.mask[index] ~= nil and type(value) == "boolean", "Invalid index or non-bool value")

    print(index, tostring(value))
    self.mask[index] = value
end

function entity:isMoving()
    return (self.speed.x ~= 0 or self.speed.y ~= 0)
end

function entity:isDead()
    return self.health == 0
end

function entity:setHealth(value)
    self.health = math.max(0, math.min(self.health + value, self.maxHealth))
end

function entity:getHealth()
    return self.health
end

function entity:setMaxHealth(value)
    self.maxHealth = value
    self:setHealth(self.maxHealth)
end

function entity:getMaxHealth()
    return self.maxHealth
end

local oldString = entity.__tostring
function entity:__tostring()
    return oldString(self):gsub("instance of class ", "")
end