require 'vars'

class = require 'libraries.middleclass'
vector = require 'libraries.vector'
json = require 'libraries.json'
state = require 'libraries.state'

require 'libraries.character'
local achievements = require 'libraries.achievement'


local star = require 'classes.game.star'

--love.graphics.setDefaultFilter("nearest", "nearest")

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

	state:change("intro")
end

function love.update(dt)
	dt = math.min(1 / 30, dt)

	for layer, objects in ipairs(STARFIELDS) do
		for _, star in ipairs(objects) do
			star:update(dt)
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

require 'libraries.horizon'