--[[ 
	This game was written by Bart Sowka and Jeremy Postelnek, we honestly don't care what you do with this as long
	as credit is given. DON'T STEAL THIS OR ELSE I'LL FIND YOU. "ESPECIALLY ME" - Turtle
	(see http://creativecommons.org/licenses/by-nc-sa/4.0/ for details)
--]]

--[[Epically require all dem files]]--

--[[function love.filesystem.exists(dir)
	assert(type(dir) == "string", "String expected: got " .. type(dir))
	return love.filesystem.isFile(dir) or love.filesystem.isDirectory(dir)
end]]

function love.load()

	loadingDebug = false

	controls = {}

	gameW = 600
	gameH = 300

	gamepad_default = {"leftx:neg", "leftx:pos", "gamepad:a", "gamepad:b"}

	controls[1] = {"a", "d", " " , "lshift"}
	controls[2] = {"left", "right", "up" , "rctrl"}

	for k = 3, 4 do
		controls[k] = {unpack(gamepad_default)}
	end

	default_controls = {unpack(controls)}

	startTime = love.timer.getTime()

	love.graphics.setDefaultFilter("nearest", "nearest") -- NO BLURRY STUFF
	
	error_img = love.graphics.newImage("gfx/error.png")

	maxload = 14

	highscore = 0
	highscorestable = {}

	for i = 1, 10 do
		table.insert(highscorestable, {"??????", "unknown", 0} )
	end

	JSON = require("lib.Json")
	require 'lib.gamefunctions'

	loadSounds()

	desktopW, desktopH = love.window.getDesktopDimensions()

	require 'lib.32log'

	requireFiles("", {"cron.lua", "Json.lua", "android", "32log.lua", "gamefunctions.lua", "gfx", "sound", "fonts", "characters", "script"})

	missingX, missingY = 0, 0
	if love.system.getOS() == "Android" or love.system.getOS() == "iOS" then
		require "android/touchcontrol"
		
		mobileMode = true

		touchcontrols = touchcontrol:new()
	end

	if love.filesystem.exists("saveData.txt") then
		loadData("settings")

		if love.joystick.getJoysticks() == 0 then
			controls[1] = {}
		end
	else
		scale = 1  
		fullscreenbool = false
		vsyncbool = true 
		strfullscreentype = "normal"
		musicvolume = 1
		soundvolume = 1
		customMusicBool = false
		loadFonts()
		highscore = 0
		
		saveData("settings", true, true)
	end
	
	if mobileMode then
		changescale()
	end

	cron = require("lib/cron")

	loading(0)
	
	loading(1)

	loading(2)
	
	loading(3)
	
	loading(4)

	version = "Version 1.5"
	versionstring = "1.5"

	graphics = "gfx/"
	sounds = "sound/"
	musics = "sound/music/"

	loading(5)

	loadAchievementsData()
	
	if not love.filesystem.exists("characters/") then
		love.filesystem.createDirectory("characters/")
	end

	characterloader:loadChars()

	loading(6)
	
	--FONTS--
	loadFonts()
	
	loading(7)

	iconimg = love.image.newImageData(graphics .. "icon.png")
	
	love.window.setIcon(iconimg)
	
	bosshpbarimg = love.graphics.newImage(graphics .. "UI/bosshpbar.png")
	bosshpquads = {}
	for i = 1, 2 do
		bosshpquads[i] = love.graphics.newQuad(0, (i-1)*16, 216, 16, bosshpbarimg:getWidth(), bosshpbarimg:getHeight())
	end

	shoopcharge = love.graphics.newImage(graphics .. "effects/boom.png")
	shoopchargequads = {}
	for x = 1, 6 do
		shoopchargequads[x] = {}
		for y = 1, 3 do
			shoopchargequads[x][y] = love.graphics.newQuad((x-1)*80, (y-1)*80, 80, 80, shoopcharge:getWidth(), shoopcharge:getHeight())
		end
	end

	shoopbase = love.graphics.newImage(graphics .. "effects/boombase.png")
	shoopbasequads = {}
	for x = 1, 6 do
		shoopbasequads[x] = {}
		for y = 1, 2 do
			shoopbasequads[x][y] = love.graphics.newQuad((x-1)*80, (y-1)*80, 80, 80, shoopbase:getWidth(), shoopbase:getHeight())
		end
	end
	
	shoopbeam = love.graphics.newImage(graphics .. "effects/beam.png")
	shoopbeamquads = {}
	for i = 1, 6 do
		shoopbeamquads[i] = love.graphics.newQuad((i-1)*22, 0, 22, 22, shoopbeam:getWidth(), shoopbeam:getHeight())
	end

	phoeniximg = love.graphics.newImage(graphics .. "game/phoenix.png")
	phoenixquads = {}

	for i = 1, 4 do
		phoenixquads[i] = {}
		for y = 1, 2 do
			phoenixquads[i][y] = love.graphics.newQuad((i-1)*64, (y-1)*50, 64, 50, phoeniximg:getWidth(), phoeniximg:getHeight())
		end
	end

	explosionimg = love.graphics.newImage(graphics .. "effects/explosion.png")
	explosionquads = {}
	for i = 1, 6 do
		explosionquads[i] = love.graphics.newQuad((i-1)*18, 0, 16, 16, explosionimg:getWidth(), explosionimg:getHeight())
	end
	
	bossimg = love.graphics.newImage(graphics .. "game/boss.png")
	bossquads = {}
	for i = 1, 3 do
		bossquads[i] = love.graphics.newQuad((i-1)*60, 0, 59, 30, bossimg:getWidth(), bossimg:getHeight())
	end

	
	powerupsimg = love.graphics.newImage(graphics .. "game/powerups.png")
	powerupquads = {}
	for i = 1, 12 do
		powerupquads[i] = love.graphics.newQuad((i-1)*19, 0, 18, 18, powerupsimg:getWidth(), powerupsimg:getHeight())
	end

	bufferimg = love.graphics.newImage(graphics .. "netplay/buffer.png")
	bufferquads = {}
	for y = 1, 2 do
		for x = 1, 2 do
			table.insert(bufferquads, love.graphics.newQuad((x-1)*40, (y-1)*40, 40, 40, bufferimg:getWidth(), bufferimg:getHeight()))
		end
	end
	
	emptyquads = love.graphics.newQuad(0, 0, 0, 0, 0, 0)
	
	shiphealthgui = love.graphics.newImage(graphics .. "effects/hitpoint.png")

	uiarrow = love.graphics.newImage(graphics .. "UI/uiarrow.png")
	uiarrowquads = {}
	for k = 1, 2 do
		uiarrowquads[k] = love.graphics.newQuad((k-1)*10, 0, 10, 17, uiarrow:getWidth(), uiarrow:getHeight())
	end

	loading(8)
	
	powerups = {"none", "shotgun",  "time", "shield", "laser", "freeze", "antiscore", "nobullets", "remove", "shoop"}

	difficultyi = 2
	difficultytypes = {"easy", "medium", "hard"}

	gamemode = "Normal"
	difficulty = difficultytypes[difficultyi]

	paused = false
	
	loading(9)
	
	loading(10)

	loadGraphics("gfx")
	loadQuads()

	loading(11)
	
	loading(12)
	
	loadFonts()
	
	newVersion, Value, updateURL = checkversion()
	
	loading(13)

	loading(14)
end


function requireFiles(path, exclusionList)
	local f = love.filesystem.getDirectoryItems(path)

	local count = 0

	for t = 1, #exclusionList do
		for k, v in pairs(f) do
			if v == exclusionList[t] or v == "main.lua" then
				--print(">>> Exluding from loading: " .. v)
				table.remove(f, k)
			end
		end
	end

	for k = 1, #f do
		if love.filesystem.isDirectory(f[k]) then
			requireFiles(f[k] .. "/", exclusionList)
		else

			if f[k]:sub(-4) == ".lua" then
				local dir = "root/"

				if path ~= dir and path ~= "" then
					dir = path
				end

				debugLoadTime(dir .. f[k])
				require(path .. f[k]:gsub(".lua", ""))
			end

		end
	end
end

function debugLoadTime(description)
	if mobileMode or not loadingDebug then
		return
	end

	print(">>> Loaded " .. description .. " in " .. round((love.timer.getTime()-startTime)*1000) .. "ms.")
	startTime = love.timer.getTime()
end

function table.contains(t, e)
	for i, v in pairs(t) do
		if type(e) == "string" then
			if v == e then
				return true
			end
		else
			for j, w in pairs(e) do
				if v == w then
					return true
				end
			end
		end
	end
	return false
end

function love.quit()
	if netplay or clientonline then
		client:disconnect()
	end
end

function loadData(value)
	if love.filesystem.exists("saveData.txt") then
		local f = love.filesystem.read("saveData.txt")
		local lua = JSON:decode(f)

		local found = {}

		for t, v in pairs(lua) do
			if t == value then
				if value == "settings" then
					for j, w in pairs(v) do
						if j == "scale" then
							scale = w

							changescale(scale, first)
						elseif j == "vsync" then
							if w == "true" then
								vsyncbool = true
							else
								vsyncbool = false
							end
						elseif j == "controls" then
							controls = w
							default_controls = w
						elseif j == "fullscreen" then
							fullscreenbool = w
						elseif j == "volume" then
							soundvolume = w[1]
							musicvolume = w[2]

							changeVolume(soundvolume, musicvolume)
						end

						if mobileMode then
							if j == "controlType" then
								if controltypes[w] then
									controli = w
								else
									controli = 1
								end
							end
						end
					end
				elseif value == "netplay" then
					for j, w in pairs(v) do
						if j == "char" then
							charconfigi = w
						elseif j == "playerconfig" then
							playerconfig = w
						elseif j == "nick" then
							nickstr = w
						elseif j == "favorites" then
							favorites = w
						end
					end
				elseif value == "achievements" then
					for k = 1, #v do
						local s = v[k]
						achievements[s[1]].loaded = true 
						achievements[s[1]].unlocked = true 
						achievements[s[1]].unlockDate = s[2]
					end

					if v["batskilled"] then
						batskilled = tonumber(v["batskilled"], 10)
					end
				elseif value == "highscores" then
					for j, w in pairs(v) do
						if j == "scores" then
							loadProper(w)
						end
					end

					table.sort(highscorestable, 
					function(a, b) 
						return a[3] > b[3] 
					end)

					highscore = highscorestable[1][3]
				end
			end
		end
	end

	debugLoadTime("save data - " .. value)
end

function saveData(index, supressNotice, first)
	local file
	local lua_table = {}
	if love.filesystem.exists("saveData.txt") then
		file = love.filesystem.read("saveData.txt")
	end

	if type(file) == "string" then
		lua_table = JSON:decode(file)
	end

	lua_table[index] = {}

	if index == "settings" then
		lua_table[index].scale = scale

		lua_table[index].volume = {soundvolume, musicvolume}

		if mobileMode then
			lua_table[index].controlType = controli
		end

		lua_table[index].controls = controls
			
		lua_table[index].vsync = vsyncbool
		lua_table[index].fullscreen = fullscreenbool
		lua_table[index].custommusic = customMusicBool

		if not supressNotice then
			newNotice("Settings saved successfully.")
		end
	elseif index == "highscores" then
		for i, v in ipairs(highscorestable) do
			highscorestable[i] = {highscorestable[i][1], highscorestable[i][2], highscorestable[i][3]}--highscorestable[i][1]
		end

		table.sort(highscorestable, 
		function(a, b) 
			return a[3] > b[3] 
		end)

		lua_table[index].scores = highscorestable

		newNotice("Highscores saved successfully.")
	elseif index == "netplay" then
		lua_table[index].nick = nickstr
		lua_table[index].char = charconfigi

		hasName = false
		for k =  #favorites, 1, -1 do
			if favorites[k][1] == favoritename then
				hasName = true
				break
			end
		end

		if not hasName then
			table.insert(favorites, {favoritename, ip, port})
		end

		lua_table[index].favorites = favorites
		lua_table[index].connectionData = connectionData
	elseif index == "achievements" then
		--[[if args[1] then
			lua_table[index].batskilled = tonumber(args[1], 16)
			return
		end]]

		for k, v in pairs(achievements) do
			if v.unlocked then
				table.insert(lua_table[index], {v.name, v.unlockDate})
			end
		end
	end

	local lua_json = JSON:encode_pretty(lua_table)

	love.filesystem.write("saveData.txt", lua_json)

end

function defaultSettings()
	if not mobileMode then
		scale = 1
	else
		controli = 1
	end

	changescale(scale)

	controls[1] = {"a", "d", " " , "lshift"}
	controls[2] = {"left", "right", "up" , "rctrl"}

	for k = 3, 4 do
		controls[k] = {unpack(gamepad_default)}
	end

	vsyncbool = true 
	musicvolume = 1
	soundvolume = 1

	changeVolume(soundvolume, musicvolume)

	love.filesystem.remove("saveData.txt")

	local logs = love.filesystem.getDirectoryItems("errors")

	local logcount = #logs

	for k = 1, #logs do
		love.filesystem.remove("errors/" .. logs[k])
	end

	newNotice("Settings set to default; " .. comma_value(logcount) .. " error logs were removed.")
end

function loading(p)
	local defaults = { {127, 127, 127}, {127, 127, 127}, {127, 127, 127} }
	local fadeTo = { {0, 255, 0}, {252, 255, 0}, {252, 255, 0} }

	love.graphics.clear()

	love.graphics.push()

	love.graphics.translate(missingX or 0, missingY or 0)
	
	love.graphics.setNewFont("fonts/Apple Chancery.ttf", 30 * scale)

	love.graphics.setColor(colorfade(p, 14, defaults[1], fadeTo[1]))

	love.graphics.print("Tiny", 90 * scale, 62 * scale)

	love.graphics.setNewFont("fonts/Apple Chancery.ttf", 70 * scale)

	love.graphics.setColor(colorfade(p, 8, defaults[2], fadeTo[2]))

	love.graphics.print("Turtle", 120 * scale, 72 * scale)

	love.graphics.setColor(colorfade(p, 13, defaults[3], fadeTo[3]))

	love.graphics.print("Industries", 210 * scale, 122 * scale)

	love.graphics.setColor(255, 255, 255)

	love.graphics.pop()

	love.graphics.present()

	if p == maxload then
		if newVersion then
			intro_load()
		else
			menu_load()
		end
	end
end

function loadFonts()
	font1 = {lrg = love.graphics.newFont("fonts/absender.ttf",48*scale), xl = love.graphics.newFont("fonts/absender.ttf",54*scale)}
	font2 = love.graphics.newFont("fonts/absender.ttf",24*scale)
	font3 = love.graphics.newFont("fonts/absender.ttf",18*scale)
	font4 = love.graphics.newFont("fonts/absender.ttf",21*scale)
	font5 = love.graphics.newFont("fonts/absender.ttf",20*scale)
	font6 = love.graphics.newFont("fonts/absender.ttf",14*scale)
	font7 = love.graphics.newFont("fonts/absender.ttf",16*scale)
	font8 = love.graphics.newFont("fonts/absender.ttf",12*scale)
	font9 = love.graphics.newFont("fonts/absender.ttf",17*scale)

	menubuttonfont = love.graphics.newFont("fonts/absender.ttf",30*scale)
	scoresfont = love.graphics.newFont("fonts/absender.ttf", 27*scale)
end

function loadGraphics(graphics_dir)
	graphics = {}

	local files = love.filesystem.getDirectoryItems(graphics_dir .. "/")

	for i = 1, #files do
		if love.filesystem.isDirectory(graphics_dir .. "/" .. files[i] .. "/") then
			local dir = graphics_dir .. "/" .. files[i] .. "/"
			local subdirfiles = love.filesystem.getDirectoryItems(dir)
			for k = 1, #subdirfiles do
				local indx = subdirfiles[k]:gsub(".png", "")
				if subdirfiles[k]:sub(-4) == ".png" then
					graphics[indx] = love.graphics.newImage(dir .. subdirfiles[k])
				end
			end
		else
			local indx = files[i]:gsub(".png", "")
			if files[i]:sub(-4) == ".png" then
				graphics[indx] = love.graphics.newImage(graphics_dir .. "/" .. files[i])
			end
		end
	end
end
	
mouse = {}

function mouse.X()
	return love.mouse.getX() - missingX
end

function mouse.Y()
	return love.mouse.getY() - missingY
end

function checkversion()
	if mobileMode then
		return
	end

	local http = require("socket.http")
	http.TIMEOUT = 3
	
	local a, b, c = http.request(updatelink)
	local newdata = {}

	if a then
		msgdata = string.gsub(a, "&nbsp;", " "):split("##GAME##")

		for i = 2, #msgdata-1 do
			table.insert(newdata, msgdata[i]:split(updatechar))
		end	

		for k = 1, #newdata do
			if newdata[k][1] == "Turtle-Invaders" then
				return tonumber(versionstring) < tonumber(newdata[k][2]), newdata[k][2], newdata[k][3]
			end
		end
	else 
		newNotice("Unable to check for update data!", true)
	end
end

function love.getQuads(image, width, height, mode)
   local width = width
   local height = height
   local mode = mode or "size"
   if mode == "amount" then
      width = math.floor(image:getWidth()/width)
      height = math.floor(image:getHeight()/height)
   end
   
   local horizontalquads = math.floor(image:getWidth()/width)
   local verticalquads = math.floor(image:getHeight()/height)
   
   local returner = {}
   
   for x = 1, horizontalquads do
      for y = 1, verticalquads do
         table.insert(returner, {image = image, quad = love.graphics.newQuad((x-1)*width, (y-1)*height, width, height)})
      end
   end
   return returner
end

function loadQuads()
	quads = {}

	batquads = {}
	for i = 1, 3 do
		batquads[i] = love.graphics.newQuad((i-1)*30, 0, 30, 16, graphics["bat"]:getWidth(), graphics["bat"]:getHeight())
	end
	
	fireballquads = {}
	for i = 1, 2 do
		fireballquads[i] = love.graphics.newQuad((i-1)*16, 0, 16, 16, graphics["fireballs"]:getWidth(), graphics["fireballs"]:getHeight())
	end

	phoenixdeathquads = {}
	for i = 1, 5 do
		phoenixdeathquads[i] = love.graphics.newQuad((i-1)*80, 0, 80, 80, graphics["phoenixdeath"]:getWidth(), graphics["phoenixdeath"]:getHeight())
	end

	for i = 1, 5 do
		table.insert(phoenixdeathquads, love.graphics.newQuad((i-1)*80, 80, 80, 80, graphics["phoenixdeath"]:getWidth(), graphics["phoenixdeath"]:getHeight()))
	end

	for i = 1, 2 do
		table.insert(phoenixdeathquads, love.graphics.newQuad((i-1)*80, 160, 80, 80, graphics["phoenixdeath"]:getWidth(), graphics["phoenixdeath"]:getHeight()))
	end

	batarmorquads = {}
	for x = 1, 3 do
		batarmorquads[x] = {}
		for y = 1, 3 do
			batarmorquads[x][y] = love.graphics.newQuad((x-1)*30, (y-1)*16, 30, 16, graphics["batarmor"]:getWidth(), graphics["batarmor"]:getHeight())
		end
	end

	coonquads = {}
	for i = 1, 2 do
		coonquads[i] = love.graphics.newQuad((i-1)*51, 0, 50, 52, graphics["risky"]:getWidth(), graphics["risky"]:getHeight())
	end

	for i = 1, math.floor(graphics["achievements"]:getWidth()/33) do
		achievementsquads[i] = love.graphics.newQuad((i-1)*33, 0, 32, 32, graphics["achievements"]:getWidth(), graphics["achievements"]:getHeight())
	end

	arrowquads = {}
	for i = 1, 2 do
		arrowquads[i] = love.graphics.newQuad((i-1)*16, 0, 16, 16, graphics["arrows"]:getWidth(), graphics["arrows"]:getHeight())
	end
end

function loadSounds()
	audio = {}
	
	local graphics_dir = "sound/" -- lazy
	
	local files = love.filesystem.getDirectoryItems("sound/")

	for i = 1, #files do
		if love.filesystem.isDirectory(graphics_dir .. "/" .. files[i] .. "/") then
			local dir = graphics_dir .. "/" .. files[i] .. "/"
			local subdirfiles = love.filesystem.getDirectoryItems(dir)
			for k = 1, #subdirfiles do
				local indx = subdirfiles[k]:gsub(".ogg", "")
				if subdirfiles[k]:sub(-4) == ".ogg" then
					audio[indx] = love.audio.newSource(dir .. subdirfiles[k], "stream")
				end
			end
		else
			local indx = files[i]:gsub(".ogg", "")
			if files[i]:sub(-4) == ".ogg" then
				audio[indx] = love.audio.newSource(graphics_dir .. "/" .. files[i], "static")
			end
		end
	end
	
	injurysounds = {"hurt", "hurt2", "hurt3"}

	audio["menu"]:setLooping(true)
end

function savelog(data)
	local pcdata = os.date("!*t")
	
	love.filesystem.createDirectory("errors")
	local m = love.filesystem.getDirectoryItems("errors")
	local s = 1
	if #m > 0 then
		s = #m + 1
	end
	local name = "error_" .. tostring(s) .. " - " .. tostring(pcdata["month"]) .. "-" .. tostring(pcdata["day"]) .. "-" .. tostring(pcdata["year"]) .. " - " .. tostring(pcdata["hour"]) .. "-" .. tostring(pcdata["min"]) .. "-" .. tostring(pcdata["sec"]) .. ".txt"
	local success = love.filesystem.write("errors/" .. name, p)

	return success
end

local function error_printer(msg, layer)
    print((debug.traceback("Error: " .. tostring(msg), 1+(layer or 1)):gsub("\n[^\n]+$", "")))
end

function inside(x1, y1, w1, h1, x2, y2, w2, h2)
	if x1 >= x2 and x1+w1 <= x2+w2 and y1 >= y2 and y1+h1 <= y2+h2 then
		return true
	end
	return false
end

function love.errhand(msg)
	if netplay or clientonline then
		client:disconnect()
	end
	
	if not scale then
		if not mobileMode then
			scale = 1
		else
			scale = math.floor( math.min(desktopW/600, desktopH/300) )
		end
	end
	local errortime = os.date()
    msg = tostring(msg)

    error_printer(msg, 2)

    if not love.window or not love.graphics or not love.event then
        return
    end

    if not love.graphics.isCreated() or not love.window.isCreated() then
        if not pcall(love.window.setMode, 800, 600) then
            return
        end
    end

    -- Reset state.
    if love.mouse then
        love.mouse.setVisible(true)
        love.mouse.setGrabbed(false)
    end
    if love.joystick then
        for i,v in ipairs(love.joystick.getJoysticks()) do
            v:setVibration() -- Stop all joystick vibrations.
        end
    end
    if love.audio then love.audio.stop() end
    love.graphics.reset()
    love.graphics.setBackgroundColor(0, 102, 127)
    love.graphics.setColor(255, 255, 255, 255)

    local trace = debug.traceback()

    love.graphics.clear()
    love.graphics.origin()

    local err = {}

    table.insert(err, "Error\n")
    table.insert(err, msg.."\n\n")
	
	local n = 0
    for l in string.gmatch(trace, "(.-)\n") do
		n = n+1
		if not string.match(l, "boot.lua") and n ~= 2 and n ~= 3 then
            l = string.gsub(l, "stack traceback:", "Traceback\n")
            table.insert(err, l)
        end
    end

    local p = table.concat(err, "\n")

   -- p = string.gsub(p, "\t", "")
    p = string.gsub(p, "%[string \"(.-)\"%]", "%1")
	p = string.gsub(p, "\r\n", "\n")
	p = string.gsub(p, "\n", "\r\n")
	
	
	--SAVE LOG
	love.filesystem.createDirectory("errors")
	local n = 1
	local function addzeros(nb, sz)
		while string.len(nb) < sz do
			nb = "0" .. nb
		end
		return nb
	end
	
	while love.filesystem.exists("errors/log_" .. addzeros(tostring(n), 4) .. ".txt") do
		n = n+1
	end
	
	local state, percent, seconds = love.system.getPowerInfo()
	local powerInf = "State: " .. tostring(state) .. "; " .. tostring(percent) .. "%; " .. tostring(seconds) .. " seconds"
	if state == "unknown" then
		powerInf = "State: Unknown"
	elseif state == "nobattery" then
		powerInf = "State: No battery"
	end
	
	function string:split(delimiter) --Not by me
		local result = {}
		local from  = 1
		local delim_from, delim_to = string.find( self, delimiter, from  )
		while delim_from do
			table.insert( result, string.sub( self, from , delim_from-1 ) )
			from = delim_to + 1
			delim_from, delim_to = string.find( self, delimiter, from  )
		end
		table.insert( result, string.sub( self, from  ) )
		return result
	end

	local major, minor, revision, codename = love.getVersion( )

	local errorlog = {	
					"[Love Version] " .. major .. "." .. minor .. "." .. revision .. "(" .. codename .. ")",
					"[Error time] " .. errortime, p,
					"[System OS] " .. love.system.getOS(),
					"[Power Supply] " .. powerInf,
					"[Processing cores] " .. love.system.getProcessorCount() 
					}

	love.filesystem.write("errors/log_" .. addzeros(tostring(n), 4) .. ".txt", table.concat(errorlog, "\r\n\r\n"))
	
	p = string.gsub(p, "\r\n", "\n")
	
	--Load fonts, for... error reasons. Yes, getting errors in the error handler is NOT a good thing...
	local errorfont1 = love.graphics.newFont("fonts/absender.ttf",14*scale)
	local errorfont2 = love.graphics.newFont("fonts/absender.ttf",48*scale)
	local errorfont3 = love.graphics.newFont("fonts/absender.ttf",54*scale)
	local errorfont4 = love.graphics.newFont("fonts/absender.ttf",18*scale)
	
	local tb = p:split("\n")
	local sz = 0
	for i, v in ipairs(tb) do
		if string.len(v) >= 1 then
			if errorfont1:getWidth(v) > sz then
				sz = errorfont1:getWidth(v)
			end
		end
	end

	local emailp = string.gsub(p, "\n", "%%0D%%0A")

	p = string.gsub(p, "\n", "\r\n")
	
	local cy = (138+16)*scale
	
	local starty = cy
	local biggerbutton = 0
	local buttons = 
	{	
		{x = 16*scale, text = "GET LOG FILE", func = function() love.system.openURL("file://" .. love.filesystem.getSaveDirectory() .. "/errors/log_" .. addzeros(tostring(n), 4) .. ".txt") end},
		{x = 16*scale, text = "SEND CRASH TO\nDEV. E-MAIL", func = function() 
			love.system.openURL("mailto:jeremy.postelnek@gmail.com?subject=Turtle: Invaders crash report&body=" .. emailp) 
		end},
		{x = 16*scale, text = "COPY ERROR TO\nCLIPBOARD", func = function() love.system.setClipboardText(p) end},
		{x = 32*scale, y = 110*scale+errorfont1:getHeight(), text = love.filesystem.getSaveDirectory() .. "/errors/", draw = false, font = errorfont1, func = function() love.system.openURL("file://" .. love.filesystem.getRealDirectory("/errors/log_" .. addzeros(tostring(n), 4) .. ".txt")) end} 
	}
	
	for i, v in ipairs(buttons) do
		local f = errorfont4
		if v.font then 
			f = v.font 
		end
		
		local s = v.text:split("\n")
		local bigger = 0
		for a = 1, #s do
			if f:getWidth(s[a]) > bigger then
				bigger = f:getWidth(s[a])
			end
		end
		
		v.width = bigger+8*scale
		if v.draw ~= false then
			biggerbutton = math.max(v.x+v.width+8*scale, biggerbutton)
		end
		v.height = f:getHeight()*#s+8*scale
		if not v.y then
			v.y = starty
			starty = v.y+v.height+8*scale
		end
	end
	
	local f = love.audio.newSource("sound/crash.ogg")
	love.audio.play(f)

	local function draw()
        love.graphics.clear()
		love.graphics.setColor(255, 255, 255, 255)
		love.graphics.draw(error_img, love.window.getWidth() / 2 - (error_img:getWidth() * scale) / 2, love.window.getHeight() / 2 - (error_img:getHeight() * scale) / 2, 0, scale, scale)
		
		love.graphics.setColor(255, 0, 0)
		
		love.graphics.setFont(errorfont2)
		
		x = errorfont3:getWidth("INVADERS")/2+16*scale
		
		love.graphics.print("TURTLE:", x-errorfont2:getWidth("Turtle:")/2, 16*scale)
		
		love.graphics.setColor(0, 255, 0)
		love.graphics.setFont(errorfont3)
		love.graphics.print("INVADERS", x-errorfont3:getWidth("INVADERS")/2, 56*scale)
		
		love.graphics.setColor(0, 0, 0, 105)
		love.graphics.setLineWidth(3)
		love.graphics.rectangle("fill", biggerbutton, cy, love.window.getWidth()-biggerbutton-8*scale, love.window.getHeight()-cy-8*scale)
		love.graphics.rectangle("line", biggerbutton, cy, love.window.getWidth()-biggerbutton-8*scale, love.window.getHeight()-cy-8*scale)
		
		love.graphics.setFont(errorfont4)
		for i, v in ipairs(buttons) do
			if v.draw ~= false then
				love.graphics.setColor(105, 105, 205, 255)
				if inside(love.mouse.getX(), love.mouse.getY(), 0, 0, v.x, v.y, v.width, v.height) then
					love.graphics.setColor(55, 55, 155, 255)
				end
				love.graphics.rectangle("fill", v.x, v.y, v.width, v.height)
				love.graphics.setColor(75, 75, 155, 255)
				if inside(love.mouse.getX(), love.mouse.getY(), 0, 0, v.x, v.y, v.width, v.height) then
					love.graphics.setColor(25, 25, 105, 255)
				end
				love.graphics.rectangle("line", v.x, v.y, v.width, v.height)
				love.graphics.setColor(255, 255, 255, 255)
				love.graphics.print(v.text, v.x+4*scale, v.y+6*scale)
			end
		end
		
		love.graphics.setColor(255, 255, 255, 255)
		love.graphics.line(16*scale, 98*scale, love.window.getWidth()-16*scale, 98*scale)
		love.graphics.line(16*scale, 138*scale, love.window.getWidth()-16*scale, 138*scale)
		love.graphics.setLineWidth(1)
		
		love.graphics.setFont(errorfont1)
		love.graphics.print("A log of this crash has been saved in:", 32*scale, 106*scale)
		
		love.graphics.setColor(205, 205, 255, 255)
		local v = buttons[4]
		if inside(love.mouse.getX(), love.mouse.getY(), 0, 0, v.x, v.y, v.width, v.height) then
			love.graphics.setColor(25, 25, 105, 255)
		end
		
		local s = love.filesystem.getSaveDirectory() .. "/errors/"
		love.graphics.print(s, 32*scale, 110*scale+errorfont1:getHeight())
		love.graphics.line(32*scale, 110*scale+errorfont1:getHeight()*2, 32*scale+errorfont1:getWidth(s), 110*scale+errorfont1:getHeight()*2)
		
		love.graphics.setColor(255, 255, 255, 255)
        love.graphics.print(errortime, love.window.getWidth()-16*scale-errorfont1:getWidth(errortime), 96*scale-errorfont1:getHeight())
		love.graphics.setScissor(biggerbutton, cy, love.window.getWidth()-biggerbutton-8*scale, love.window.getHeight()-cy-8*scale)
        love.graphics.printf(p, biggerbutton+6*scale, cy+6*scale, love.window.getWidth()-biggerbutton-16*scale, "left")
		love.graphics.setScissor()
        love.graphics.present()
    end

    while true do
        love.event.pump()

        for e, a, b, c in love.event.poll() do
            if e == "quit" then
                return
            end
            if e == "keypressed" and a == "escape" then
                return
            end
			if e == "mousepressed" then
				local x, y, button = a, b, c
				if button == "l" then
					for i, v in pairs(buttons) do
						if inside(x, y, 0, 0, v.x, v.y, v.width, v.height) and v.func then
							v.func()
						end
					end
				end
			end
        end

        draw()

        if love.timer then
            love.timer.sleep(0.1)
        end
    end
end

function love.textinput(u)
	if _G[state .. "_textinput"] then
		_G[state .. "_textinput"](u)
	end
end

function love.focus(f)
	if not clientonline and not netplay then
		if not f and state == "game" and not gameover then
			paused = true
			love.audio.pause()
		elseif f then
			love.audio.resume()
		end
	end
end

function love.draw()
	if fullscreenbool then
		love.graphics.translate(missingX, missingY)
	end

	if _G[state .. "_draw"] then
		_G[state .. "_draw"]()
	end

	if notices then
		for k, v in pairs(notices) do
			love.graphics.setScissor(0, 0, 600 * scale, 300 * scale)
			v:draw()
			love.graphics.setScissor()
		end
	end

	if achievements then
		for k, v in pairs(achievements) do
			v:draw()
		end
	end

	--drawBetaBanner()
end

function drawBetaBanner()
	love.graphics.push()
	love.graphics.rotate(-math.pi/4)
	love.graphics.setColor(0, 148, 255, 200)
	love.graphics.rectangle("fill", -54 * scale, 20 * scale, 120 * scale, 30 * scale)
	love.graphics.setColor(255, 255, 255, 200)
	love.graphics.setFont(font4)
	love.graphics.print("Beta", (-54 + (104 / 2)) * scale - love.graphics.getFont():getWidth("Beta") / 2, (22 + (30 / 2)) * scale - love.graphics.getFont():getHeight("Beta") / 2)
	love.graphics.pop()
end

function love.update(dt)
	dt = math.min(0.1666667, dt)
	gdt = dt 
	
	if _G[state .. "_update"] then
		_G[state .. "_update"](dt)
	end

	if clientonline then
		client:update(dt)
		client:netUpdate(dt)
	end

	if netplay then
		server:update(dt)
	else
		if achievements then
			for k, v in pairs(achievements) do
				v:update(dt)
			end
		end
		
		if not clientonline then
			HBD:updateRecording(dt)
		end
	end

	util.updateTimers(dt)
	
	if notices then
		for k, v in pairs(notices) do
			v:update(dt)
		end
	end
end

function love.keypressed(k, u)
	if k == "space" then
		k = " "
	end
	
	if _G[state .. "_keypressed"] then
		_G[state .. "_keypressed"](k, u)
	end
	
	HBD:keypressed(k)
end

function love.gamepadpressed(joystick, button)
	if _G[state .. "_joystickpressed"] then
		_G[state .. "_joystickpressed"](joystick, button)
	end
end

function love.gamepadaxis(joystick, axis, value)
	if _G[state .. "_joystickaxis"] then
		_G[state .. "_joystickaxis"](joystick, axis, value)
	end
end

function love.joystickadded( joystick )
	if not mobileMode then
		local id = joystick:getID()

		newNotice("Joystick number " .. id .. " connected.")

		if _G[state .. "_joystickadded"] then
			_G[state .. "_joystickadded"]( joystick )
		end
	end
end

function love.joystickremoved( joystick )
	local id = joystick:getID()

	newNotice("Joystick number " .. id .. " removed.")

	if _G[state .. "_joystickremoved"] then
		_G[state .. "_joystickremoved"]( joystick )
	end
end

function love.keyreleased( key, repeats )
	if _G[state .. "_keyreleased"] then
		_G[state .. "_keyreleased"](key)
	end
end

function love.mousepressed(x, y, button)
	if _G[state .. "_mousepressed"] then
		_G[state .. "_mousepressed"](x - missingX, y - missingY, button)
	end
end

function love.mousereleased(x, y, button)
	if _G[state .. "_mousereleased"] then
		_G[state .. "_mousereleased"](x - missingX, y - missingY, button)
	end
end

function love.mousemoved(x, y, dx, dy)
	if _G[state .. "_mousemoved"] then
		_G[state .. "_mousemoved"](x, y, dx, dy)
	end
end