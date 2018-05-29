require 'data.powerups.powerup'

local powerupItems = love.filesystem.getDirectoryItems("data/powerups")

local powerups = {}
for i = 1, #powerupItems do
    local name = powerupItems[i]:gsub(".lua", "")
    
    if not name:find("init") and not name:find("powerup") then
        table.insert(powerups, require("data.powerups." .. name))
    end
end

return powerups