local shield = class("shield", powerup)

shield.time = 8
shield.trackPlayer = {true, true}
function shield:initialize(x, y)
    local player = state:get("player")
    powerup.initialize(self, x, y, player:getWidth(), player:getHeight())

    self.player = player

    self.category = 5
    self.mask = { false, false, true }

    self.player.shieldQuadi = 1
    self.player.shieldTimer = 0
end

function shield:update(dt)
    powerup.update(self, dt)
    self.player:shieldUpdate(dt)
end

function shield:draw()
    self.player:shieldDraw()
end

return shield