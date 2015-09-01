function randompowerupchance(chance)
	local name = ""
	
	if chance < 6 and chance > 2 then
		name = powerups[love.math.random(2, 10)]  
	elseif chance == 1 then
		name = powerups[11]
	end

	if name then
		return name
	end
end

function round(num, idp) --Not by me
	local mult = 10^(idp or 0)
	return math.floor(num * mult + 0.5) / mult
end

function comma_value(amount)
	local formatted = amount
	while true do   
		formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
		if (k==0) then
			break
		end
	end
	return formatted
end

function makeImageGray(image)
	local imgData = image

	imgData:mapPixel(function(x, y, r, g, b, a)
		local gray = (r + g + b) / 3
		return gray, gray, gray, a
	end)

	return imgData
end

function love.graphics.roundrectangle(mode, x, y, w, h, rd, s)
	local l = love.graphics.getLineWidth() or 1
	if mode == "fill" then l = 0 end --the line width doesn't matter if we're not using it :P
	
	local w, h = w+l, h+l
	local r, g, b, a = love.graphics.getColor()
	local rd = rd or math.max(w, h)/4
	local s = s or 32

	local corner = 1
	local function mystencil()
		if corner == 1 then
			return x-l, y-l, rd+l, rd+l
		elseif corner == 2 then
			return x+w-rd+l, y-l, rd+l, rd+l
		elseif corner == 3 then
			return x-l, y+h-rd+l, rd+l, rd+l
		elseif corner == 4 then
			return x+w-rd+l, y+h-rd+l, rd+l, rd+l
		elseif corner == 5 then
			return x+rd, y-l, w-2*rd+l, h+2*l
		elseif corner == 6 then
			return x, y+rd, rd+l, h-2*rd+l
		elseif corner == 7 then
			return x+w-rd+l, y+rd, rd+l, h-2*rd+l
		end
	end

	love.graphics.setScissor(mystencil())
	love.graphics.setColor(r, g, b, a)
	love.graphics.circle(mode, x+rd, y+rd, rd, s)
	love.graphics.setScissor()
	corner = 2
	love.graphics.setScissor(mystencil())
	love.graphics.setColor(r, g, b, a)
	love.graphics.circle(mode, x+w-rd, y+rd, rd, s)
	love.graphics.setScissor()
	corner = 3
	love.graphics.setScissor(mystencil())
	love.graphics.setColor(r, g, b, a)
	love.graphics.circle(mode, x+rd, y+h-rd, rd, s)
	love.graphics.setScissor()
	corner = 4
	love.graphics.setScissor(mystencil())
	love.graphics.setColor(r, g, b, a)
	love.graphics.circle(mode, x+w-rd, y+h-rd, rd, s)
	love.graphics.setScissor()
	corner = 5
	love.graphics.setScissor(mystencil())
	love.graphics.setColor(r, g, b, a)
	love.graphics.rectangle(mode, x, y, w, h)
	love.graphics.setScissor()
	corner = 6
	love.graphics.setScissor(mystencil())
	love.graphics.setColor(r, g, b, a)
	love.graphics.rectangle(mode, x, y, w, h)
	love.graphics.setScissor()
	corner = 7
	love.graphics.setScissor(mystencil())
	love.graphics.setColor(r, g, b, a)
	love.graphics.rectangle(mode, x, y, w, h)
	love.graphics.setScissor()
end

_translate = love.graphics.translate
_translateX, _translateY = {0}, {0}
_translateCounter = {0}
_pop = love.graphics.pop
_push = love.graphics.push
_origin = love.graphics.origin
_scissor = love.graphics.setScissor

