local charselect = class("charselect")

local portrait = require 'classes.charselect.portrait'

local CSS_WIDTH = 4
local CSS_HEIGHT = 3

function charselect:load()
    self.font = love.graphics.newFont("graphics/upheval.ttf", 80)
    self.characterFont = love.graphics.newFont("graphics/upheval.ttf", 40)
    self.gridFont = love.graphics.newFont("graphics/upheval.ttf", 20)

    self.cursorImage = love.graphics.newImage("graphics/charselect/cursor.png")
    self.cursorQuads = {}
    for i = 1, 2 do
        self.cursorQuads[i] = love.graphics.newQuad((i - 1) * 99, 0, 99, 99    , self.cursorImage:getWidth(), self.cursorImage:getHeight())
    end
    self.cursorTimer = 0
    self.cursorQuad = 1

    self.cusorPosition = vector(1, 1)

    self.grid = {}
    for x = 1, CSS_WIDTH do
        self.grid[x] = {}
        for y = 1, CSS_HEIGHT do
            self.grid[x][y] = portrait:new(characters[CSS_WIDTH * (y - 1) + x], 385 + (x - 1) * 140, 218 + (y - 1) * 160)
        end
    end

    self.cursors = {}
    for i = 1, 1 do
        self.cursors[i] = vector(1, 1)
    end
end

function charselect:update(dt)
    self.cursorTimer = self.cursorTimer + 4 * dt
    self.cursorQuad = math.floor(self.cursorTimer % 2) + 1
end

function charselect:draw()
    love.graphics.setFont(self.font)
    love.graphics.print("CHOOSE A CHARACTER", (WINDOW_WIDTH - self.font:getWidth("CHOOSE A CHARACTER")) / 2, WINDOW_HEIGHT * 0.09)

    love.graphics.setFont(self.gridFont)
    for x = 1, #self.grid do
        for y = 1, #self.grid[x] do
            self.grid[x][y]:draw(self.gridFont)
            if self.cursors[1].x == x and self.cursors[1].y == y then
                love.graphics.draw(self.cursorImage, self.cursorQuads[self.cursorQuad], self.grid[x][y].x, self.grid[x][y].y)
            end
        end
    end
end

function charselect:gamepadpressed(joy, button)
    if joy:getID() == 1 then
        if button == "b" then
            state:change("title")
        end
    end

    local _id = joy:getID() 
    local cursor = self.cursors[_id]

    if button == "dpright" then
        cursor.x = math.min(cursor.x + 1, #self.grid)
    elseif button == "dpleft" then
        cursor.x = math.max(cursor.x - 1, 1)
    elseif button == "dpup" then
        cursor.y = math.max(cursor.y - 1, 1)
    elseif button == "dpdown" then
        cursor.y = math.min(cursor.y + 1, #self.grid[cursor.x])
    end

    local selection = characters[CSS_WIDTH * (cursor.y - 1) + cursor.x]
    if button == "a" then
        state:change("game", {selection})
    end
end

return charselect