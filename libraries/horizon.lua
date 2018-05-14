--SUPER LOW LEVEL HACKS
local BINDS =
{
	["buttons"] =
	{
		["a"] = "dpleft",
		["d"] = "dpright",
		["w"] = "dpup",
		["s"] = "dpdown",
		["z"] = "a",
		["x"] = "b"
	},
	
	["axes"] =
	{
		["leftx"] = "left|right"
	}
}

local JOYSTICK = {
	getID = function(self)
		return 1
	end
}

local gamepadpressed = love.gamepadpressed
local gamepadaxis = love.gamepadaxis

function love.keypressed(key)
	if key == "escape" then
		love.event.quit()
	end

	if BINDS["buttons"][key] then
		gamepadpressed(JOYSTICK, BINDS["buttons"][key])
	end

	local split = BINDS["axes"]["leftx"]:split("|")
	local value = nil

	if key == split[1] then
		value = -1
	elseif key == split[2] then
		value = 1
	end
	
	if value ~= nil then
		gamepadaxis(JOYSTICK, "leftx", value)
	end
end

function love.keyreleased(key)
	local split = BINDS["axes"]["leftx"]:split("|")
	local value = 0

	if key == split[1] or key == split[2] then
		gamepadaxis(JOYSTICK, "leftx", value)
	end
end