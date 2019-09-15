local sprite = love.graphics.newImage("graphics/game/effects/explosion.png")
local quads = {}
for i = 1, 6 do
    quads[i] = love.graphics.newQuad((i - 1) * 32, 0, 32, 32, sprite:getWidth(), sprite:getHeight())
end

return function(entity, x, y)
    entity.isPassive = true

    audio:play("explode")

    return entity
    :give(Components.Animation, nil, {removeOnFinish = true})
    :give(Components.Sprite, sprite, quads)
    :give(Components.Position, x, y)
    :give(Components.Size, 32, 32)
end
