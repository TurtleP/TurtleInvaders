local shotgun = class("shotgun", powerup)

shotgun.time = 8
function shotgun:initialize(x, y)
    powerup.initialize(self, x, y, 0, 0)
    self:shoot()
end

function shotgun:shoot()
    local objects = state:get("objects")
    
    table.insert(objects["bullet"], bullet:new(self.x, self.y, {-200, -200}))

    table.insert(objects["bullet"], bullet:new(self.x, self.y, {0, -400}))
    
    table.insert(objects["bullet"], bullet:new(self.x, self.y, {200, -200}))
end

return shotgun