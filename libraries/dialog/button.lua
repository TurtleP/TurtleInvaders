button = class("button")

function button:initialize(text, x, y, width, script)
    self.text = text

    self.x = x
    self.y = y

    self.width = width
    self.height = 35

    self.selected = false

    print(script)
    local callback = callbacks[script]
    if not callback then
        callback = function() end
    end
    self.press = callback
end

function button:select(selected)
    self.selected = selected
end

function button:update(dt)

end

function button:draw()
    love.graphics.setColor(0.008, 0.973, 0.773)

    local font = love.graphics.getFont()
    love.graphics.print(self.text, (self.x * _env.SCALE) + ((self.width * _env.SCALE) - font:getWidth(self.text)) / 2, (self.y * _env.SCALE) + ((self.height * _env.SCALE) - font:getHeight()) / 2 + 1)

    if self.selected then
        love.graphics.setColor(0.404, 0.671, 0.784, math.abs(math.sin(love.timer.getTime() * 2)) + 0.35)
        love.graphics.rectangle("line", self.x * _env.SCALE, self.y * _env.SCALE, self.width * _env.SCALE, self.height * _env.SCALE, 4 * _env.SCALE)
    end
end
