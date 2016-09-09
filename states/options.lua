function optionsInit()
	optionTabs = {"General", "Controls"}

	optionsX = love.graphics.getWidth() / 2 - 180 * scale
	optionsY = love.graphics.getHeight() / 2 - 105 * scale
	optionsWidth = 360
	optionsHeight = 210
	
	mainFont = love.graphics.newFont("graphics/monofonto.ttf", 24 * scale)
	logoFont = love.graphics.newFont("graphics/monofonto.ttf", 16 * scale)
	calibrationFont = love.graphics.newFont("graphics/monofonto.ttf", 40 * scale)

	optionsSelection = 1
	optionsTab = 1

	optionsSelections =
	{
		{
			{"Difficulty:", function() optionsChangeDifficulty(1) end},
			{"Game Mode:", function() optionsChangeMode(1) end},
			{"", function() end},
			{"Sound effects:", function() optionsToggleSound(false) end},
			{"Music:", function() optionsToggleSound(true) end},
			{"", function() end},
			{"Delete data", function() defaultSettings(true) end},
			{"View credits", function() util.changeState("credits") end}
		},
		{
			{"Controls type:", function() optionsChangeControls(1) end},
			{"", function() end},
			{"", function() end},
			{"", function() end},
			{"", function() end},
			{"", function() end},
			{"Calibrate accelerometer", function() if controlTypei == 1 then calibrationMode = true end end}
		}
	}

	controlsTextX = optionsX
	controlsScrollDelay = 0.4
	optionsDelay = 0.1

	calibrationMode = false
	calibrationFade = 0
	calibrationRectangleWidth = 0

	calibrationPrompt =
	{
		"Please tilt the device slightly",
		"at a comfortable position",
		"to calibrate the accelerometer.",
		"Tap anywhere when done."
	}
end

function optionsUpdate(dt)
	optionsDelay = math.max(optionsDelay - dt, 0)

	if mobileMode then
		if optionsTab == 2 then
			if calibrationMode then
				if calibrationFade < 1 then
					calibrationFade = math.min(calibrationFade + dt / 0.4, 1)
				else
					local deadZoneCapture = math.abs(util.round(accelerometerJoystick:getAxis(currentAxis), 2))

					calibrationRectangleWidth = (deadZoneCapture / 1) * 100

					if deadZoneCapture == 0 then
						return
					end

					currentDeadZone = deadZoneCapture
				end
				return
			else
				if calibrationFade > 0 then
					calibrationFade = math.max(calibrationFade - dt / 0.4, 0)
					return
				end
			end

			if controlsScrollDelay > 0 then
				controlsScrollDelay = controlsScrollDelay - dt
			else
				controlsTextX = controlsTextX - (60 * scale) * dt

				if controlsTextX + mainFont:getWidth(controlsText) < optionsX then
					controlsTextX = optionsX + optionsWidth * scale
				end
			end
		end
	end
end

