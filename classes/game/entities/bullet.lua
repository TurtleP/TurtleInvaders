bullet = class("bullet", powerup)

local bulletSound = love.audio.newSource("audio/bullet.ogg", "static")

bullet.time = -1
bullet.isBullet = true
function bullet:initialize(x, y, speed, ...)
    powerup.initialize(self, nil, x, y, 6, 6)

    if not speed then
        self:setSpeedY(-600)
    else
        self:setSpeed(unpack(speed))
    end

    self.mask = { false, false, true, false, true }
    if self.speed.y > 0 then
        self.mask[2] = true
        self.mask[3] = false
    end

    self.category = 4

    bulletSound:play()
end

function bullet:update(dt)
    if self.y + self.height < 0 or self.y > WINDOW_HEIGHT then
        self.remove = true
    end
end

function bullet:draw()
    love.graphics.setColor(1, 0.922, 0.231)
    love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)

    love.graphics.setColor(1, 1, 1, 1)
end

function bullet:ceil(name, data)
    if self.enemyFilter[name] and self.speed.y < 0 then
        data:die()
        self.remove = true
    elseif name == "player" then
        if not self:checkForShield() then
            data:setHealth(-1)
        end
    end
    return false
end

function bullet:floor(name, data)
    if self.enemyFilter[name] and self.speed.y < 0 then
        data:die()
        self.remove = true
    elseif name == "player" then
        if not self:checkForShield() then
            data:setHealth(-1)
        end
    end
    return false
end

function bullet:right(name, data)
    if self.enemyFilter[name] and self.speed.y < 0 then
        data:die()
        self.remove = true
    elseif name == "player" then
        if not self:checkForShield() then
            data:setHealth(-1)
        end
    end
    return false
end

function bullet:left(name, data)
    if self.enemyFilter[name] and self.speed.y < 0 then
        data:die()
        self.remove = true
    elseif name == "player" then
        if not self:checkForShield() then
            data:setHealth(-1)
        end
    end
    return false
end

function bullet:checkForShield()
    local player = state:get("player")
    return tostring(player:getPowerup()):find("shield")
end