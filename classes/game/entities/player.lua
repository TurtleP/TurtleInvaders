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

function player:shoot()
    local center = self:getCenter()

    bullet:new(center.x - 3, self.y)
end