require 'data.powerups.powerup'

local powerupItems = love.filesystem.getDirectoryItems("data/powerups")
local exception =
{
    "init",
    "powerup",
    "frostbullet"
}

local function isException(name)
    local pass = true
    for index = 1, #exception do
        if name:find(exception[index]) then
            pass = false
        end
    end
    return not pass
end

local powerups = {}
for i = 1, #powerupItems do
    local name = powerupItems[i]:gsub(".lua", "")
    
    if not isException(name) then
        table.insert(powerups, require("data.powerups." .. name))
    end
end

return powerups