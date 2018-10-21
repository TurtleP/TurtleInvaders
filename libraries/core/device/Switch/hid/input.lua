local _PACKAGE = (...)

local _PACKAGE_ROOT = (...)
local _, ends = _PACKAGE_ROOT:find("core")
_PACKAGE_ROOT = _PACKAGE_ROOT:sub(1, ends)

local json = require(_PACKAGE_ROOT .. ".libraries.json")
local hook = require(_PACKAGE_ROOT .. ".libraries.hook")

local _CONFIG_PATH = _PACKAGE:gsub("%.", "/")
local _, ends = _PACKAGE:find("Switch")
_CONFIG_PATH = _CONFIG_PATH:sub(1, ends)

local _BUTTONS_CONFIG = love.filesystem.read(_CONFIG_PATH .. "/config.json")

local input = {}
input.buttons = json:decode(_BUTTONS_CONFIG)

local JOY = {}
JOY.getID = function(self)
    return 1
end

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

function input.keypressed(key)
    for check, value in pairs(input.buttons) do
        if key == check then
            if not value:find(":") then
                oldGamepadPressed(JOY, value)
            else
                local axis = value:split(":")
                oldGamepadAxis(JOY, axis[3], tonumber(axis[2]))
            end
        end
    end
end

function input.keyreleased(key)
    for check, value in pairs(input.buttons) do
        if key == check then
            if not value:find("axis") then
                oldGamepadReleased(JOY, value)
            else
                local axis = value:split(":")
                oldGamepadAxis(JOY, axis[3], 0)
            end
        end
    end
end

love.keypressed = hook.add(oldKeyPressed, input.keypressed)
love.keyreleased = hook.add(oldKeyReleased, input.keyreleased)