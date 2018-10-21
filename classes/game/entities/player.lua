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
    
    self.powerup = powerup:new()

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

    if self.powerup.update then
        self.powerup:update(dt)
    end
end

function player:draw()
    if self:isDead() or self:isInvincible() then
        return
    end
    self:render()
end

function player:ceil(name, data)
    if name == "enemy" then
        return false
    end
end

function player:floor(name, data)
    if name == "enemy" then
        return false
    end
end

function player:right(name, data)
    if name == "enemy" then
        return false
    end
end

function player:left(name, data)
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
    self.powerup:setData(powerupClass)

    if not self.powerup.child:isShootable() then
        self.powerup:enable()
    end
end

function player:getPowerup(name)
    if name then
        return tostring(self.powerup.class):find(name)
    end
    return self.powerup.child ~= nil
end

function player:shoot()
    if not self.canShoot then
        return
    end

    if not self.powerup.child then
        self.powerup.child = bullet
    end

    if self:getPowerup() then
        if self.powerup.child:isShootable() then
            self.powerup:shoot(self.x + (self.width / 2), self.y - 2)
        end
    end

    self.canShoot = false
end