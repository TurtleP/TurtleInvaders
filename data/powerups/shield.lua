local shield = class("shield", powerup)

shield.time = 8
function shield:initialize(x, y, player)
    powerup.initialize(self, x, y, player:getWidth(), player:getHeight())
    self.player = player
end

return shield