function optionsDraw()
	if mobileMode then
		love.graphics.draw(backImage, util.getHeight() * 0.01, util.getHeight() * 0.011)
	end

	love.graphics.setFont(mainFont)

	--GENERAL
	love.graphics.setColor(127, 127, 127)
	if optionsTab == 1 then
		love.graphics.setColor(255, 255, 255)
	end
	love.graphics.print("General", optionsX, optionsY + 2 * scale)	

	--CONTROLS
	love.graphics.setColor(127, 127, 127)
	if optionsTab == 2 then
		love.graphics.setColor(255, 255, 255)
	end
	love.graphics.print("Controls", optionsX + 98 * scale, optionsY + 2 * scale)

	--ACHIEVEMENTS
	love.graphics.setColor(127, 127, 127)
	if optionsTab == 3 then
		love.graphics.setColor(255, 255, 255)
	end
	love.graphics.print("Achievements", optionsX + 210 * scale, optionsY + 2 * scale)

	love.graphics.setFont(logoFont)

	--GENERAL
	if optionsTab == 1 then

		love.graphics.setColor(255, 255, 255)
		love.graphics.print("v" .. versionString, (optionsX + optionsWidth * scale) - logoFont:getWidth("v" .. versionString), (optionsY + optionsHeight * scale) - logoFont:getHeight())

		love.graphics.setColor(127, 127, 127)
		if optionsSelection == 1 then
			love.graphics.setColor(255, 255, 255)
		end
		love.graphics.print("Difficulty: " .. difficulties[difficultyi], optionsX + 16 * scale, optionsY + 32 * scale)

		love.graphics.setColor(127, 127, 127)
		if optionsSelection == 2 then
			love.graphics.setColor(255, 255, 255)
		end
		love.graphics.print("Game Mode: " .. gameModes[gameModei], optionsX + 16 * scale, optionsY + 54 * scale)

		love.graphics.setColor(127, 127, 127)
		if optionsSelection == 4 then
			love.graphics.setColor(255, 255, 255)
		end

		local soundString = "Enabled"
		if not soundEnabled then
			soundString = "Disabled"
		end
		love.graphics.print("Sound Effects: " .. soundString, optionsX + 16 * scale, optionsY + 98 * scale)
		
		love.graphics.setColor(127, 127, 127)
		if optionsSelection == 5 then
			love.graphics.setColor(255, 255, 255)
		end

		local musicString = "Enabled"
		if not musicEnabled then
			musicString = "Disabled"
		end
		love.graphics.print("Music: " .. musicString, optionsX + 16 * scale, optionsY + 120 * scale)

		love.graphics.setColor(127, 127, 127)
		if optionsSelection == 7 then
			love.graphics.setColor(255, 255, 255)
		end
		love.graphics.print("Delete Data", optionsX + 16 * scale, optionsY + 164 * scale)

		love.graphics.setColor(127, 127, 127)
		if optionsSelection == 8 then
			love.graphics.setColor(255, 255, 255)
		end
		love.graphics.print("View Credits", optionsX + 16 * scale, optionsY + 186 * scale)
	end

	if optionsTab == 2 then
		if not mobileMode then
			love.graphics.setColor(127, 127, 127)
			if optionsSelection == 1 then
				love.graphics.setColor(255, 255, 255)
			end
			love.graphics.print("Move Left: " .. controls["left"]:gsub("^%l", string.upper), optionsX + 16 * scale, optionsY + 32 * scale)

			love.graphics.setColor(127, 127, 127)
			if optionsSelection == 2 then
				love.graphics.setColor(255, 255, 255)
			end
			love.graphics.print("Move Right: " .. controls["right"]:gsub("^%l", string.upper), optionsX + 16 * scale, optionsY + 54 * scale)

			love.graphics.setColor(127, 127, 127)
			if optionsSelection == 3 then
				love.graphics.setColor(255, 255, 255)
			end
			love.graphics.print("Shoot: " .. controls["shoot"]:gsub("^%l", string.upper), optionsX + 16 * scale, optionsY + 76 * scale)
			
			love.graphics.setColor(127, 127, 127)
			if optionsSelection == 4 then
				love.graphics.setColor(255, 255, 255)
			end
			love.graphics.print("Use Ability: " .. controls["ability"]:gsub("^%l", string.upper), optionsX + 16 * scale, optionsY + 98 * scale)
		else
			if calibrationMode then
				love.graphics.setColor(0, 0, 0, 200 * calibrationFade)
				love.graphics.rectangle("fill", 0, 0, util.getWidth(), util.getHeight())

				love.graphics.setColor(255, 255, 255, 255 * calibrationFade)
				love.graphics.setFont(mainFont)
			
				for y = 1, #calibrationPrompt do
					love.graphics.print(calibrationPrompt[y], util.getWidth() / 2 - mainFont:getWidth(calibrationPrompt[y]) / 2, util.getHeight() / 2 - (mainFont:getHeight() * 3) / 2 + (y - 1) * 24 * scale)
				end

				love.graphics.rectangle("fill", optionsX, util.getHeight() * 0.8, calibrationRectangleWidth * scale, 16 * scale)
				
				love.graphics.draw(backImage, util.getHeight() * 0.01, util.getHeight() * 0.011)

				return
			end

			love.graphics.setColor(127, 127, 127)
			if optionsSelection == 1 then
				love.graphics.setColor(255, 255, 255)
			end
			love.graphics.print("Controls type: " .. controlTypes[controlTypei], optionsX + 16 * scale, optionsY + 32 * scale)

			love.graphics.setColor(0, 255, 0)

			controlsText = "Tilt the device to move; tap to shoot a bullet or use a powerup if one is equipped. Hold tap to use the character's ability."
			if controlTypei == 2 then
				controlsText = "Swipe left or right to move in the specified direction; secondary tap to shoot a bullet or use a powerup if one is equipped. Hold the secondary tap to use the character's ability."
			end
			love.graphics.printf(controlsText, optionsX, optionsY + 80 * scale, optionsWidth * scale, "center")

			if controlTypei == 1 then
				love.graphics.setColor(127, 127, 127)
				if optionsSelection == 7 then
					love.graphics.setColor(255, 255, 255)
				end
				love.graphics.print("Calibrate accelerometer", optionsX + 16 * scale, optionsY + 164 * scale)
			end

			love.graphics.setColor(255, 255, 255)

			
			love.graphics.setScissor(optionsX, optionsY + optionsHeight * scale - mainFont:getHeight(), optionsWidth * scale, mainFont:getHeight())

			love.graphics.print(controlsText, controlsTextX, optionsY + 186 * scale)
		
			love.graphics.setScissor()
		end
	end

	if optionsTab == 3 then
		for k = 1, #achievements do
			love.graphics.setColor(127, 127, 127)
			if achievements[k].unlocked then
				love.graphics.setColor(255, 255, 255)
			end
			love.graphics.draw(achievementImage, achievementQuads[k], optionsX + math.mod((k - 1), 2) * 180 * scale, (((optionsY + 32 * scale) + 16 * scale) - 15 * scale) + math.floor((k - 1) /  2) * 36 * scale)
			love.graphics.print(achievements[k].title, optionsX + 40 * scale + math.mod((k - 1), 2) * 180 * scale, (((optionsY + 32 * scale) + 16 * scale) - logoFont:getHeight() / 2) + math.floor((k - 1) /  2) * 36 * scale)
		end
	end
