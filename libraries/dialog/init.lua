local _PACKAGE = (...)
local _PATH = _PACKAGE:gsub("%.", "/")

require(_PACKAGE .. '.button')
require(_PACKAGE .. '.dialog')

messages = {}
local items = love.filesystem.getDirectoryItems(_PATH .. '/messages')
for i = 1, #items do
    local data = love.filesystem.read(_PATH .. '/messages/' .. items[i])
    messages[items[i]:gsub(".json", "")] = json:decode(data)
end

callbacks = {}
local items = love.filesystem.getDirectoryItems(_PATH .. '/callbacks')
for i = 1, #items do
    local name = items[i]:gsub(".lua", "")
    callbacks[name] = require(_PATH .. '.callbacks.' .. name)
end