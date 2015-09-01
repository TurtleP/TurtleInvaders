function settings_load(tabi, selectioni)
	state = "settings"
	highlightMax = 1
	highlightTimer = 0

	love.audio.stop(audio["credits"])

	--	{minimum distance from text, oscilation distance, bar size}
	highlightOsc = {2, 5, 5}
	
	slideTime = 0
	slideMax = .5
	slideDist = 10
	
	volumeSteps = 10

	--[[
		plug in, you use controller 1 for player 1, and use its default bindings. 
		You can still change these bindings in settings, however.
	--]]
	
	settings_windowx = 600 / 2 - 200
	settings_windowy = 300 / 2 - 110
	settings_width = 400
	settings_height = 220

	tabs = {"general", "audio / video", "achievements"}

	keyBlackListings = 
	{
		["up"] = true,
		["down"] = true,
		["left"] = true,
		["right"] = true,
		["lshift"] = true,
		["rshift"] = true,
		["lctrl"] = true,
		["rctrl"] = true,
		["lalt"] = true,
		["ralt"] = true,
		["kp0"] = true,
		["kp1"] = true,
		["kp2"] = true,
		["kp3"] = true,
		["kp4"] = true,
		["kp5"] = true,
		["kp6"] = true,
		["kp7"] = true,
		["kp8"] = true,
		["kp9"] = true,
		["kp+"] = true,
		["kp."] = true,
		["kpenter"] = true,
		["kp*"] = true,
		["kp/"] = true,
	}

	love.graphics.setFont(font5)

	if not tabi and not selectioni then
		settingstabi = 1
		settings_selectioni = 1
	else
		settingstabi = tabi
		settings_selectioni = selectioni
	end

	settingstab = tabs[settingstabi]

	generalmax = 5

	currentply = 1
	currentplyList = {1, 2, 3, 4}
	
	controlTypes = {"move left", "move right", "shoot bullets", "special ability"}

	settings = {
		general = {
			{"Difficulty", "list", "difficultyi", difficultytypes},
			{"Game Mode", "list", "gamemodei", gamemodes},
			{"Modify Controls", "function", function() settingstab = "controls" settings_selectioni = 1 end},
			{"View Credits", "function", credits_load},
			{"Restore all Defaults", "function", defaultSettings}
		},
		["audio / video"] = {
			{"Sound Volume", "volume", "soundvolume"},
			{"Music Volume", "volume", "musicvolume"},
			{"Game Scale", "value", "scale", 1, changescale, "scale"},
			{"Vertical Sync", "toggle", "vsyncbool"}
		},
		achievements = {
			
		},
		controls = {
			{"Edit Player", "listfunction", "currentply", currentplyList, settings_refreshControls}
		}
	}

	if mobileMode then
		settings["general"][3] = {"Control type", "list", "controli", controltypes}

		table.remove(settings["audio / video"], 3)

		settings["general"][5][1] = "Reset cache and settings"
	end

	local text = controls[currentply]

	for k = 1, #controlTypes do
		if text[k] == " " then
			text[k] = "spacebar"
		end
		table.insert(settings["controls"], {controlTypes[k], "textfunction", text[k], function()
			setControls = true
		end})
	end

	for k = 1, #achievementsData do
		table.insert(settings["achievements"], {"achievement", achievements[achievementsData[k].internal]})
	end

	inputkeyDelay = 0.2
end

function settings_keyInput(t, val, axis)
	if inputkeyDelay > 0 then
		return
	end

	if val ~= "escape" then
		local inputString = ""

		if t == "keyboard" then
			inputString = val
		else
			if t == "joystickbutton" then
				inputString = "gamepad:" .. val
			elseif t == "joystickaxis" then
				local dir = "neg"
				if val > 0.2 then
					dir = "pos"
				end

				inputString = inputString .. axis .. ":" .. dir
			end
		end
		
		controls[currentply][settings_selectioni-2] = inputString

		data = inputString
		if data == " " then
			data = "spacebar"
		end

		settings["controls"][settings_selectioni-1] = {controlTypes[settings_selectioni-2], "textfunction", data, function()
			setControls = true
		end}

		setControls = false
	else
		setControls = false
	end

	inputkeyDelay = 0.4
end

function settings_joystickaxis(joystick, axis, value)
	if setControls then
		if value > gamepaddeadzone or value < -gamepaddeadzone then
			settings_keyInput("joystickaxis", value, axis)
		end
	end
