local physics = {}

local min = math.min
local floor = math.floor
local ceil = math.ceil

function physics:initialize(layers)
    assert(type(layers) == "table", "Cannot initialize physics. Table expected, got " .. type(layers))

    self.layers = layers
end

function physics:update(dt)
    for index, layer in pairs(self.layers) do
        for objectIndex, object in pairs(layer) do
            if not object:isStatic() then
                local hor, ver = false, false
                
                object.speed.y = min(object.speed.y + object.gravity * dt, window:getHeight())

                for _, otherLayer in pairs(self.layers) do
                    for _, otherObject in pairs(otherLayer) do 
                        if object ~= otherObject and self:maskLookup(object, otherObject.category) then
                            hor, ver = self:resolve(object, otherObject, dt)
                        end
                    end
                end

                --versus tiles?
                local xstart = floor((object.x + object.speed.x * dt) / 16) + 1
                local ystart = floor((object.y + object.speed.y * dt) / 16) + 1

                local from, to = xstart, xstart + floor(object.width / 16)
                local dir = 1

                if object.speed.x < 0 then
                    from, to = to, from
                    dir = -1
                end

                for x = from, to, dir do
                    for y = ystart, ystart + ceil(object.height / 16) do
                        if self.layers["tile"] and self.layers["tile"][x .. "-" .. y] then
                            local thor, tver = self:resolve(object, {"tile", self.layers["tile"][x .. "-" .. y]}, dt)

                            if thor then
                                hor = true
                            elseif tver then
                                ver = true
                            end
                        end
                    end
                end

                --move object
                if not hor then
                    object.x = object.x + object.speed.x * dt
                end

                if not ver then
                    object.y = object.y + object.speed.y * dt
                end

                --check if we can remove
                if object:update(dt) or object.remove then
                    self:popEntity(index, objectIndex)
                end
            end
        end
    end
end

function physics:pushEntity(object, layerIndex)
    assert(type(object) ~= "nil", "Cannot push nil object to physics!")

    if not layerIndex then
        layerIndex = 1
    end
    
    table.insert(self.layers[layerIndex], object)
end

function physics:popEntity(layerIndex, position)
    assert(type(position) == "number" and position ~= nil, "Cannot pop object. Number expected, got " .. type(position))

    if not layerIndex then
        layerIndex = 1
    end
    table.remove(self.layers[layerIndex], position)
end

function physics:checkBounds(x, y, width, height, filter)
    local out = {}

    return out
end

function physics:maskLookup(object, id)
    return object:getMask(id)
end

function physics:resolve(object, otherObject, dt)
    local x = object.x + object.speed.x * dt
    local y = object.y + object.speed.y * dt

    local name, otherName = tostring(object), tostring(otherObject)

    local hor, ver = false, false
    if self:aabb(object.x, y, object.width, object.height, otherObject.x, otherObject.y, otherObject.width, otherObject.height) then
        ver = self:handleVertical(name, object, otherName, otherObject)
    elseif self:aabb(x, object.y, object.width, object.height, otherObject.x, otherObject.y, otherObject.width, otherObject.height) then
        hor = self:handleHorizontal(name, object, otherName, otherObject)
    end

    return hor, ver
end

function physics:handleHorizontal(name, object, otherName, otherObject)
    if object.speed.x > 0 then
        if otherObject.speed.x < 0 then
            if otherObject.left then
                if otherObject:left(name, object) ~= false then
                    otherObject.speed.x = 0
                end
            else
                otherObject.speed.x = 0
            end
        end

        if object.right then
            if object:right(otherName, otherObject) ~= false then
                object.x = otherObject.x - object.width
                object.speed.x = 0
                return true
            end
        else
            object.x = otherObject.x - object.width
            object.speed.x = 0
            return true
        end
    else
        if otherObject.speed.x > 0 then
            if otherObject.right then
                if otherObject:right(name, object) ~= false then
                    otherObject.speed.x = 0
                end
            else
                otherObject.speed.x = 0
            end
        end

        if object.left then
            if object:left(otherName, otherObject) ~= false then
                object.x = otherObject.x + otherObject.width
                object.speed.x = 0
                return true
            end
        else
            object.x = otherObject.x + otherObject.width
            object.speed.x = 0
            return true
        end
    end
    return false
end

function physics:handleVertical(name, object, otherName, otherObject)
    if object.speed.y > 0 then
        if otherObject.speed.y < 0 then
            if otherObject.ceil then
                if otherObject:ceil(name, object) ~= false then
                    otherObject.speed.y = 0
                end
            else
                otherObject.speed.y = 0
            end
        end

        if object.floor then
            if object:floor(otherName, otherObject) ~= false then
                object.y = otherObject.y - object.height
                object.speed.y = 0
                return true
            end
        else
            object.y = otherObject.y - object.height
            object.speed.y = 0
            return true
        end
    else
        if otherObject.speed.y > 0 then
            if otherObject.floor then
                if otherObject:floor(name, object) ~= false then
                    otherObject.speed.y = 0
                end
            else
                otherObject.speed.y = 0
            end
        end

        if object.ceil then
            if object:ceil(otherName, otherObject) ~= false then
                object.y = otherObject.y + otherObject.height
                object.speed.y = 0
                return true
            end
        else
            object.y = otherObject.y + otherObject.height
            object.speed.y = 0
            return true
        end
    end
    return false
end

function physics:draw()
    for index, layer in pairs(self.layers) do
        for layerIndex, object in pairs(layer) do
            object:draw()
        end
    end
end

function physics:aabb(x, y, width, height, otherX, otherY, otherWidth, otherHeight)
    return x + width > otherX and x < otherX + otherWidth and y + height > otherY and y < otherY + otherHeight
end

function physics:containsPoint(x, y, otherX, otherY, width, height)
    return x >= otherX and x <= otherX + width and y >= otherY and y <= otherY + height
end

return physics