powerup = class("powerup", entity)

function powerup:initialize(x, y, width, height)
    entity.initialize(self, x, y, width, height)
   
    self.alive = true
    self.time = 5
end

function powerup:update(dt)
    if self.y + self.height < 0 then
        self.remove = true
    end
end

function powerup:getTime()
    return self.time
end

function powerup:delete()
    local player = state:get("objects")["player"][1]
    player:setPowerup(nil)

    state:call("newRoulette", true)

    self.remove = true
end

function powerup:shoot()
    --empty
end