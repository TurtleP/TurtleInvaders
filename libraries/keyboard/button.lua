local button = class("button")

local COLORS =
{
    general = {0.840, 0.840, 0.840},
    highlight = {0.922, 0.922, 0.922},
    special = {0.796, 0.796, 0.796},
    button_text = {0.278, 0.278, 0.278},
    okay = {0.224, 0.333, 0.867}
}

local SPECIAL =
{
    ["DEL"] = love.graphics.newImage("libraries/keyboard/delete.png"),
    ["SHIFT"] = love.graphics.newImage("libraries/keyboard/shift.png"),
    ["SPACE"] = love.graphics.newImage("libraries/keyboard/space.png"),
    ["RETURN"] = love.graphics.newImage("libraries/keyboard/return.png")
}

function button:initialize(text, x, y, ...)
    self.x = x
    self.y = y
    
    local config = {...}
    
    self.width 	= config[1] or 85
    self.height = config[2] or 56

    self.color	= COLORS[config[3]] or COLORS.general
    self.textColor = COLORS[config[4]] or COLORS.button_text
    self.iconColor = COLORS[config[5]] or COLORS.general

    self.highlighted = false

    self.text = text
    self.font = love.graphics.newFont(24)

    self.caps = false
end

function button:getText()
    if not self:isSpecial() then
        return self.text
    else
        return nil
    end
end

function button:isSpecial()
    return SPECIAL[self.text] or self.text == "OK"
end

function button:doFunction(keyboard)
    if self.text == "SHIFT" then
        keyboard:toggleCaps()
    elseif self.text == "DEL" then
        keyboard:delete()
    elseif self.text == "RETURN" then
        return
    elseif self.text == "OK" then
        keyboard:submit()
    end
end

function button:toggleCaps()
    self.caps = not self.caps

    if self.caps then
        self.text = self.text:upper()
    else
        self.text = self.text:lower()
    end
end

function button:draw()
    love.graphics.setFont(self.font)

    love.graphics.setColor(self.color)
    love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)

    love.graphics.setColor(self.iconColor)
    if SPECIAL[self.text] then
        love.graphics.draw(SPECIAL[self.text], self.x + (self.width - SPECIAL[self.text]:getWidth()) / 2, self.y + (self.height - SPECIAL[self.text]:getHeight()) / 2)
        return
    end
    
    love.graphics.setColor(self.textColor)
    love.graphics.print(self.text, self.x + (self.width / 2) - self.font:getWidth(self.text) / 2, self.y + (self.height / 2) - self.font:getHeight() / 2)
end

return button