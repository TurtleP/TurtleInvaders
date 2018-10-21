boss = class("boss", entity)

local bossMusic = love.audio.newSource("audio/music/boss.ogg", "stream")
bossMusic:setLooping(true)

function boss:initialize(x, y, width, height, health)
    entity.initialize(self, x, y, width, height)

    self.quadi = 1
    self.timer = 0

    local speeds = {-240, 240}
    local speed = speeds[love.math.random(#speeds)]

    self:setSpeedX(speed)

    self.category = 5

    self.health = health
    self.maxHealth = self.health
    self.actualHealth = health * 2

    self:setMask(1, true)
    self:setMask(4, true)
    self:setMask(3, false)

    self.invincibleTimer = 0
    self.explosionCount = 0

    physics:pushEntity(self, 2)

    self.explosionTimer = timer:new(love.math.random(0.02, 0.04), function(self)
        if self.explosionCount > 100 then
            local player = state:get("player")
            player:setMaxHealth(player:getMaxHealth() + 1)
            state:call("newWave", true)
            self:clearInfo()
            entity.die(self)
            return
        end
        state:call("setShakeValue", 10)
        explosion:new(love.math.random(self.x, self.x + (self.width - 48)), love.math.random(self.y, self.y + (self.height - 48)))
        self.explosionCount = self.explosionCount + 1
    end, nil, self)

    titleSong:stop()
    bossMusic:play()
end

function boss:update(dt)
    if self.health > 0 then
        self.timer = self.timer + 7 * dt
        self.quadi = math.floor(self.timer % #self.quads) + 1

        if self.invincible then
            self.invincibleTimer = self.invincibleTimer + 10 * dt
            if self.invincibleTimer > 20 then
                self.invincibleTimer = 0
                self.invincible = false
            end
        end
    else
        self.explosionTimer:update(dt)
    end
end

function boss:draw()
    if self:isInvincible() then
        return
    end

    local offset = 0
    if self.float then
        offset = math.sin(love.timer.getTime() * 8) * 16
    end
    love.graphics.draw(self.image, self.quads[self.quadi], self.x, self.y + offset)
end

function boss:die()
    local info = state:get("enemyInfo")

    if self.health >= 1 then
        if self:isInvincible() then
            return
        end

        info:setEntity(self)
        self:setHealth(-1, force)
    end
end

function boss:clearInfo()
    local info = state:get("enemyInfo")

    if info:getEntity() == self then
        info:setEntity(nil)
    end

    bossMusic:stop()
    titleSong:play()
end

function boss:setHealth(value, force)
    self.actualHealth = math.max(self.actualHealth - 1, 0)

    if self.actualHealth % 2 == 0 and self.health >= 1 then
        self.invincible = true
        entity.setHealth(self, value)
    end
    
    if self.health <= 0 then
        self:setSpeedX(0)
    end
    print(self.health)
end

function boss:isInvincible()
    return math.floor(self.invincibleTimer) % 2 == 0 and self.invincibleTimer > 0
end

function boss:ceil(name, data)
    if name == "bullet" then
        return self:global(name, data)
    end
end

function boss:floor(name, data)
    if name == "bullet" then
        return self:global(name, data)
    end
end

function boss:left(name, data)
    if name == "bullet" then
        return self:global(name, data)
    end

    if name == "barrier" then
        self:setSpeedX(-self.speed.x)
        return false
    end
end

function boss:right(name, data)
    if name == "bullet" then
        return self:global(name, data)
    end

    if name == "barrier" then
        self:setSpeedX(-self.speed.x)
        return false
    end
end

function boss:global(name, data)
    if name == "bullet" then
        return false
    end
end