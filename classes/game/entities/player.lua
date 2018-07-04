player = class("player", entity)

function player:initialize(x, y, character)
    entity.initialize(self, x, y - character.height, character.width, character.height)

    self.mask = { true, false, true, false }

    self.category = 2
    self.moveSpeed = 400
    self.health = 3

    self.invincibleTimer = 0

    for component, value in pairs(character) do
        self[component] = value
    end

    self:setMaxHealth(self.health)
    self.powerup = {obj = nil, class = nil}
    self.canShoot = true

    self.shootTimer = timer:new(0.4, function(self)
        self.canShoot = true
    end, nil, self)

    self.powerupTimer = nil
end

function player:update(dt)
    if self.invincible then
        self.invincibleTimer = self.invincibleTimer + 10 * dt
        if self.invincibleTimer > 20 then
            self.invincibleTimer = 0
            self.invincible = false
        end
    end
    self:animate(dt)

    self.shootTimer:update(dt)

    if self.powerupTimer then
        self.powerupTimer:update(dt)
    end

    if self.powerup.obj then
        self.powerup.obj:update(dt)
    end
end

function player:draw()
    if self:isDead() or self:isInvincible() then
        return
    end
    self:render()
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
    self:setSpeedX(self.moveSpeed)
end

function player:moveLeft()
    self:setSpeedX(-self.moveSpeed)
end

function player:stopMoving()
    self:setSpeed(0, 0)
end

function player:setHealth(amount)
    if amount < 0 then
        if not self.invincible then
            if self.health <= 1 then
                state:call("setGameover", true)
                self:die()
            end
            self.invincible = true
        else
            return
        end
    end
    entity.setHealth(self, amount)
end

function player:isInvincible()
    return math.floor(self.invincibleTimer) % 2 == 0 and self.invincibleTimer > 0
end

function player:setPowerup(powerupClass)
    if not powerupClass then
        self.powerup.obj = nil
        self.powerup.class = nil
        return
    else
        if self:getPowerup() then
            return
        end
    end

    self.powerup.class = powerupClass

    if not powerupClass.isBullet then --variable check
        self.powerup.obj = powerupClass:new(self.x, self.y, self)
    end

    self:createTimer()
end

function player:createTimer()
    local time = self.powerup.class.time

    if time ~= 0 then
        self.powerupTimer = timer:new(time, function(self)
            if self.powerup.obj then
                self.powerup.obj:delete()
            end
            self.powerup.class = nil
            self.powerupTimer = nil
        end, function(self)
            if self.powerup.obj then
                if self.powerup.obj.isBullet then
                    if self.powerup.obj.shouldTimeout then
                        return true
                    else
                        return true
                    end
                else
                    return true
                end
            end
        end, self)
    end
end

function player:getPowerup(name)
    if name then
        return tostring(self.powerup.class):find(name)
    end
    return self.powerup.class
end

function player:firePowerup(center)
    local layers = state:get("layers")
    local tmp = self.powerup.class:new(center.x, self.y, self)

    local offset = -(tmp:getHeight() + 6)
    if tostring(tmp) == "megacannon" then
        offset = 0
    end
    tmp:offset(-tmp:getWidth() / 2, offset)

    self.powerup.obj = tmp

    table.insert(layers[2], tmp)
end

function player:shoot()
    if not self.canShoot then
        return
    end

    local center = self:getCenter()
    if self:getPowerup() then
        if self.powerup.class.isBullet then
            self:firePowerup(center)
            return
        end
    end

    bullet:new(center.x - 3, self.y - 6)
    self.canShoot = false
end