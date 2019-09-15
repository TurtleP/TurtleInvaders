local game = class("game")

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
    WORLD:addEntity(Entities.Player(Entity(), 40, 299))

    -- DUMB BARRIERS
    --WORLD:addEntity(Entities.Barrier(Entity(), 0, _env.WINDOW_H, _env.WINDOW_W, 1))
    WORLD:addEntity(Entities.Barrier(Entity(), -1, 0, 1, _env.WINDOW_H))
    WORLD:addEntity(Entities.Barrier(Entity(), _env.WINDOW_W, 0, 1, _env.WINDOW_H))
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
    WORLD:emit("update", dt)
end

function game:draw()
    WORLD:emit("draw")
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

    if button == "y" then
        self:spawnEntity("bat", {love.math.random(0, 600), love.math.random(0, 80)})
    end

    WORLD:emit("gamepadpressed", joy, button)
end

function game:gamepadaxis(joy, axis, value)
    WORLD:emit("gamepadaxis", joy, axis, value)
end

return game
