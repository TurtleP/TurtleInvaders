function love.load()
    require 'libraries.core'
    core.init("switch")

    require 'data.classes.global.star'
    require 'libraries.dialog'

    _env  = require 'data.environment'
    state = require 'libraries.state'

    local concord = require 'libraries.concord'
    concord.init({useEvents = false})

    Entity    = concord.entity
    Component = concord.component
    System    = concord.system
    Instance  = concord.instance

    love.math.setRandomSeed(os.time())
    love.math.random(); love.math.random()
 
    stars = {}
    dialogs = {}
    for i = 1, 384 do
        stars[i] = star:new(love.math.random(0, _env.WINDOW_W), love.math.random(0, _env.WINDOW_H), love.math.random(0.25, 0.50))
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

    if button == "start" or button == "plus" then
        love.event.quit()
    end
end

function love.gamepadaxis(joystick, axis, value)
    _env.GAMEPADAXISGROUP(dialogs, axis, value)

    state:gamepadaxis(joystick, axis, value)
end