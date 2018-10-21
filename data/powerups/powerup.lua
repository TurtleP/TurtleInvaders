powerup = class("powerup", entity)

function powerup:initialize(object, x, y, width, height)
    entity.initialize(self, x or 0, y or 0, width or 0, height or 0)

    self.isBullet = true
    self.trackPlayer = {false, false}
    self.alive = true
    
    self.time = -1

    self.enemyFilter = {enemy = true, megabat = true, raccoon = true}

    self.child = object
    self.shot = false
end

function powerup:update(dt)
    if self.time ~= -1 then
        self.time = math.max(self.time - dt, 0)

        if self.y + self.height < 0 then
            self.remove = true
        end
    end

    if self.trackPlayer and self.shot then
        local player = state:get("player")
        local center = player:getCenter()

        if self.trackPlayer[1] then
            self.child.x = center.x - (self.child.width / 2)
        end

        if self.trackPlayer[2] then
            self.child.y = center.y - (self.child.height / 2)
        end
    end

    if self.time == 0 then
        self:delete()
    end
end

function powerup:setData(object)
    self.child = object

    self.isBullet = object.isBullet
    self.time = object.time or -1
    self.trackPlayer = object.trackPlayer or {false, false}
    self.shot = false
end

function powerup:enable()
    local entity = self.child:new()
    physics:pushEntity(entity, 3)
    self.child = entity
end

function powerup:isShootable()
    return self.isBullet
end

function powerup:getTime()
    return self.time
end

function powerup:delete()
    local player = state:get("player")

    if self.child then
        self.child.remove = true
    end

    player:setPowerup(bullet)

    state:call("newRoulette", true)
end

function powerup:shoot(x, y)
    if self.child then
        if self.child.timeoutOnFire then
            if self.shot then
                return
            end
        end

        local entity = self.child:new(x, y)
        entity:offset(-(entity.width / 2), -(entity.height))

        physics:pushEntity(entity, 2)
        
        if entity.timeoutOnFire then
            self.child = entity
        end

        self.shot = true
    end
end