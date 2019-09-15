local sprite = love.graphics.newImage("graphics/game/enemies/bat.png")

local quads  = {}
for i = 1, 3 do
    quads[i] = love.graphics.newQuad((i - 1) * 60, 0, 60, 28, sprite:getWidth(), sprite:getHeight())
end

local animation =
{
    idle =
    {
        rate = 8, frames = {1, 2, 3}
    }
}

return function(entity, x, y)
    entity.name = "bat"

    return entity
    :give(Components.Collision)
    :give(Components.Animation, animation)
    :give(Components.Sprite, sprite, quads, nil)
    :give(Components.Mask, function(player, item)
        if item.isPassive then
            return nil
        end
        return "slide"
    end)
    :give(Components.Position, x, y)
    :give(Components.Size, 60, 28)
    :give(Components.Velocity, 0, vector(0, love.math.random(90, 180)))
end
