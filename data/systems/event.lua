local Event = System({Components.Controls})

function Event:gamepadpressed(pad, button)
    for _, entity in ipairs(self.pool) do
        local controls = entity:get(Components.Controls)
        local velocity = entity:get(Components.Velocity)

        if entity:has(Components.Static) then
            return
        end

        if button == "a" then
            controls:Shoot(entity)
        end
    end
end

function Event:gamepadaxis(pad, axis, value)
    for _, entity in ipairs(self.pool) do
        if entity:has(Components.Static) then
            return
        end

        local controls = entity:get(Components.Controls)
        local velocity = entity:get(Components.Velocity)

        if axis == "leftx" then
            if value < -0.5 then
                controls:SetSpeed(entity, velocity, -(120 * _env.SCALE))
            elseif value > 0.5 then
                controls:SetSpeed(entity, velocity, (120 * _env.SCALE))
            else
                controls:SetSpeed(entity, velocity, 0)
            end
        end
    end
end

return Event