end

function optionsTouchPressed(id, x, y, pressure)
	if calibrationMode then
		calibrationMode = false
		return
	end

	if isTapped(optionsX, optionsY + 6 * scale, mainFont:getWidth("General"), 20 * scale) then
		optionsChangeTab(1)
	elseif isTapped(optionsX + 98 * scale, optionsY + 6 * scale, mainFont:getWidth("Controls"), 20 * scale) then
		optionsChangeTab(2)
	elseif isTapped(optionsX + 210 * scale, optionsY + 2 * scale, mainFont:getWidth("Achievements"), 20 * scale) then
		optionsChangeTab(3)
	end

	if optionsDelay > 0 then
		return
	end

	if isTapped(util.getWidth() * 0.01, util.getHeight() * 0.011, 16 * scale, 16 * scale) then
	    saveSettings()
		util.changeState("title")
	end

	if optionsTab == 3 then
		return
	end

	for k = 1, #optionsSelections[optionsTab] do
		local v = optionsSelections[optionsTab][k][1]

		if v ~= "" then
			if isTapped(optionsX + 16 * scale, optionsY + (32 + (k - 1) * 22) * scale, logoFont:getWidth(v), 16 * scale) then
				
				if optionsSelection ~= k then
					optionsSelection = k
				else
					optionsSelections[optionsTab][optionsSelection][2]()
				end

				break
			end
		end
	end
end

function optionsKeyPressed(key)
	if optionsInput then
		local controlSelected = "left"
		if optionsSelection == 2 then
			controlSelected = "right"
		elseif optionsSelection == 3 then
			controlSelected = "shoot"
		elseif optionsSelection == 4 then
			controlSelected = "ability"
		end

		controls[controlSelected] = key
		optionsInput = false
		
		return
	end

	if key == "s" or key == "down" then
		optionsChangeItem(1)
	elseif key == "w" or key == "up" then
		optionsChangeItem(-1)
	elseif key == "d" or key == "right" then
		if optionsSelection == 1 then
			optionsChangeDifficulty(1)
		elseif optionsSelection == 2 then
			optionsChangeMode(1)
		end
	elseif key == "a" or key == "left" then
		if optionsSelection == 1 then
			optionsChangeDifficulty(-1)
		elseif optionsSelection == 2 then
			optionsChangeMode(-1)
		end
	elseif key == "space" or key == "return" then
		if optionsTab == 1 then
			if optionsSelection == 7 then
				defaultSettings(true)
			elseif optionsSelection == 8 then
				util.changeState("credits")
			end
		elseif optionsTab == 2 then
			if optionsSelection > 0 or optionsSelection < 5 then
				optionsInput = true
			end
		end
	elseif key == "escape" then
		saveSettings()
		
		util.changeState("title")
	elseif key == "tab" then
		optionsChangeTab()
	end
