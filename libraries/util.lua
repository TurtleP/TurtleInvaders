local util = {}

--[[
	util.lua

	Useful Tool in Love

	TurtleP

	v2.0
--]]

local scale = {1, 1}

function util.changeScale(scalar)
	scale = scalar

	love.window.setMode(love.graphics.getWidth() * scalar, love.graphics.getHeight() * scalar)
end

function util.clearFonts()
	if mainFont then
		mainFont = nil
	end

	if logoFont then
		logoFont = nil
	end

	if hudFont and waveFont then
		hudFont = nil
		waveFont = nil
	end

	if warningFont then
		warningFont = nil
	end

	if chooseFont and abilityFont then
		chooseFont = nil
		abilityFont = nil
	end

	collectgarbage()
	
	fontCount = 0
end

function util.toBoolean(stringCompare)
	return tostring(stringCompare) == "true"
end

function util.setScalar(xScale, yScale)
	scale = {xScale, yScale}
end

function util.changeState(toState, ...)
	local arg = {...} or {}

	if _G[toState .. "Init"] then
		_G[toState .. "Init"](unpack(arg))
	end

	state = toState
end

function util.updateState(dt)
	if _G[state .. "Update"] then
		_G[state .. "Update"](dt)
	end
end

function util.renderState()
	if _G[state .. "Draw"] then
		_G[state .. "Draw"]()
	end
end

function util.keyPressedState(key)
	if _G[state .. "KeyPressed"] then
		_G[state .. "KeyPressed"](key)
	end
end

function util.keyReleasedState(key)
	if _G[state .. "KeyReleased"] then
		_G[state .. "KeyReleased"](key)
	end
end

function util.dist(x1,y1, x2,y2) 
	return ((x2-x1)^2+(y2-y1)^2)^0.5 
end

function util.clamp(val, min, max)
	return math.max(min, math.min(val, max))
end

function util.colorFade(currenttime, maxtime, c1, c2) --Color function
	local tp = currenttime/maxtime
	local ret = {} --return color

	for i = 1, #c1 do
		ret[i] = c1[i]+(c2[i]-c1[i])*tp
		ret[i] = math.max(ret[i], 0)
		ret[i] = math.min(ret[i], 255)
	end

	return ret
end

function util.getWidth()
	return love.graphics.getWidth()
end

function util.getHeight()
	if _EMULATEHOMEBREW then
		return 240
	end
	return love.graphics.getHeight()
end

Color =
{
	["red"] = {225, 73, 56},
	["green"] = {65, 168, 95},
	["blue"] = {44, 130, 201},
	["yellow"] = {250, 197, 28},
	["orange"] = {243, 121, 52},
	["purple"] = {147, 101, 184},
	["darkPurple"] = {85, 57, 130},
	["black"] = {0, 0, 0},
	["white"] = {255, 255, 255}
}

return util
