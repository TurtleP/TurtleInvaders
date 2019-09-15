local Sprite = Component(function(entity, graphic, quads, drawfunc)
    entity.graphic = graphic
    entity.quads   = quads

    entity.quad = (quads and quads[1]) or quads
    entity.direction = _env.SCALE

    entity.draw = drawfunc
end)

function Sprite:GetOffsetX(entity)
    local size = entity:get(Components.Size)

    if self.direction < 0 then
        return size.width
    end
    return 0
end

function Sprite:SetIndex(index)
    assert(self.quads[index] ~= nil, "Index " .. tostring(index) .. " does not exist.")
    self.quad = self.quads[index]
end

return Sprite