end

function optionsGamePadPressed(joystick, button)
	if joystick == currentGamePad then

		if optionsInput then
			local controlSelected = "left"
			if optionsSelection == 2 then
				controlSelected = "right"
			elseif optionsSelection == 3 then
				controlSelected = "shoot"
			elseif optionsSelection == 4 then
				controlSelected = "ability"
			end

			controls[controlSelected] = button
			optionsInput = false
			
			return
		end

		if button == "dpdown" then
			optionsChangeItem(1)
		elseif button == "dpup" then
			optionsChangeItem(-1)
		elseif button == "dpright" then
			if optionsSelection == 1 then
				optionsChangeDifficulty(1)
			elseif optionsSelection == 2 then
				optionsChangeMode(1)
			end
		elseif button == "dpleft" then
			if optionsSelection == 1 then
				optionsChangeDifficulty(-1)
			elseif optionsSelection == 2 then
				optionsChangeMode(-1)
			end
		elseif button == "a" then
			if optionsTab == 1 then
				if optionsSelection == 7 then
					defaultSettings(true)
				elseif optionsSelection == 8 then
					util.changeState("credits")
				end
			elseif optionsTab == 2 then
				if optionsSelection > 0 or optionsSelection < 5 then
					optionsInput = true
				end
			end
		elseif button == "b" then
			saveSettings()

			util.changeState("title")
		elseif button == "rightshoulder" or button == "leftshoulder" then
			optionsChangeTab()
		end
	end
end

function optionsChangeTab(i)
	if i then
		optionsTab = i
		optionsSelection = 1
		return
	end
	optionsTab = optionsTab + 1

	local max = 3
	if mobileMode then
		max = 2
	end

	if optionsTab > max then
		optionsTab = 1
	end

	optionsSelection = 1
end

function optionsChangeItem(i)
	local max = #optionsSelections[optionsTab]
	if optionsTab == 2 then
		max = 4
	else
		if (optionsSelection + i == 3) or (optionsSelection + i == 6)  then
			optionsSelection = optionsSelection + i
		end
	end

	optionsSelection = util.clamp(optionsSelection + i, 1, max)
end

function optionsChangeDifficulty(i)
	difficultyi = difficultyi + i
	if difficultyi < 1 then
		difficultyi = #difficulties
	elseif difficultyi > #difficulties then
		difficultyi = 1
	end
end

function optionsChangeMode(i)
	gameModei = gameModei + i
	if gameModei < 1 then
		gameModei = #gameModes
	elseif gameModei > #gameModes then
		gameModei = 1
	end
end

function optionsToggleSound(bgm)
	for k, v in pairs(_G) do
		if type(v) == "userdata" then
			if v.getType then
				if not bgm then
					if v:getType() == "static" then
						if v:getVolume() == 0 then
							v:setVolume(1)
							soundEnabled = true
						else
							v:setVolume(0)
							soundEnabled = false
						end
					end
				else
					if v:getType() == "stream" then
						if v:getVolume() == 0 then
							v:setVolume(1)
							musicEnabled = true
						else
							v:setVolume(0)
							musicEnabled = false
						end
					end
				end
			end
		end
	end
end

function optionsChangeControls(add)
	if not mobileMode then
		return
	end

	controlTypei = controlTypei + add
	if controlTypei > #controlTypes then
		controlTypei = 1
	end
	
	controlsTextX = optionsX
	controlsScrollDelay = 0.4
end

function optionsSetSound(bgm)
	for k, v in pairs(_G) do
		if type(v) == "userdata" then
			if v.getType then
				if not bgm then
					if v:getType() == "static" then
						if not soundEnabled then
							v:setVolume(0)
						else
							v:setVolume(1)
						end
					end
				else
					if v:getType() == "stream" then
						if not musicEnabled then
							v:setVolume(0)
						else
							v:setVolume(1)
						end
					end
				end
			end
		end
	end
end