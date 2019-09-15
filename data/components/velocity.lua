local Velocity = Component(function(entity, pps, speed)
    entity.gravity = pps or 360
    entity.speed = speed or vector(0, 0)
end)

function Velocity:SetSpeed(x, y)
    self.speed = vector(x or 0, y or 0)
end

function Velocity:GetX()
    return self.speed.x
end

function Velocity:SetX(x)
    self.speed.x = x
end

function Velocity:GetY()
    return self.speed.y
end

function Velocity:SetY(y)
    self.speed.y = y
end

return Velocity