end

function settings_refreshControls()
	for k = 1, #controlTypes do
		settings["controls"][k+1] = {controlTypes[k], "textfunction", controls[currentply][k], function()
			setControls = true
		end}
	end
end

function settings_joystickadded(joystick)
	settings_refreshControls()
end

function settings_joystickremoved(joystick)
	settings_refreshControls()
end

function settings_joystickpressed(joystick, button)
	if not setControls then
		if button == "b" then
			settings_movecursor(nil, nil, false)
		elseif button == "dpdown" then
			settings_movecursor(nil, false)
		elseif button == "dpup" then
			settings_movecursor(nil, true)
		elseif button == "dpright" then
			settings_movecursor(true)
		elseif button == "dpleft" then
			settings_movecursor(false)
		elseif button == "a" then
			settings_movecursor(nil, nil, true)
		end
	else
		settings_keyInput("joystickbutton", button)
	end	
end

function settings_update(dt)
	menu_update(dt)

	highlightTimer = highlightTimer + dt
	if highlightTimer >= highlightMax then
		highlightTimer = highlightTimer - highlightMax
	end
	
	if slideTime > 0 then
		slideTime = math.abs(math.max(0, slideTime-dt))
		
		--negative 0 or something. HNNNNNNG
		if slideTime < 0 then 
			slideTime = 0 
		end
	end

	if setControls then
		if inputkeyDelay > 0 then
			inputkeyDelay = inputkeyDelay - dt
		end
	end
end

function settings_draw()
	menu_draw(100)
	local font = love.graphics.getFont()
	
	love.graphics.setColor(32, 32, 32, 255)
	love.graphics.rectangle("fill", settings_windowx * scale, settings_windowy * scale, settings_width * scale, settings_height * scale)

	love.graphics.setColor(255, 255, 255)
	love.graphics.rectangle("line", settings_windowx * scale, settings_windowy * scale, settings_width * scale, settings_height * scale)

	local add = 0
	local width = 0
	for k = 1, #tabs do
		if k > 1 then
			width = width + font:getWidth(tabs[k - 1])
			add = add + 16
		end

		if settingstabi == k and settings_selectioni == 1 then
			local l = love.graphics.getLineWidth()
			love.graphics.setLineWidth(4)
			
			love.graphics.setColor(255, 255, 255)
			
			local w = font:getWidth(tabs[k])
			local h = font:getHeight()
			local x, y = (settings_windowx + 20) * scale + width + (add * scale), ( settings_windowy + 20 ) * scale
			local f = (math.sin(highlightTimer/highlightMax * math.pi*2)+1)/2 * highlightOsc[2]
			
			local corner = {x-highlightOsc[1]-f-2*scale, y-highlightOsc[1]-f-4*scale, x+highlightOsc[1]+f+w, y+highlightOsc[1]+f+h}
			
			love.graphics.line(corner[1], corner[2], corner[1]+highlightOsc[3], corner[2])
			love.graphics.line(corner[1], corner[2], corner[1], corner[2]+highlightOsc[3])
			love.graphics.line(corner[3], corner[2], corner[3]-highlightOsc[3], corner[2])
			love.graphics.line(corner[3], corner[2], corner[3], corner[2]+highlightOsc[3])
			love.graphics.line(corner[1], corner[4], corner[1]+highlightOsc[3], corner[4])
			love.graphics.line(corner[1], corner[4], corner[1], corner[4]-highlightOsc[3])
			love.graphics.line(corner[3], corner[4], corner[3]-highlightOsc[3], corner[4])
			love.graphics.line(corner[3], corner[4], corner[3], corner[4]-highlightOsc[3])
			
			love.graphics.setLineWidth(l)
		else
			love.graphics.setColor(127, 127, 127)
		end
		
		love.graphics.print(tabs[k], (settings_windowx + 20) * scale + width + (add * scale), ( settings_windowy + 20 ) * scale )
	end

	if settingstab == "general" then
		love.graphics.setColor(255, 255, 255)
		love.graphics.print(version, (settings_windowx + settings_width) * scale - font:getWidth(version) - 3 * scale, (settings_windowy + settings_height) * scale - font:getHeight(version))
	end

	settings_drawtab()
end

