local laser = class("laser", powerup)

local laserSound = love.audio.newSource("audio/laser.ogg", "static")

laser.time = 5
laser.isBullet = true
function laser:initialize(x, y)
    powerup.initialize(self, x, y, 4, 12)
    
    laserSound:play()
    self:setSpeedY(-600)

    self.mask = { false, false, true }
end

function laser:draw()
    love.graphics.setColor(0.898, 0.224, 0.208) --229, 57, 53
    love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
end

function laser:upCollide(name, data)
    if name == "enemy" then
        self:enemyCollide(data)
        return false
    end
end

function laser:downCollide(name, data)
    if name == "enemy" then
        self:enemyCollide(data)
        return false
    end
end

function laser:leftCollide(name, data)
    if name == "enemy" then
        self:enemyCollide(data)
        return false
    end
end

function laser:rightCollide(name, data)
    if name == "enemy" then
        self:enemyCollide(data)
        return false
    end
end

function laser:enemyCollide(data)
    data:die(true)
end

return laser