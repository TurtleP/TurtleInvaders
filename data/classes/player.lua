player = class("player")

local playerImage = love.graphics.newImage("graphics/game/ship.png")

function player:initialize(x, y)
    self.x = x
    self.y = y

    self.wdith = 30
    self.height = 30

    self.speed = vector()
end

function player:update(dt)
    self.x = self.x + self.speed.x * dt
end

function player:draw()
    love.graphics.draw(playerImage, self.x, self.y, self.rotation, _env.SCALE, _env.SCALE)
end

function player:gamepadaxis(axis, value)
    if axis:find("right") then
        self.rotation = math.atan2(1, value)
    end
end