function settings_drawtab()
	local font = love.graphics.getFont()
	local slide = math.floor(math.sin((slideMax-slideTime)/slideMax * (math.pi/2)) * slideDist)*scale
	
	for i, v in ipairs(settings[settingstab]) do
		love.graphics.setColor(127, 127, 127)
		local y = (settings_windowy + 60) * scale + (i-1)*30*scale
		local x = (settings_windowx + 20) * scale
		
		if settings_selectioni == i+1 then
			x = x + slide
			love.graphics.setColor(255, 255, 255)
		end
		
		if v[1] == "achievement" then
			
			love.graphics.setScissor(x - 2 * scale, (settings_windowy + 58) * scale, 360 * scale, 128 * scale)
			local off = math.max(0, (settings_selectioni * v[2].height - 128) * scale)
			local y = (settings_windowy + 60) * scale + (i-1)*38*scale

			local img = v[2].imgGray
			local extraStr = ""

			love.graphics.print(i .. ".", x, (y + (v[2].height / 2) * scale - font5:getHeight(i .. ".") / 2) + 4 * scale - off)

			if v[2].unlocked then
				img = v[2].graphic
				extraStr = " (" .. v[2].unlockDate .. ")"
			end

			love.graphics.draw(img, v[2].quad[v[2].quadi], x + font5:getWidth(i .. ".") + 4 * scale, y + 2 * scale - off, 0, scale, scale)

			love.graphics.print(v[2].text .. extraStr, x + font5:getWidth(i .. ".") + 40 * scale, (y + (v[2].height / 2) * scale - font5:getHeight(v[2].text) / 2) + 4 * scale - off)
			love.graphics.setScissor()

			if settings_selectioni-1 == i then
				love.graphics.print(v[2].description,  (settings_windowx + 20) * scale, (settings_windowy + settings_height) * scale - font5:getHeight(v[2].description))
			end
		elseif v[2] == "list" then
			love.graphics.print(v[1] .. ":  " .. v[4][ _G[v[3]] ], x, y)
			local x1 = font:getWidth(v[1] .. ": ")
			local y1 = font:getHeight()-4*scale
			
			local l = love.graphics.getLineWidth()
			love.graphics.setLineWidth(2*scale)
			
			love.graphics.polygon("fill", x+x1, y+y1/2, x+x1+y1/2, y, x+x1+y1/2, y+y1)
			love.graphics.polygon("line", x+x1, y+y1/2, x+x1+y1/2, y, x+x1+y1/2, y+y1)
			
			x1 = x1 + font:getWidth(" ." .. v[4][ _G[v[3]] ])
			
			love.graphics.polygon("fill", x+x1+y1/2, y+y1/2, x+x1, y, x+x1, y+y1)
			love.graphics.polygon("line", x+x1+y1/2, y+y1/2, x+x1, y, x+x1, y+y1)
			
			love.graphics.setLineWidth(l)
		elseif v[2] == "volume" then
			love.graphics.print(v[1] .. ":", x, y)
			
			local l = love.graphics.getLineWidth()
			love.graphics.setLineWidth(3*scale)
			
			for i = 1, volumeSteps do
				local x1 = x+font:getWidth(v[1] .. ": ") + (i-1)*5*scale
				local h = font:getHeight()
				local y1 = y+(volumeSteps-i)*(h/volumeSteps)
				
				
				love.graphics.setColor(55, 55, 55, 255)
				if _G[ v[3] ] >= (1/volumeSteps)*i and _G[ v[3] ] > 0 then
					love.graphics.setColor(0, 155, 255, 255)
				end
				love.graphics.line(x1, y1, x1, y1+(h/volumeSteps)*i)
			end
			
			love.graphics.setLineWidth(l)
		elseif v[2] == "toggle" then
			love.graphics.print(v[1] .. ":", x, y)
			
			love.graphics.setColor(55, 55, 55, 255)
			
			local l = love.graphics.getLineWidth()
			love.graphics.setLineWidth(6*scale)
			
			local x1 = x + font:getWidth(v[1] .. ": ") + 3*scale
			local y1 = y + font:getHeight()/2 - 3*scale
			local w = 12*scale
			
			love.graphics.circle("fill", x1, y1, 3*scale, 8*scale)
			love.graphics.circle("fill", x1 + w, y1, 3*scale, 8*scale)
			love.graphics.line(x1, y1, x1 + w, y1)
			
			love.graphics.setLineWidth(3*scale)
			love.graphics.setColor(55, 75, 85, 255)
			
			local off = 0
			if _G[ v[3] ] then
				love.graphics.setColor(0, 155, 255, 255)
				off = w
			end
			
			love.graphics.circle("line", x1+off, y1, w/2, 16*scale)
			love.graphics.circle("line", x1+off, y1, w/2, 16*scale)
			
			love.graphics.setLineWidth(l)
		elseif v[2] == "function" then
			love.graphics.print(" " .. v[1], x, y)
			
			local l = love.graphics.getLineWidth()
			love.graphics.setLineWidth(2 * scale)
			
			local x1 = font:getWidth(v[1] .. "  ")
			local y1 = font:getHeight()
			
			love.graphics.line(x, y-4*scale, x, y+y1)
			love.graphics.line(x, y-4*scale, x+5*scale, y-4*scale)
			love.graphics.line(x, y+y1, x+5*scale, y+y1)
			
			love.graphics.line(x+x1, y-4*scale, x+x1, y+y1)
			love.graphics.line(x+x1, y-4*scale, x+x1-5*scale, y-4*scale)
			love.graphics.line(x+x1, y+y1, x+x1-5*scale, y+y1)
			
			love.graphics.setLineWidth(l)
		elseif v[2] == "listfunction" then
			love.graphics.print(v[1] .. ":  " .. v[4][ _G[v[3]] ], x, y)
			local x1 = font:getWidth(v[1] .. ": ")
			local y1 = font:getHeight()-4*scale
			
			love.graphics.polygon("fill", x+x1, y+y1/2, x+x1+y1/2, y, x+x1+y1/2, y+y1)
			
			x1 = x1 + font:getWidth(" ." .. v[4][ _G[v[3]] ])
			
			love.graphics.polygon("fill", x+x1+y1/2, y+y1/2, x+x1, y, x+x1, y+y1)
		elseif v[2] == "textfunction" then
			love.graphics.print(v[1] .. ":  " .. v[3], x, y)
		elseif v[2] == "value" then
			love.graphics.print(v[1] .. ": " .. _G[ v[3] ], x, y)
		end
	end
