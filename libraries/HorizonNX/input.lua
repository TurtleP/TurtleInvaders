-- Clamps a number to within a certain range.
local function clamp(low, n, high)
	return math.min(math.max(low, n), high)
end

local function split(str, delimiter) --Not by me
    local result = {}
    local from   = 1
    local delim_from, delim_to = string.find( str, delimiter, from   )
    while delim_from do
        table.insert( result, string.sub( str, from , delim_from-1 ) )
        from = delim_to + 1
        delim_from, delim_to = string.find( str, delimiter, from   )
    end
    table.insert( result, string.sub( str, from   ) )
    return result
end

--JOYSTICK EVENTS
local JOYSTICK = 
{
	getID = function()
		return 1
	end
}

local function updateAxis(which, direction)
	for k, v in pairs(which) do
		local axis, value = nil, 0
		if k == "x" then
			axis = direction .. "x"
		else
			axis = direction .. "y"
		end

		if love.keyboard.isDown(v[1]) then
			value = -1
		elseif love.keyboard.isDown(v[2]) then
			value = 1
		end

		love.gamepadaxis(JOYSTICK, axis, value)
	end
end

local oldKeypressed = love.keypressed
function love.keypressed(key)
	for k, v in pairs(CONFIG.KEYS) do
		if key == v then
			love.gamepadpressed(JOYSTICK, k)
		end
	end
end

local oldKeyreleased = love.keyreleased
function love.keyreleased(key)
	for k, v in pairs(CONFIG.KEYS) do
		if key == v then
			if love.gamepadreleased then
				love.gamepadreleased(JOYSTICK, k)
			end
		end
	end
end

local oldUpdate = love.update
function love.update(dt)
	updateAxis(CONFIG.KEYS.leftAxis, "left")
	updateAxis(CONFIG.KEYS.rightAxis, "right")

	oldUpdate(dt)
end