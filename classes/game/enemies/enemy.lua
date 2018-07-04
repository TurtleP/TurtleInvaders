enemy = class("enemy", entity)

local frostbullet = require 'data.powerups.frostbullet'

local enemyImage = love.graphics.newImage("graphics/game/enemies/bat.png")
local enemyQuads = {}
for y = 1, 2 do
    enemyQuads[y] = {}
    for x = 1, 3 do
        enemyQuads[y][x] = love.graphics.newQuad((x - 1) * 90, (y - 1) * 42, 90, 42, enemyImage:getWidth(), enemyImage:getHeight())
    end
end

local abilities =
{
    {"circle", 2},
    {"bullet", 7},
    {"shotgun", 13},
    {"freeze", 18},
    {"laser", 22}
}

local eyeColors =
{
    none = {1, 1, 1},
    bullet = {1, 0.922, 0.231},
    shotgun = {1, 0.757, 0.227},
    freeze = {0.259, 0.6474, 0.961},
    laser = {0.898, 0.224, 0.208}
}

function enemy:initialize(x, y)
    entity.initialize(self, x, y, 90, 42)

    self.timer = 0
    self.quadi = 1

    self.mask = { true, true, false, true, true }

    self.category = 3

    self:setSpeed(math.random(-150, 150), 120)

    local layers = state:get("layers")
    table.insert(layers[2], self)

    self:setMaxHealth(math.random(1, 3))

    self.powerup = nil
    if math.random() < 0.20 then
        local randomAbility = math.random(#abilities) 
        if abilities[randomAbility][2] <= state:get("wave") then
            self.powerup = abilities[randomAbility][1]
            
            if self.powerup ~= "cirlce" then
                self.shootTimer = timer:new(math.random(1, 3), function(self)
                    self:shoot()
                    self.shootTimer:setMaxTime(math.random(1, 3))
                end, nil, self)
            else
                self:setSpeedX(0)
                self.angle = 0
            end
        end
    end

    self.eyeColor = eyeColors[self.powerup] or {1, 1, 1}
end

function enemy:update(dt)
    self.timer = self.timer + 8 * dt
    self.quadi = math.floor(self.timer % 3) + 1

    if self.y > WINDOW_HEIGHT then
        self:clearInfo()
        self.remove = true
    end

    if self.shootTimer then
        self.shootTimer:update(dt)
    end

    if self.powerup == "circle" then
        self.angle = self.angle + 5 * dt

        --[[self.x = self.x + math.cos(self.angle) * 4
        self.y = self.y + math.sin(self.angle) * 4]]
    end
end

function enemy:draw()
    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(enemyImage, enemyQuads[1][self.quadi], self.x, self.y)

    love.graphics.setColor(self.eyeColor)
    love.graphics.draw(enemyImage, enemyQuads[2][self.quadi], self.x, self.y)

    love.graphics.setColor(1, 1, 1)
end

function enemy:upCollide(name, data)
    if name == "shield" then
        self:die(true)
    end

    if name == "player" then
        return self:playerCollide(data)
    end

    if name == "bullet" then
        return false
    end
end

function enemy:downCollide(name, data)
    if name == "shield" then
        self:die(true)
    end

    if name == "player" then
        return self:playerCollide(data)
    end

    if name == "bullet" then
        return false
    end
end

function enemy:rightCollide(name, data)
    if name == "shield" then
        self:die(true)
    end

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
    if name == "shield" then
        self:die(true)
    end

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

function enemy:clearInfo()
    local info = state:get("enemyInfo")

    if info:getEntity() == self then
        info:setEntity(nil)
    end
end

function enemy:die(force)
    local info = state:get("enemyInfo")

    if self.health >= 1 then
        info:setEntity(self)
        self:setHealth(-1, force)
    end
end

function enemy:setHealth(value, force)
    entity.setHealth(self, value)

    if self.health <= 0 or force then
        self:clearInfo()

        local player = state:get("player")
        if not player:getPowerup() and math.random() < 0.03 then
            state:call("newRoulette")
        end
        entity.die(self)
    end
end

function enemy:shoot()
    local center = self:getCenter()
    local powerups = state:get("powerups")
    
    if self.powerup == "laser" then
        self:shootPowerup(powerups[3], 600)
        return
    elseif self.powerup == "freeze" then
        self:shootPowerup(frostbullet, 600)
        return
    elseif self.powerup == "shotgun" then
        self:shootPowerup(powerups[8], true)
        return
    end

    bullet:new(center.x - 3, self.y + self.height + 6, {0, 600})
end

function enemy:shootPowerup(powerup, arg)
    local layers = state:get("layers")
    local center = self:getCenter()

    local tmp = powerup:new(center.x, self.y + self.height + 6, arg)
    tmp:offset(-tmp:getWidth() / 2, 0)

    table.insert(layers[2], tmp)
end

function enemy:playerCollide(player)
    if tostring(player:getPowerup()):find("shield") then
        return false
    end

    player:setHealth(-1)
    entity.die(self)
    self:clearInfo()

    return false
end