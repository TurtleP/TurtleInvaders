local shadow = class("shadow", powerup)

shadow.time = 6
function shadow:initialize()
    powerup.initialize(self, 0, 0, 0, 0)
end

return shadow