local sprite = love.graphics.newImage("graphics/game/enemies/bat.png")

local quads  = {}
for i = 1, 3 do
    quads[i] = love.graphics.newQuad((i - 1) * 60, 0, 60, 28, sprite:getWidth(), sprite:getHeight())
end

return function(entity, x, y)
    entity.name = "bat"

    local function BatMask(player, other)
        if other.isPassive or other.name == entity.name then
            return nil
        end

        if other.name == "player" then
            state:call("removeEntity", entity)

            local Position = entity:get(Components.Position)
            state:call("spawnEntity", "explosion", {Position.x + 14, Position.y + 2})

            local Health = other:get(Components.Health)
            Health:Add(-1)
        end

        return "slide"
    end

    return entity
    :give(Components.Collision)
    :give(Components.Animation)
    :give(Components.Sprite, sprite, quads, nil)
    :give(Components.Mask, BatMask)
    :give(Components.Position, x, y)
    :give(Components.Size, 60, 28)
    :give(Components.Velocity, 0, vector(0, love.math.random(90, 180)))
end
