local _PACKAGE = (...):sub(1, (...):find("%."))
local hook = require(_PACKAGE .. "libraries.hook")

window:setSize(400, 480)

local graphics = {}

graphics.SCREEN = "top"
graphics.RENDER = "top"

graphics.SCISSOR =
{
    top = {0, 0, 400, 240},
    bottom = {40, 240, 320, 240}
}

local function applyTouchScreen(x, y)
    if graphics.SCREEN == "bottom" then
        return x + 40, y + 240
    end
    return x, y
end

--Hook into functions
local oldClear = love.graphics.clear
local oldDraw = love.draw
local oldErrHand = love.errhand
local oldPresent = love.graphics.present
local oldRectangle = love.graphics.rectangle
local oldDrawable = love.graphics.draw

function graphics.rectangle(mode, x, y, ...)
    x, y = applyTouchScreen(x, y)
    oldRectangle(mode, x, y, ...)
end

function graphics.drawable(image, quad, x, y, ...)
    if type(quad) == "number" then
        quad, x = applyTouchScreen(quad, x) --confusing and dumb
    else
        x, y = applyTouchScreen(x, y)
    end
    oldDrawable(image, quad, x, y, ...)
end

function graphics.drawScreen(screen)
    local scissor = graphics.SCISSOR[screen]
    love.graphics.setScissor(unpack(scissor))
    oldRectangle("line", unpack(scissor))
end

--defined because Löve Potion uses it
function love.graphics.setScreen(screen)
    graphics.SCREEN = screen
end

function graphics.postDraw()
    love.graphics.setScissor()
end

function graphics.draw()
    graphics.drawScreen("top")
    oldDraw()

    graphics.drawScreen("bottom")
    oldDraw()
end

function graphics.drawBorder()
    love.graphics.setColor(0.3, 0.3, 0.3)

    oldRectangle("fill", 0, 240, 40, 240)
    oldRectangle("fill", 360, 240, 40, 240)

    love.graphics.setColor(1, 1, 1)
end

function graphics.deleteHooks()
    hook.clear(love.graphics.present)
end

love.graphics.rectangle = graphics.rectangle
love.graphics.draw = graphics.drawable

function love.draw()
    graphics.draw()
end

love.graphics.present = hook.add(oldPresent, function()
    graphics.postDraw()
    graphics.drawBorder()
end)

love.errhand = hook.add(oldErrHand, graphics.deleteHooks)