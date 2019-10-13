local _PACKAGE = (...)

local _LIBS_PATH = _PACKAGE:sub(1, (...):find("%."))

local hook = require(_LIBS_PATH .. "libraries.hook")

local _CONFIG_PATH = _PACKAGE:gsub("%.", "/")
_CONFIG_PATH = _CONFIG_PATH:sub(1, _PACKAGE:find("DS") + 1)

local _BUTTONS_CONFIG = love.filesystem.read(_CONFIG_PATH .. "/config.json")

local input = {}

function input.activate()
    input.buttons = json:decode(_BUTTONS_CONFIG)

    --Hooks
    local oldGamepadPressed = nil
    if not love.gamepadpressed then
        function love.gamepadpressed(joystick, button) 
        
        end
    end
    oldGamepadPressed = love.gamepadpressed

    local oldGamepadReleased = nil
    if not love.gamepadreleased then
        function love.gamepadreleased(joystick, button) 
        
        end
    end
    oldGamepadReleased = love.gamepadreleased

    local oldGamepadAxis = nil
    if not love.gamepadaxis then
        function love.gamepadaxis(joystick, axis, value)

        end
    end
    oldGamepadAxis = love.gamepadaxis

    local oldKeyPressed = nil
    if not love.keypressed then
        function love.keypressed(key) 
        
        end
    end
    oldKeyPressed = love.keypressed

    local oldKeyReleased = nil
    if not love.keyreleased then
        function love.keyreleased(key) 
        
        end
    end
    oldKeyReleased = love.keypressed

    local dir = {up = -1, down = 1, left = -1, right = 1}
    function input.keypressed(key)
        for check, value in pairs(input.buttons) do
            if key == check then
                if not value:find(":") then
                    oldGamepadPressed(nil, value)
                else
                    local axis = value:split(":")
                    oldGamepadAxis(nil, tonumber(axis[2]), dir[axis[3]])
                end
            end
        end
    end

    function input.keyreleased(key)
        for check, value in pairs(input.buttons) do
            if key == check then
                if not value:find("axis") then
                    oldGamepadReleased(nil, value)
                else
                    local axis = value:split(":")
                    oldGamepadAxis(nil, tonumber(axis[2]), 0)
                end
            end
        end
    end

    love.keypressed = hook.add(oldKeyPressed, input.keypressed)
    love.keyreleased = hook.add(oldKeyReleased, input.keyreleased)
end