end

function settings_keypressed(key)
	if setControls then
		if keyBlackListings[key] then
			settings_keyInput("keyboard", key)
		end
		return
	end

	if key == "escape" then
		settings_movecursor(nil, nil, false)
	elseif key == "s" or key == "down" then
		settings_movecursor(nil, false)
	elseif key == "w" or key == "up" then
		settings_movecursor(nil, true)
	elseif key == "d" or key == "right" then
		settings_movecursor(true)
	elseif key == "a" or key == "left" then
		settings_movecursor(false)
	elseif key == "enter" or key == "return" or key == "kpenter" or key == " " then
		settings_movecursor(nil, nil, true)
	end
end

function settings_textinput(text)
	if setControls then
		settings_keyInput("keyboard", text)
	end
end

function settings_movecursor(right, up, enter)
	if up ~= nil then
		if up then
			if settings_selectioni > 1 then
				settings_selectioni = settings_selectioni - 1
				slideTime = slideMax
			end
		else
			if settings_selectioni <= #settings[settingstab] then
				settings_selectioni = settings_selectioni + 1
				slideTime = slideMax
			end
		end
	end

	if right ~= nil then

		if right then

			if settings_selectioni == 1 then
				if settingstabi < #tabs then
					settingstabi = settingstabi + 1

					settingstab = tabs[settingstabi]
				end
			elseif settings[settingstab][settings_selectioni-1][2] == "list" then
				local v = _G[ settings[settingstab][settings_selectioni-1][3] ]
				local n = v+1
				if n > #settings[settingstab][settings_selectioni-1][4] then n = 1 end
				_G[ settings[settingstab][settings_selectioni-1][3] ] = n
			elseif settings[settingstab][settings_selectioni-1][2] == "volume" then
				local v = _G[ settings[settingstab][settings_selectioni-1][3] ]
				local n = v+(1/volumeSteps)
				if n > 1 then n = 1 end
				_G[ settings[settingstab][settings_selectioni-1][3] ] = n

				if settings[settingstab][settings_selectioni-1][3] == "soundvolume" then
					changeVolume(n)
				else
					changeVolume(false, n)
				end
			elseif settings[settingstab][settings_selectioni-1][2] == "toggle" then
				_G[ settings[settingstab][settings_selectioni-1][3] ] = true
			elseif settings[settingstab][settings_selectioni-1][2] == "listfunction" then

				--list thing
				local v = _G[ settings[settingstab][settings_selectioni-1][3] ]
				local n = v+1
				if n > #settings[settingstab][settings_selectioni-1][4] then n = 1 end
				_G[ settings[settingstab][settings_selectioni-1][3] ] = n

				--function thing
				settings[settingstab][settings_selectioni-1][5]("right")
			elseif settings[settingstab][settings_selectioni-1][2] == "value" then

				_G [ settings[settingstab][settings_selectioni-1][3] ] = _G [ settings[settingstab][settings_selectioni-1][3] ] + settings[settingstab][settings_selectioni-1][4] --step pls (4th table index)

				local arg = {}
				if _G[ settings[settingstab][settings_selectioni-1][6] ] then
					arg = { _G[ settings[settingstab][settings_selectioni-1][6] ] } --CALLLBACK ARGS
				end

				if settings[settingstab][settings_selectioni-1][5] then
					settings[settingstab][settings_selectioni-1][5](unpack(arg)) --FUNCK THIS
				end	

			end

		else

			if settings_selectioni == 1 then
				if settingstabi > 1 then
					settingstabi = settingstabi - 1

					settingstab = tabs[settingstabi]
				end
			elseif settings[settingstab][settings_selectioni-1][2] == "list" then
				local v = _G[ settings[settingstab][settings_selectioni-1][3] ]
				local n = v-1
				if v-1 < 1 then n = #settings[settingstab][settings_selectioni-1][4] end
				_G[ settings[settingstab][settings_selectioni-1][3] ] = n
			elseif settings[settingstab][settings_selectioni-1][2] == "volume" then
				local v = _G[ settings[settingstab][settings_selectioni-1][3] ]
				local n = v-(1/volumeSteps)
				if n < 0 then n = 0 end
				_G[ settings[settingstab][settings_selectioni-1][3] ] = n

				if settings[settingstab][settings_selectioni-1][3] == "soundvolume" then
					changeVolume(n)
				else
					changeVolume(false, n)
				end
			elseif settings[settingstab][settings_selectioni-1][2] == "toggle" then
				_G[ settings[settingstab][settings_selectioni-1][3] ] = false
			elseif settings[settingstab][settings_selectioni-1][2] == "listfunction" then

				--list thing
				local v = _G[ settings[settingstab][settings_selectioni-1][3] ]
				local n = v-1
				if v-1 < 1 then n = #settings[settingstab][settings_selectioni-1][4] end
				_G[ settings[settingstab][settings_selectioni-1][3] ] = n

				--function thing
				settings[settingstab][settings_selectioni-1][5]("left")
			elseif settings[settingstab][settings_selectioni-1][2] == "value" then

				_G [ settings[settingstab][settings_selectioni-1][3] ] = _G [ settings[settingstab][settings_selectioni-1][3] ] - settings[settingstab][settings_selectioni-1][4] --step pls (4th table index)

				local arg = _G[ settings[settingstab][settings_selectioni-1][6] ] or {}

				if settings[settingstab][settings_selectioni-1][5] then
					settings[settingstab][settings_selectioni-1][5](arg)
				end	

			end

		end
	end

	if enter ~= nil then
		if enter then
			if settings_selectioni > 1 then
				if settings[settingstab][settings_selectioni-1][2] == "function" then
					local args = settings[settingstab][settings_selectioni-1][4]
					if args == nil then args = {}
					elseif type(args) ~= "table" then args = {settings[settingstab][settings_selectioni-1][4]} end
					
					settings[settingstab][settings_selectioni-1][3](unpack(args))
				elseif settings[settingstab][settings_selectioni-1][2] == "toggle" then
					_G[ settings[settingstab][settings_selectioni-1][3] ] = not _G[ settings[settingstab][settings_selectioni-1][3] ]

					if settings[settingstab][settings_selectioni-1][4] then
						settings[settingstab][settings_selectioni-1][4]()
					end
				elseif settings[settingstab][settings_selectioni-1][2] == "textfunction" then
					settings[settingstab][settings_selectioni-1][4]()
				end
			end
		else
			menu_load(true)
		end
	end
end