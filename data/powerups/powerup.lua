powerup = class("powerup", entity)

powerup.isBullet = false
function powerup:initialize(x, y, width, height)
    entity.initialize(self, x, y, width, height)
   
    self.alive = true
    self.time = 5
end

function powerup:update(dt)
    if self.y + self.height < 0 then
        self.remove = true
    end

    if self.trackPlayer then
        local player = state:get("player")
        local center = player:getCenter()

        if self.trackPlayer[1] then
            self.x = center.x - (self.width / 2)
        end

        if self.trackPlayer[2] then
            self.y = center.y - (self.height / 2)
        end
    end
end

function powerup:getTime()
    return self.time
end

function powerup:delete()
    local player = state:get("player")
    player:setPowerup(nil)

    state:call("newRoulette", true)

    self.remove = true
end

function powerup:shoot()
    --empty
end