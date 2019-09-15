local OS = {love.system.getOS()}

if OS[2] ~= nil then
    return
end

local _PACKAGE = (...)

require(_PACKAGE .. ".video.graphics")
require(_PACKAGE .. ".hid.input")