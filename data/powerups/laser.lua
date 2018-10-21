local laser = class("laser", powerup)

local laserSound = love.audio.newSource("audio/laser.ogg", "static")

laser.time = 5
laser.isBullet = true
function laser:initialize(x, y, speed)
    powerup.initialize(self, nil, x, y, 4, 12)
    
    laserSound:play()

    self:setSpeedY(-600)

    self.mask = { false, true, true }
end

function laser:draw()
    love.graphics.setColor(0.898, 0.224, 0.208) --229, 57, 53
    love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
end

function laser:ceil(name, data)
    if name == "enemy" and self.speed.y < 0 then
        data:die(true)
    elseif name == "player" then
        data:setHealth(-1)
    end
    return false
end

function laser:down(name, data)
    if name == "enemy" and self.speed.y < 0 then
        data:die(true)
    elseif name == "player" then
        data:setHealth(-1)
    end
    return false
end

function laser:left(name, data)
    if name == "enemy" and self.speed.y < 0 then
        data:die(true)
    elseif name == "player" then
        data:setHealth(-1)
    end
    return false
end

function laser:right(name, data)
    if name == "enemy" and self.speed.y < 0 then
        data:die(true)
    elseif name == "player" then
        data:setHealth(-1)
    end
    return false
end

return laser