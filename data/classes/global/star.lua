star = class("star")

local YEET_FACTOR = 2.50
local SLOW_DOWN_RATE = 128

function star:initialize(x, y, r)
    self.x = x
    self.y = y

    self.r = r

    self.opacity = love.math.random(0.50, 0.75)

    self.velocity = vector(0, (_env.WINDOW_H * YEET_FACTOR) / self.r)
    self.maxSpeed = vector(0, love.math.random(80, 128))
end

function star:update(dt)
    if self.velocity.y > self.maxSpeed.y then
        self.velocity.y = math.max(self.velocity.y - SLOW_DOWN_RATE * dt, self.maxSpeed.y)
    end

    self.y = self.y + self.velocity.y * dt
    if self.y + self.velocity.y * dt > _env.WINDOW_H then
        self.y = -self.maxSpeed.y
    end
end

function star:setVelocity(x, y)
    self.maxSpeed = vector(x, y)
end

function star:draw()
    love.graphics.setColor(1, 1, 1, self.opacity)
    love.graphics.circle("fill", self.x * _env.SCALE, self.y * _env.SCALE, self.r * _env.SCALE)

    love.graphics.setColor(1, 1, 1, 1)
end
