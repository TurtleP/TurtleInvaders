bullet = class("bullet", entity)

local bulletSound = love.audio.newSource("audio/bullet.ogg", "static")

function bullet:initialize(x, y, speed, ...)
    entity.initialize(self, x, y, 6, 6)

    if not speed then
        self:setSpeedY(-600)
    else
        self:setSpeed(unpack(speed))
    end

    self.mask = { false, false, true }
    if self.speed.y > 0 then
        self.mask[2] = true
        self.mask[3] = false
    end

    self.category = 4

    bulletSound:play()

    local layer = state:get("layers")
    table.insert(layer[2], self)
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

function bullet:upCollide(name, data)
    if name == "enemy" and self.speed.y < 0 then
        data:die()
        self.remove = true
    elseif name == "player" then
        if not self:checkForShield() then
            data:setHealth(-1)
        end
    end
    return false
end

function bullet:downCollide(name, data)
    if name == "enemy" and self.speed.y < 0 then
        data:die()
        self.remove = true
    elseif name == "player" then
        if not self:checkForShield() then
            data:setHealth(-1)
        end
    end
    return false
end

function bullet:rightCollide(name, data)
    if name == "enemy" and self.speed.y < 0 then
        data:die()
        self.remove = true
    elseif name == "player" then
        if not self:checkForShield() then
            data:setHealth(-1)
        end
    end
    return false
end

function bullet:leftCollide(name, data)
    if name == "enemy" and self.speed.y < 0 then
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