return function(entity, x, y, width, height)
    return entity
    :give(Components.Position, x, y)
    :give(Components.Size, width, height)
    :give(Components.Static)
end
