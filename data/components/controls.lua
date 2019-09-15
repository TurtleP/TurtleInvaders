local Controls = Component(function(entity)

end)

function Controls:SetSpeed(entity, speed, new)
    if speed and speed:GetX() ~= new then
        speed:SetX(new)
    end
end

function Controls:Shoot(entity)
    local position = entity:get(Components.Position)
    local size = entity:get(Components.Size)

    state:call("spawnEntity", "bullet", {position.x + size.width / 2, position.y - 8})
end

return Controls
