return function(entity, x, y)
    audio:play("shoot")

    entity.name = "bullet"
    entity.removeOnUpperScreen = true

    local function BulletMask(player, other)
        if other.name == "bat" then
            state:call("removeEntity", other)
            state:call("removeEntity", entity)

            local Position = other:get(Components.Position)
            state:call("spawnEntity", "explosion", {Position.x + 14, Position.y + 2})

            state:call("addScore", 100)

            return nil
        elseif other.isPassive or other.name == entity.name then
            return nil
        end
        return "slide"
    end

    return entity
    :give(Components.Collision)
    :give(Components.Mask, BulletMask)
    :give(Components.Position, x, y)
    :give(Components.Primitive, "circle", {0.99, 0.85, 0.21})
    :give(Components.Size, 2, 2)
    :give(Components.Velocity, 0, vector(0, -(180 * _env.SCALE)))
end
