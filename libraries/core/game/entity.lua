local entity = class("entity", object)

function entity:initialize(x, y, width, height)
    object.initialize(self, x, y, width, height)

    self.category = 0
    self.mask = { false }

    self.state = "idle"

    self.health = 0
end

function entity:update(dt)

end

function entity:draw()

end

function entity:getCenter()
    return vector(self.x + (self.width / 2), self.y + (self.height / 2))
end

function entity:getWidth()
    return self.width
end

function entity:getHeight()
    return self.height
end

function entity:offset(offsetX, offsetY)
    self.x = self.x + offsetX
    self.y = self.y + offsetY
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

function entity:isMoving()
    return (self.speed.x ~= 0 or self.speed.y ~= 0)
end

function entity:isDead()
    return self.health == 0
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

function entity:setState(state)
    if self.state ~= state then
        self.quadi = 1
        self.timer = 0
        self.state = state
    end
end

function entity:setMask(id, value)
    self.mask[id] = value
end

function entity:getMask(id)
    return self.mask[id]
end

function entity:setGravity(gravity)
    self.gravity = gravity
end

function entity:getGravity()
    return self.gravity
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

return entity