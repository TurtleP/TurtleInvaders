dialog = class("dialog")

local TIME_SPEED = 1.45
local MAX_TIME = 2

function dialog:initialize(message)
    self.width = 385
    self.height = 170

    self.x = (_env.WINDOW_W - self.width) / 2
    self.y = (_env.WINDOW_H - self.height) / 2

    self.timer = 0
    self.opacity = {window = 0, this = 0}

    self.fonts = 
    {
        love.graphics.newFont(16 * _env.SCALE),
        love.graphics.newFont(14 * _env.SCALE)
    }

    self.config = messages[message]
    self.textPosition = vector(self.x * _env.SCALE + ((self.width * _env.SCALE) - self:calculateTextWidth()) / 2, ((self.y * _env.SCALE) + ((self.height * _env.SCALE) - self:calculateTextHeight()) / 2))

    self.buttons = {}

    local buttonConfig = self.config.buttons
    if buttonConfig then
        for i = 1, #buttonConfig do
            local width = self.width * buttonConfig[i].width
            table.insert(self.buttons, button:new(buttonConfig[i].text, self.x + (i - 1) * width, self.y + (self.height - 35), width, buttonConfig[i].callback))
        end
        self.buttons[1]:select(true)
    end
    self.currentButton = 1

    self.open = true
end

function dialog:calculateTextWidth()
    local width = 0

    local textConfig = self.config.body
    for i = 1, #textConfig do
        local value = textConfig[i]

        if value then
            local newWidth = self.fonts[1]:getWidth(value[2])

            if newWidth > width then
                width = newWidth
            end
        end
    end
    
    return width
end

function dialog:getButtonPadding()
    return (#self.config.buttons - 1) * 35 * _env.SCALE
end

function dialog:calculateTextHeight()
    local buttonHeight = self:getButtonPadding()
    return (#self.config.body * self.fonts[1]:getHeight()) + buttonHeight
end

function dialog:update(dt)
    self.opacity.window = math.min(self.opacity.window + dt / 0.4, 0.65)
    self.opacity.this = math.min(self.opacity.this + dt / 0.4, 1)

    return not self.open
end

function dialog:draw()
    love.graphics.setColor(0, 0, 0, self.opacity.window)
    love.graphics.rectangle("fill", 0, 0, _env.WINDOW_W * _env.SCALE, _env.WINDOW_H * _env.SCALE)

    love.graphics.setColor(0.275, 0.275, 0.275, self.opacity.this)
    love.graphics.rectangle("fill", self.x * _env.SCALE, self.y * _env.SCALE, self.width * _env.SCALE, self.height * _env.SCALE, 4 * _env.SCALE)

    love.graphics.setColor(1, 1, 1, self.opacity.this)

    local textConfig = self.config.body
    for i = 1, #textConfig do
        local value = textConfig[i]

        if value then
            local font = self.fonts[value[1]] or self.fonts[1]
            local text = value[2]

            love.graphics.setFont(font)
            love.graphics.print(text, math.floor(self.textPosition.x), self.textPosition.y + (i - 1) * self.fonts[1]:getHeight())
        end
    end

    love.graphics.setFont(self.fonts[1])

    local buttonConfig = self.config.buttons
    if #buttonConfig > 0 then
        love.graphics.setColor(0.404, 0.404, 0.404)
        self:renderBorderLines(#buttonConfig)

        _env.RENDERGROUP(self.buttons)
    end

    love.graphics.setColor(1, 1, 1, 1)
end

function dialog:cursorMove(right)
    self.buttons[self.currentButton]:select(false)
    if right then
        self.currentButton = math.min(self.currentButton + 1, #self.buttons)
    else
        self.currentButton = math.max(self.currentButton - 1, 1)
    end
    self.buttons[self.currentButton]:select(true)
end

function dialog:gamepadpressed(button)
    if button == "dpright" then
        self:cursorMove(true)
    elseif button == "dpleft" then
        self:cursorMove(false)
    end

    if button == "a" then
        self.buttons[self.currentButton]:press(self)
    end
end

function dialog:gamepadaxis(axis, value)
    if axis == "leftx" then
        if value > 0.5 then
            self:cursorMove(true)
        elseif value < -0.5 then
            self:cursorMove(false)
        end
    end
end

function dialog:renderBorderLines(count)
    love.graphics.rectangle("fill", self.x * _env.SCALE, ((self.y * _env.SCALE) + ((self.height * _env.SCALE) - self:getButtonPadding())), (self.width * _env.SCALE), 1 * _env.SCALE)
    if count == 2 then
        love.graphics.rectangle("fill", (self.x + (self.width / 2) - 1) * _env.SCALE, ((self.y * _env.SCALE) + ((self.height * _env.SCALE) - self:getButtonPadding()) + 1), 1 * _env.SCALE, 34 * _env.SCALE)
    end
end