local pause = class("pause")

function pause:initialize()
    self.width = 160
    self.height = 150

    self.x = (_env.WINDOW_W - self.width) / 2
    self.y = (_env.WINDOW_H - self.height) / 2

    self.active = false
end

function pause:draw()
    love.graphics.setColor(0.05, 0.05, 0.05, 0.75)
    love.graphics.rectangle("fill", self.x * _env.SCALE, self.y * _env.SCALE, self.width * _env.SCALE, self.height * _env.SCALE, 4 * _env.SCALE)

    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.setFont(Fonts.PAUSE_HEADER)
    love.graphics.print("GAME PAUSED", (self.x + (self.width / 2)) * _env.SCALE - Fonts.PAUSE_HEADER:getWidth("GAME PAUSED") / 2, (self.y + 10) * _env.SCALE)
end

function pause:toggle()
    self.active = not self.active
end

function pause:isActive()
    return self.active
end

return pause:new()
