local CURRENT_DEVICE = nil

local function initialize(device)
    CURRENT_DEVICE = tostring(device):lower()
end

local oldGetOS = love.system.getOS
function love.system.getOS()
    print(CURRENT_DEVICE)
end

return init