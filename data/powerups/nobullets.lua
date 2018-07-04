local nobullets = class("nobullets", powerup)

nobullets.time = 5
nobullets.isBullet = true
function nobullets:initialize()
    powerup.initialize(self, 0, 0, 0, 0)
end

return nobullets