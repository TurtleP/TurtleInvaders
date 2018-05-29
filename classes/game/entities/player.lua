player = class("player", entity)

function player:initialize(x, y, character)
    entity.initialize(self, x, y - character.height, character.width, character.height)

    self.mask = { true, false, true, false }

    self.category = 2
    self.DEFAULT_SPEED = 400

    self:setMaxHealth(3)

    self.invincibleTimer = 0

    for component, value in pairs(character) do
        self[component] = value
    end
    
    self.powerup = {obj = nil, class = nil}
    self.canShoot = true

    self.shootTimer = timer:new(0.4, function()
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
    self:setSpeedX(self.DEFAULT_SPEED)
end

function player:moveLeft()
    self:setSpeedX(-self.DEFAULT_SPEED)
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

    if not powerupClass.isBullet then --function check
        self.powerup.obj = powerupClass:new(self.x, self.y, self)
    end

    local time = powerupClass.time
    self.powerupTimer = timer:new(time, function(self)
        if self.powerup.obj then
            self.powerup.obj:delete()
        end
        self.powerup.class = nil
        self.powerupTimer = nil
    end, nil, self)
end

function player:getPowerup(attribute)
    return self.powerup.class ~= nil
end

function player:firePowerup(center)
    local bullets = state:get("objects")["bullet"]
    local tmp = self.powerup.class:new(center.x, self.y)
    tmp:offset(-tmp:getWidth() / 2, 0)

    self.powerup.obj = tmp
    
    table.insert(bullets, tmp)
end

function player:shoot()
    if not self.canShoot then
        return
    end

    local center = self:getCenter()
    if self:getPowerup() then
        if self.powerup.class.isBullet then
            self:firePowerup(center)
        end
    else
        bullet:new(center.x - 3, self.y)
    end
    self.canShoot = false
end