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
audio = require 'data.musicloader'
state = require 'libraries.state'

require 'data.fonts'

function love.load()
    love.math.setRandomSeed(os.time())
    love.math.random(); love.math.random()

    stars = {}
    dialogs = {}
    for i = 1, 384 do
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
