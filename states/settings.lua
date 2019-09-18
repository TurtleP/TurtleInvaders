local settings = class("settings")

require 'data.classes.menu.header'

function settings:load()
    self.headers = {}

    local headerInfo = {"GENERAL", "TROPHIES"}
    local width = 400
    for i = 1, #headerInfo do
        table.insert(self.headers, header:new(headerInfo[i], 60 + (i - 1) * width, 40))
    end

    self.headers[1]:highlight(true)

    self.smallFont = love.graphics.newFont("graphics/fonts/BMArmy.ttf", 16 * _env.SCALE)
end

function settings:update(dt)
    _env.UPDATEGROUP(self.headers, dt)
end

function settings:draw()
    _env.RENDERGROUP(self.headers)

    love.graphics.setFont(self.smallFont)

    love.graphics.setColor(0.5, 0.5, 0.5)
    love.graphics.print(_env.VERSION, (_env.WINDOW_W * _env.SCALE) - self.smallFont:getWidth(_env.VERSION)  -40 * _env.SCALE, (_env.WINDOW_H - 40) * _env.SCALE)
end

function settings:gamepadpressed(joy, button)
    if button == "b" then
        state:change("menu", 2)
    end
end

return settings
