local game = class("game")

require "data.classes.game.display"
local SCORE = require "data.classes.game.score"
local PAUSE = require "data.classes.game.pause"
require 'data.classes.game.timer'

local WORLD = Instance()

function game:load()
    DebugRenderer = Systems.DebugRenderer()
    WORLD:addSystem(DebugRenderer, "draw")
    WORLD:disableSystem(DebugRenderer, "draw")

    SpriteRenderer = Systems.SpriteRenderer()
    WORLD:addSystem(SpriteRenderer, "draw")

    AnimationSystem = Systems.Animation()
    WORLD:addSystem(AnimationSystem, "update")

    PhysicsSystem = Systems.Physics()
    WORLD:addSystem(PhysicsSystem, "update")

    EventSystem = Systems.Event()
    WORLD:addSystem(EventSystem, "gamepadpressed")
    WORLD:addSystem(EventSystem, "gamepadaxis")

    PrimitiveSystem = Systems.Primitive()
    WORLD:addSystem(PrimitiveSystem, "draw")

    -- SINGLE INSTANCED PLAYER
    local player = Entities.Player(Entity(), 40, 299)
    WORLD:addEntity(player)
    self.display = display:new(player)

    -- DUMB BARRIERS
    --WORLD:addEntity(Entities.Barrier(Entity(), 0, _env.WINDOW_H, _env.WINDOW_W, 1))
    WORLD:addEntity(Entities.Barrier(Entity(), -1, 0, 1, _env.WINDOW_H))
    WORLD:addEntity(Entities.Barrier(Entity(), _env.WINDOW_W, 0, 1, _env.WINDOW_H))

    self.enemyTimer = timer:new(2, function()
        self:spawnEntity("bat", {love.math.random(0, 600), -28})
    end)
end

function game:addScore(amount)
    SCORE:add(amount)
end

function game:spawnEntity(name, args)
    if name == "bat" then
        WORLD:addEntity(Entities.Bat(Entity(), unpack(args)))
    elseif name == "bullet" then
        WORLD:addEntity(Entities.Bullet(Entity(),  unpack(args)))
    elseif name == "explosion" then
        WORLD:addEntity(Entities.Explosion(Entity(), unpack(args)))
    end
end

function game:removeEntity(entity)
    WORLD:removeEntity(entity)
end

function game:update(dt)
    if PAUSE:isActive() then
        return
    end

    WORLD:emit("update", dt)

    self.enemyTimer:update(dt)
end

function game:draw()
    WORLD:emit("draw")

    self.display:draw()

    SCORE:draw()

    if PAUSE:isActive() then
        PAUSE:draw()
    end
end

function game:gamepadpressed(joy, button)
    if button == "x" then
        _env.DEBUG = not _env.DEBUG

        if _env.DEBUG then
            WORLD:enableSystem(DebugRenderer, "draw")
        else
            WORLD:disableSystem(DebugRenderer, "draw")
        end
    end

    if button == "dpup" then
        DebugRenderer:Zoom(1)
    elseif button == "dpdown" then
        DebugRenderer:Zoom(-1)
    end

    if button == "start" or button == "plus" then
        PAUSE:toggle()
    end

    WORLD:emit("gamepadpressed", joy, button)
end

function game:gamepadaxis(joy, axis, value)
    WORLD:emit("gamepadaxis", joy, axis, value)
end

return game
