local SpriteRenderer = System({Components.Position, Components.Sprite})

function SpriteRenderer:init()
    self.sprites = {}
end

function SpriteRenderer:entityAdded(entity)
    local sprite   = entity:get(Components.Sprite)
    if self.sprites[entity] then
        sprite.graphic = self.sprites[entity][1]
        sprite.quads = self.sprites[entity][2]
    end
end

function SpriteRenderer:entityRemoved(entity)
    local sprite   = entity:get(Components.Sprite)
    self.sprites[entity] = {sprite.graphic, sprite.quads}
end

function SpriteRenderer:draw()
    for _, entity in ipairs(self.pool) do
        local position = entity:get(Components.Position)
        local sprite   = entity:get(Components.Sprite)

        if not sprite.draw then
            if sprite.quad then
                love.graphics.draw(sprite.graphic, sprite.quad, position.x * _env.SCALE, position.y * _env.SCALE, 0, _env.SCALE , _env.SCALE , sprite:GetOffsetX(entity), 0)
            else
                love.graphics.draw(sprite.graphic, position.x * _env.SCALE, position.y * _env.SCALE, 0, _env.SCALE , _env.SCALE , sprite:GetOffsetX(entity), 0)
            end
        else
            sprite:draw(position.x * _env.SCALE, position.y * _env.SCALE)
        end
    end
end

return SpriteRenderer
