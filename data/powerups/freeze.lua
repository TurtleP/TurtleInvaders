local freeze = class("freeze", powerup)

freeze.time = 7
function freeze:initialize(x, y)
    powerup.initialize(self, x, y, 0, 0)
    self.player = state:get("player")
    self.player:freeze()
end

function freeze:delete()
    self.player:unFreeze()
    powerup.delete(self)
end

return freeze