local Mask = Component(function(entity, filter)
    entity.filter = filter or function(self, entity, item) end
end)

return Mask