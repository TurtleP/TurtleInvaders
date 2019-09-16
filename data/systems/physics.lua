local Physics = System({Components.Position, Components.Size})
local bump = require 'libraries.bump'

function Physics:init()
    WORLD = bump.newWorld(16)
end

function Physics:entityAdded(entity)
    local position = entity:get(Components.Position)
    local size     = entity:get(Components.Size)

    WORLD:add(entity, position.x, position.y, size.width, size.height)
end

function Physics:entityRemoved(entity)
    WORLD:remove(entity)
end

function Physics:update(dt)
    for _, entity in ipairs(self.pool) do
        local position = entity:get(Components.Position)
        local mask = nil
        if entity:has(Components.Mask) then
            mask = entity:get(Components.Mask)
        end

        if entity:has(Components.Velocity) and not entity:has(Components.Static) then
            local velocity  = entity:get(Components.Velocity)

            if velocity.gravity ~= 0 then
                velocity.speed.y = math.min(velocity.speed.y + velocity.gravity * dt, velocity.gravity)
            end

            local ax, ay = position.x, position.y

            if entity:has(Components.Collision) then
                ax, ay, collisions, len = WORLD:move(entity, position.x + velocity.speed.x * dt, position.y + velocity.speed.y * dt, mask.filter)

                if #collisions > 0 then
                    for i = 1, #collisions do
                        if collisions[i].normal.y ~= 0 then
                            self:ResolveVertical(entity, collisions[i])
                        end
                    end
                end

                position:Set(ax, ay)

                if (ay < 0 and entity.removeOnUpperScreen) or ay > _env.WINDOW_H then
                    state:call("removeEntity", entity)
                end
            end
        end
    end
end

function Physics:ResolveVertical(entity, against)
    local velocity  = entity:get(Components.Velocity)
    local collision = entity:get(Components.Collision)

    if velocity.speed.y > 0 then
        if collision.floor then
            if not collision:floor(entity, against.other.name, against.other, against.type) then
                velocity.speed.y = 0
            end
        else
            velocity.speed.y = 0
        end
    end
end

return Physics
