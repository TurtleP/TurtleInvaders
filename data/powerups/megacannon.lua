local megacannon = class("megacannon", powerup)

megacannon.time = 10
megacannon.isBullet = true
function megacannon:initialize(x, y, player)
    powerup.initialize(self, x, y, 0, 0)
    self.player = player
end

return megacannon