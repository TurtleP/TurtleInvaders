local explosion = class("explosion", powerup)

explosion.time = 0.1
explosion.isBullet = true --it isn't but who cares
function explosion:initialize()
    powerup.initialize(self, 0, 0, 0, 0)

    local objects = state:get("objects")
    for k, v in ipairs(objects["enemy"]) do
        v:die(true)
    end
end

return explosion