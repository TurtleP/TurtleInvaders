local score = class("score")

function score:initialize()
    self.value = 0
    self.x = _env.WINDOW_W / 2 - 10
end

function score:add(amount)
    self.value = math.max(self.value + amount, 0)
end

function score:draw()
    love.graphics.print("SCORE:", (self.x * _env.SCALE) - Fonts.HUD:getWidth("SCORE:") / 2, 10 * _env.SCALE)
    love.graphics.print(self.value, (self.x * _env.SCALE) - Fonts.HUD:getWidth(self.value) / 2, 28 * _env.SCALE)
end

return score:new()
