require 'vars'

class = require 'libraries.middleclass'
state = require 'libraries.state'
hook = require 'libraries.hook'

achievements = require 'libraries.achievement'

json = require 'libraries.json'
save  = require 'libraries.save'
vector = require 'libraries.vector'

require 'libraries.character'

local star = require 'classes.common.star'

love.graphics.setDefaultFilter("nearest", "nearest")
io.stdout:setvbuf("no")

function love.load()
    math.randomseed(os.time())

    STARFIELDS = {}
    for fieldIndex = 1, FIELDCOUNT do
        STARFIELDS[fieldIndex] = {}
        for starCount = 1, math.floor(STARLIMIT / FIELDCOUNT) do
            table.insert(STARFIELDS[fieldIndex], star:new(math.random(0, WINDOW_WIDTH), math.random(0, WINDOW_HEIGHT), fieldIndex))
        end
    end

    titleSong = love.audio.newSource("audio/music/menu.ogg", "stream")
    titleSong:setLooping(true)

    --love.audio.setVolume(0)
    state:change("intro")
end

function love.update(dt)
    dt = math.min(1 / 30, dt)

    for layer, objects in ipairs(STARFIELDS) do
		for _, star in ipairs(objects) do
			if not state:get("paused") then
				star:update(dt)
			end
        end
    end

    state:update(dt)
    achievements:update(dt)
end

function love.draw()
    for layer, objects in ipairs(STARFIELDS) do
        for _, star in ipairs(objects) do
            star:draw()
        end
    end

    state:draw()
    achievements:draw()
end

function love.gamepadpressed(joy, button)
    state:gamepadpressed(joy, button)

    if button == "start" then
        love.event.quit()
    end
end

function love.gamepadaxis(joy, axis, value)
    state:gamepadaxis(joy, axis, value)
end

require 'libraries.HorizonNX'