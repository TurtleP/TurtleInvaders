local Position = Component(function(entity, x, y)
    entity.x = x
    entity.y = y
end)

function Position:Set(x, y)
    self.x = x
    self.y = y
end

function Position:Translate(dx, dy)
    self.x = self.x + dx
    self.y = self.y + dy
end

return Position
