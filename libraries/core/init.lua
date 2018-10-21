local _PACKAGE = (...)

--load external libraries for cöre functionality
class  = require(_PACKAGE .. ".libraries.middleclass")
util   = require(_PACKAGE .. ".libraries.util")
vector = require(_PACKAGE .. ".libraries.vector")

MAX_SAVES = 1
save    = require(_PACKAGE .. ".system.save")
window  = require(_PACKAGE .. ".video.window")

object  = require(_PACKAGE .. ".game.object")
entity  = require(_PACKAGE .. ".game.entity")
physics = require(_PACKAGE .. ".game.physics")

core = {}
function core.init(device)
    local PATH = _PACKAGE .. ".device." .. device
    local FIX_PATH = PATH:gsub("%.", "/")

    --check if folder exists
    if love.filesystem.getInfo(FIX_PATH) then
        require(PATH)
    end
end