function love.graphics.pop()
	for i = 1, _translateCounter[#_translateCounter] do
		table.remove(_translateX)
		table.remove(_translateY)
	end
	table.remove(_translateCounter)
	_pop()
end

function love.graphics.push()
	table.insert(_translateCounter, 0)
	_push()
end

function love.graphics.translate(x, y)
	table.insert(_translateX, x)
	table.insert(_translateY, y)
	_translateCounter[#_translateCounter] = _translateCounter[#_translateCounter] + 1
	_translate(x, y)
end

function love.graphics.getTranslation()
	return love.graphics.getTranslationX(), love.graphics.getTranslationY()
end

function love.graphics.getTranslationX()
	local x = 0
	for i, v in ipairs(_translateX) do
		x = x + v
	end
	return x
end

function love.graphics.getTranslationY()
	local y = 0
	for i, v in ipairs(_translateY) do
		y = y + v
	end
	return y
end

function love.graphics.origin()
	for i = 1, _translateCounter[#_translateCounter] do
		_translateX[#_translateX - (i-1)] = 0
		_translateY[#_translateY - (i-1)] = 0
	end
	_origin()
end

function love.graphics.setScissor(x, y, w, h)
	if x and type(x) == "number" then
		x = x + love.graphics.getTranslationX()
	end
	if y and type(y) == "number" then
		y = y + love.graphics.getTranslationY()
	end
	_scissor(x, y, w, h)
end

function newNotice(t, isWarn)
	table.insert(notices, notice:new(t, isWarn))
end

function getPowerColor(p)
	if p == "none" or p == "shotgun" then
		return {255, 244, 96}
	elseif p == "laser" then
		return {255, 0, 0}
	elseif p == "freeze" then
		return {0, 148, 255}
	elseif p == "time" then
		return {121, 121, 121}
	elseif p == "revive" then
		return {0, 255, 0}
	end
end

function changescale(s, first)

	if s then
		if s > getFullScale() and fullscreenbool then
			scale = s - 1
			return
		end
	end

	if mobileMode then
		fullscreenbool = true
		scale = getFullScale()
	else
		scale = math.max(s, 1)

		if not first then
			if gameH * scale > desktopH or gameW * scale > desktopW then 
				fullscreenbool = true
				scale = getFullScale()
			else 
				fullscreenbool = false
			end
		end
	end

	--[[if fullscreenbool then
		background = { img = love.graphics.newImage("gfx/UI/background.png") }

		background["width"] = background["img"]:getWidth() / 16
		background["height"] = background["img"]:getHeight() / 16
	end]]

	missingX, missingY = 0, 0
	if fullscreenbool then
		missingY = (desktopH - (300 * scale)) / 2
		missingX = (desktopW - (600 * scale)) / 2
	end

	love.window.setMode(600 * scale, 300 * scale, {fullscreen=fullscreenbool, fullscreentype="desktop", vsync=vsyncbool})

	loadFonts()

	--it's legit
	for i = 1, 5 do
		starfield[i] = {}
		starfield[i].position = 0
		starfield[i].chunks = {makeStarChunk(i, true), makeStarChunk(i)}
	end

	if state then
		if state == "settings" then
			_G[state .. "_load"](settingstabi, settings_selectioni)
		else
			_G[state .. "_load"]()
		end
	end	
end

starfield = {}
function makeStarChunk(i, minusY)
	local field = {}
	local toy = 0
	if minusY then toy = -gameH end
	for star = 1, 100/i do
		table.insert(field, {x = love.math.random(0, gameW), y = love.math.random(toy, gameH)})
	end
	return field
end

function getFullScale()
	return math.floor( math.min(desktopW/600, desktopH/300) ) --round to thousands
end

function playsound(sound)
	if audio[sound]:isStatic() then
		if soundvolume == 0 then
			return
		end
	else
		if musicvolume == 0 or customMusicBool then
			return
		end
	end

	if audio[sound] then
		audio[sound]:stop()
		audio[sound]:play()
	end
end

function stopMusic()
	for k, v in pairs(audio) do
		if not v:isStatic() and v:isPlaying() then
			love.audio.stop(v)
		end
	end
end

function changeVolume(sound, music)
	if sound then
		sound = round( math.clamp(sound, 0, 1) , 2 )
	elseif music then
		music = round( math.clamp(music, 0, 1) , 2 )
	end

	for k, v in pairs(audio) do
		if v:isStatic() then
			if sound then
				v:setVolume(sound)
			end
		else
			if music then
				v:setVolume(music)
			end
		end
	end
end

--Not mine, see https://love2d.org/forums/viewtopic.php?p=18936#p18936
function math.clamp(val, lower, upper)
    assert(val and lower and upper, "Invalid input: expected base value, lower limit, and upper limit. Got: " .. val .. ", " .. lower .. ", " .. upper)
    if lower > upper then lower, upper = upper, lower end -- swap if boundaries supplied the wrong way
    return math.max(lower, math.min(upper, val))
end

function table.merge(t1, t2)
	local ret = {}
	for i, v in pairs(t1) do
		table.insert(ret, v)
	end
	for i, v in pairs(t2) do
		table.insert(ret, v)
	end
	return ret
end

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

function makeGradient(x, y, width, height, color1, color2)
	local def = definition or 32
	local size = math.max(width, height)
	local img = love.image.newImageData(width, height)
	img:mapPixel(function(x, y, r, g, b, a)
		local color = colorfade(dist(x, y, width/2, height/2), dist(0, 0, width/2, height/2), color1, color2)
		return unpack(color)
	end)
	return love.graphics.newImage(img)
end

function love.graphics.roundScissor(x, y, w, h, r, s)
	local r = r or false
	if w and h and not r then
		r = math.min(w, h)/4
	end
	local s = s or 32
	local cr, cg, cb, ca = love.graphics.getColor()

	local function myStencil()
		if x and y and w and h then
			love.graphics.setColor(255, 255, 255, 255)
			love.graphics.circle("fill", x+r, y+r, r, s)
			love.graphics.circle("fill", x+w-r, y+r, r, s)
			love.graphics.circle("fill", x+r, y+h-r, r, s)
			love.graphics.circle("fill", x+w-r, y+h-r, r, s)
			love.graphics.rectangle("fill", x+r, y, w-2*r, h)
			love.graphics.rectangle("fill", x, y+r, w, h-2*r)
		end
	end

	if x and y and w and h then
		love.graphics.setStencil(myStencil)
	else
		love.graphics.setStencil()
	end
	love.graphics.setColor(cr, cg, cb, ca)
end

function colorfade(currenttime, maxtime, c1, c2) --Color function
	local tp = currenttime/maxtime
	local ret = {} --return color

	for i = 1, #c1 do
		ret[i] = c1[i]+(c2[i]-c1[i])*tp
		ret[i] = math.max(ret[i], 0)
		ret[i] = math.min(ret[i], 255)
	end

	return ret
end