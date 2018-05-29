local nobullets = class("nobullets", powerup)

nobullets.time = 5
function nobullets:initialize()
    powerup.initialize(self, 0, 0, 0, 0)
end

return nobullets