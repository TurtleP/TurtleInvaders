local sprite = love.graphics.newImage("graphics/game/ship.png")

return function(entity, x, y)
    entity.name = "player"

    return entity
    :give(Components.Collision)
    :give(Components.Controls)
    :give(Components.Health, 3)
    :give(Components.Mask, function(player, item)
        if item.isPassive then
            return nil
        end
        return "slide"
    end)
    :give(Components.Sprite, sprite, nil, nil)
    :give(Components.Position, x, y)
    :give(Components.Size, 60, 62)
    :give(Components.Velocity, 0)
end
