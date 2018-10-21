local shotgun = class("shotgun", powerup)

shotgun.time = 8
shotgun.isBullet = true
function shotgun:initialize(x, y, flip)
    powerup.initialize(self, x, y, 0, 0)
    self:shoot(flip)
end

function shotgun:shoot(flip)
    local layers = state:get("layers")

    local mul = 1
    print(tostring(flip))
    if type(flip) == "boolean" and flip then
        mul = -1
    end

    table.insert(layers[2], bullet:new(self.x, self.y, {-200, -200 * mul}))

    table.insert(layers[2], bullet:new(self.x, self.y, {0, -400 * mul}))
    
    table.insert(layers[2], bullet:new(self.x, self.y, {200, -200 * mul}))
end

return shotgun