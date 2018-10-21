local object = class("object")

function object:initialize(x, y, width, height)
    self.x = x
    self.y = y

    self.width = width
    self.height = height

    self.speed = vector()
    self.gravity = 0

    self.active = true
    self.static = false

    self.scale = 1
end

function object:setScale(scale)
    if not state:get("paused") then
        self.scale = scale
    end
end

function object:getXOffset()
    local offset = 0
    if self.scale < 0 then
        offset = self.width
    end
    
    return offset
end

function object:setSpeed(x, y)
    local speed = vector(x, y)
    self.speed = speed
end

function object:setSpeedX(velocityX)
    self.speed.x = velocityX
end

function object:setSpeedY(velocityY)
    self.speed.y = velocityY
end

function object:isStatic()
    return self.static
end

function object:unlock()
    self.freeze = false
    self.active = true
end

function object:die(reason)
    self.remove = true
    return true
end

local oldString = object.__tostring
function object:__tostring()
    return oldString(self):gsub("instance of class ", "")
end

return object