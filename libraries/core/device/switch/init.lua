local OS = {love.system.getOS()}

if OS[2] ~= nil then
    return
end

local _PACKAGE = (...)

window:setSize(1280, 720)
window:setScalei(2, 2)

require(_PACKAGE .. ".hid.input")