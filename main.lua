require 'libraries.core'
core.init("switch")

require 'data.classes.global.star'
require 'libraries.dialog'

local concord = require 'libraries.concord'
concord.init({useEvents = false})

Entity    = concord.entity
Component = concord.component
System    = concord.system
Instance  = concord.instance

require 'data.components'
require 'data.entities'
require 'data.systems'

_env  = require 'data.environment'
state = require 'libraries.state'

require 'data.core'

function love.load()
    core.input.activate()
    logger.info("Game scale set to %d", _env.SCALE)

    love.math.setRandomSeed(os.time())
    love.math.random(); love.math.random()

    stars = {}
    dialogs = {}

    local STAR_COUNT = 256
    for i = 1, STAR_COUNT do
        stars[i] = star:new()
    end

    love.audio.setVolume(_env.VOLUME)

    state:change("intro")
end

function love.update(dt)
    dt = math.min(1 / 30, dt)

    _env.UPDATEGROUP(stars, dt)

    _env.UPDATEGROUP(dialogs, dt)

    state:update(dt)
end

function love.draw()
    _env.RENDERGROUP(stars)

    state:draw()

    _env.RENDERGROUP(dialogs)
end

function love.gamepadpressed(joystick, button)
    _env.GAMEPADPRESSGROUP(dialogs, button)

    state:gamepadpressed(joystick, button)

    if button == "back" or button == "minus" then
        love.event.quit()
    end
end

function love.gamepadaxis(joystick, axis, value)
    _env.GAMEPADAXISGROUP(dialogs, axis, value)

    state:gamepadaxis(joystick, axis, value)
end
