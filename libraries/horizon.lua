--SUPER LOW LEVEL HACKS
local BINDS =
{
	["buttons"] =
	{
		["left"] = "dpleft",
		["right"] = "dpright",
		["up"] = "dpup",
		["down"] = "dpdown",
		["z"] = "a",
		["x"] = "b"
	},
	
	["axes"] =
	{
		["leftx"] = "a|d"
	}
}

function string:split(delimiter) --Not by me
	local result = {}
	local from   = 1
	local delim_from, delim_to = string.find( self, delimiter, from   )
	while delim_from do
		table.insert( result, string.sub( self, from , delim_from-1 ) )
		from = delim_to + 1
		delim_from, delim_to = string.find( self, delimiter, from   )
	end
	table.insert( result, string.sub( self, from   ) )
	return result
end

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
	local value = 0

	if key == split[1] then
		value = -1
	elseif key == split[2] then
		value = 1
	end
	gamepadaxis(JOYSTICK, "leftx", value)
end

function love.keyreleased(key)
	local split = BINDS["axes"]["leftx"]:split("|")
	local value = 0

	if key == split[1] or key == split[2] then
		gamepadaxis(JOYSTICK, "leftx", value)
	end
end