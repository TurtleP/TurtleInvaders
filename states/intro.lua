local intro = class("intro")

local MAX_TIME = 3
local TIME_SPEED = 1.45

function intro:load()
    self.fade = 0
    self.time = 0

    self.splash = { image = love.graphics.newImage("graphics/intro/logo.png") }
    self.splash.position = vector((_env.WINDOW_W - self.splash.image:getWidth()) / 2, ((_env.WINDOW_H - self.splash.image:getHeight()) / 2))

    audio:play("intro")
end

function intro:update(dt)
    self.time = math.min(self.time + dt / TIME_SPEED, MAX_TIME)

    -- quad in -> quad out (0 -> 1 -> 0) for fade
    self.fade = math.max(0, -math.pow(self.time - 1, 2) + 1)

    if self.time == MAX_TIME then
        state:change("menu")
    end
end

function intro:draw()
    love.graphics.setColor(1, 1, 1, self.fade)
    love.graphics.draw(self.splash.image, self.splash.position.x * _env.SCALE,  self.splash.position.y * _env.SCALE, 0, _env.SCALE, _env.SCALE)
end

function intro:gamepadpressed(joystick, button)
    state:change("menu")
end

function intro:destroy()
    self.splash = nil

    audio:stop("intro")
end

return intro
