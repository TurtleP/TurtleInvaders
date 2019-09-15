local Primitive = Component(function(entity, which, color)
    entity.type = which
    entity.color = color
end)

function Primitive:GetType()
    return self.type
end

return Primitive
