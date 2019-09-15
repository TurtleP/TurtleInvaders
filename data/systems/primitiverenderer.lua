local PrimitiveRenderer = System({Components.Position, Components.Size, Components.Primitive})

function PrimitiveRenderer:draw()
    for _, entity in ipairs(self.pool) do
        local position = entity:get(Components.Position)
        local primitive = entity:get(Components.Primitive)
        local size = entity:get(Components.Size)

        love.graphics.setColor(primitive.color)

        if primitive:GetType() == "circle" then
            love.graphics.circle("fill", position.x * _env.SCALE, position.y * _env.SCALE, (size.width / 2) * _env.SCALE)
        end

        love.graphics.setColor(1, 1, 1)
    end
end

return PrimitiveRenderer
