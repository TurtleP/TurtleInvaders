return function(entity, x, y)
    audio:play("shoot")

    return entity
    :give(Components.Collision)
    :give(Components.Mask, function(player, item)
        if item.name == "bat" then
            state:call("removeEntity", item)
            state:call("removeEntity", entity)

            local Position = item:get(Components.Position)
            state:call("spawnEntity", "explosion", {Position.x + 14, Position.y + 2})
        end
        return "slide"
    end)
    :give(Components.Position, x, y)
    :give(Components.Primitive, "circle", {0.99, 0.85, 0.21})
    :give(Components.Size, 2, 2)
    :give(Components.Velocity, 0, vector(0, -(180 * _env.SCALE)))
end
