header = class("header")

local HEADER_FONT = love.graphics.newFont("graphics/fonts/BMArmy.ttf", 32 * _env.SCALE)

function header:initialize(text, x, y)
    self.text = text

    self.x = x
    self.y = y

    self.width = HEADER_FONT:getWidth(text)
    self.height = HEADER_FONT:getHeight()

    self.selected = false
    self.highlighted = false

    self.highlightWidth = 0
end

function header:getWidth()
    return self.width
end

function header:select(enable)
    self.selected = enable
end

function header:highlight(enable)
    self.highlighted = enable
end

function header:update(dt)
    if not self.selected then
        self.highlightWidth = math.max(self.highlightWidth - 450 * dt, 0)
    else
        self.highlightWidth = math.min(self.highlightWidth + 450 * dt, self.width)
    end
end

function header:draw()
    love.graphics.setFont(HEADER_FONT)

    love.graphics.setColor(0.5, 0.5, 0.5)
    if self.highlighted then
        love.graphics.setColor(1, 1, 1)
    end
    love.graphics.print(self.text, self.x, self.y)

    love.graphics.rectangle("fill", self.x + (self.width / 2) - self.highlightWidth / 2, self.y + self.height, self.highlightWidth, 4)
end
