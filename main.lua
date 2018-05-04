class = require 'libraries.middleclass'
vector = require 'libraries.vector'

require 'vars'

state = require 'libraries.state'

local star = require 'classes.game.star'

--love.graphics.setDefaultFilter("nearest", "nearest")

function love.load()
	love.math.setRandomSeed(os.time())

	STARFIELDS = {}
	for fieldIndex = 1, FIELDCOUNT do
		STARFIELDS[fieldIndex] = {}
		for starCount = 1, math.floor(STARLIMIT / FIELDCOUNT) do
			table.insert(STARFIELDS[fieldIndex], star:new(love.math.random(0, WINDOW_WIDTH), love.math.random(0, WINDOW_HEIGHT), fieldIndex))
		end
	end

	state:change("title")
end

function love.update(dt)
	dt = math.min(1 / 30, dt)

	for layer, objects in ipairs(STARFIELDS) do
		for _, star in ipairs(objects) do
			star:update(dt)
		end
	end

	state:update(dt)
end

function love.draw()
	for layer, objects in ipairs(STARFIELDS) do
		for _, star in ipairs(objects) do
			star:draw()
		end
	end

	state:draw()
end

function love.keypressed(key)
	state:keypressed(key)

	if key == "q" then
		love.event.quit()
	end
end

function love.keyreleased(key)

end

function love.gamepadpressed(joy, button)
	state:gamepadpressed(joy, button)
end

function love.gamepadreleased(joy, button)

end