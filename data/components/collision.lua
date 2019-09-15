local Collision = Component(function(entity, args)
    if not args then
        args = {}
    end
    entity.floor = args["floor"] or function(self, entity, name, data)

    end
    --entity.y = y
end)

return Collision