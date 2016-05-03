function optionsInit()
	optionTabs = {"General", "Controls"}

	optionsX = 20
	optionsY = 14
	optionsWidth = 360
	optionsHeight = 210
	
	mainFont = love.graphics.newFont("graphics/monofonto.ttf", 24)
	logoFont = love.graphics.newFont("graphics/monofonto.ttf", 16)

	optionsSelection = 1
	optionsTab = 1

	optionsStarLayers = {}
	for k = 1, 3 do
		optionsStarLayers[k] = {}
		for x = 1, 100 / k do
			table.insert(optionsStarLayers[k], star:new(love.math.random(400), love.math.random(240), k))
		end
	end
end

function optionsDraw()
	love.graphics.setScreen("top")

	for layer = 1, 3 do
		for j, w in pairs(optionsStarLayers[layer]) do
			w:draw()
		end
	end

	love.graphics.setDepth(-INTERFACE_DEPTH)

	love.graphics.setFont(mainFont)

	--[[love.graphics.setColor(32, 32, 32, 200)

	love.graphics.rectangle("fill", optionsX, optionsY, optionsWidth, optionsHeight)

	love.graphics.setColor(255, 255, 255, 255)
	love.graphics.rectangle("line", optionsX, optionsY, optionsWidth, optionsHeight)]]

	--GENERAL
	love.graphics.setColor(127, 127, 127)
	if optionsTab == 1 then
		love.graphics.setColor(255, 255, 255)
	end
	love.graphics.print("General", optionsX + 8, optionsY + 2)

	

	--ACHIEVEMENTS
	love.graphics.setColor(127, 127, 127)
	if optionsTab == 2 then
		love.graphics.setColor(255, 255, 255)
	end
	love.graphics.print("Achievements", optionsX + 110, optionsY + 2)

	love.graphics.setFont(logoFont)

	--GENERAL
	if optionsTab == 1 then
		love.graphics.setColor(127, 127, 127)
		if optionsSelection == 1 then
			love.graphics.setColor(255, 255, 255)
		end
		love.graphics.print("Difficulty: " .. difficulties[difficultyi], optionsX + 16, optionsY + 32)

		love.graphics.setColor(127, 127, 127)
		if optionsSelection == 2 then
			love.graphics.setColor(255, 255, 255)
		end
		love.graphics.print("Game Mode: " .. gameModes[gameModei], optionsX + 16, optionsY + 54)

		love.graphics.setColor(127, 127, 127)
		if optionsSelection == 3 then
			love.graphics.setColor(255, 255, 255)
		end
		love.graphics.print("Delete data", optionsX + 16, optionsY + 76)

		love.graphics.setColor(127, 127, 127)
		if optionsSelection == 4 then
			love.graphics.setColor(255, 255, 255)
		end
		love.graphics.print("View credits", optionsX + 16, optionsY + 98)

		love.graphics.setColor(127, 127, 127)
		if optionsSelection == 5 then
			love.graphics.setColor(255, 255, 255)
		end
		love.graphics.print("Enable Directional Pad: " .. tostring(util.toBoolean(directionalPadEnable)):gsub("^%l", string.upper), optionsX + 16, optionsY + 142)

		love.graphics.setColor(127, 127, 127)
		if optionsSelection == 6 then
			love.graphics.setColor(255, 255, 255)
		end
		love.graphics.print("Shoot: " .. controls["shoot"]:gsub("^%l", string.upper), optionsX + 16, optionsY + 164)

		love.graphics.setColor(127, 127, 127)
		if optionsSelection == 7 then
			love.graphics.setColor(255, 255, 255)
		end
		love.graphics.print("Use Ability: " .. controls["ability"]:gsub("^%l", string.upper), optionsX + 16, optionsY + 186)
	end

	if optionsTab == 2 then
		for k = 1, #achievements do
			love.graphics.setColor(127, 127, 127)
			if achievements[k].unlocked then
				love.graphics.setColor(255, 255, 255)
			end
			love.graphics.draw(achievementImage, achievementQuads[k], optionsX + math.mod((k - 1), 2) * 180, (((optionsY + 32) + 16) - 15) + math.floor((k - 1) /  2) * 36)
			love.graphics.print(achievements[k].title, optionsX + 40 + math.mod((k - 1), 2) * 180, (((optionsY + 32) + 16) - logoFont:getHeight() / 2) + math.floor((k - 1) /  2) * 36)
		end
	end

	love.graphics.setDepth(NORMAL_DEPTH)
end

function optionsKeyPressed(key)
	if optionsInput then
		local controlSelected = "shoot"
		if optionsSelection == 7 then
			controlSelected = "ability"
		end

		if key:sub(1, 4) ~= "cpad" and key:sub(1, 1) ~= "d" then
			controls[controlSelected] = key
			optionsInput = false
		end
		return
	end

	if key == "cpaddown" then
		optionsSelection = math.min(optionsSelection + 1, 7)
	elseif key == "cpadup" then
		optionsSelection = math.max(optionsSelection - 1, 1)
	elseif key == "cpadright" then
		if optionsSelection == 1 then
			difficultyi = math.min(difficultyi + 1, #difficulties)
		elseif optionsSelection == 2 then
			gameModei = math.min(gameModei + 1, #gameModes)
		elseif optionsSelection == 5 then
			useDirectionalPad(true)
		end
	elseif key == "cpadleft" then
		if optionsSelection == 1 then
			difficultyi = math.max(difficultyi - 1, 1)
		elseif optionsSelection == 2 then
			gameModei = math.max(gameModei - 1, 1)
		elseif optionsSelection == 5 then
			useDirectionalPad(false)
		end
	elseif key == "a" then
		if optionsTab == 1 then
			if optionsSelection == 6 or optionsSelection == 7 then
				optionsInput = true
			elseif optionsSelection == 3 then
				explodeSound:play()

				defaultSettings(true)
			elseif optionsSelection == 4 then
				util.changeState("credits")
			end
		end
	elseif key == "b" then
		saveSettings()
		
		util.changeState("title", 2)
	elseif key == "rbutton" then
		optionsChangeTab(1)
	elseif key == "lbutton" then
		optionsChangeTab(-1)
	end
end

function optionsChangeTab(i)
	if optionsTab + i > 0 and optionsTab + i < 3 then
		if i > 0 then
			tabRightSound:play()
		else
			tabLeftSound:play()
		end
	end

	optionsTab = util.clamp(optionsTab + i, 1, 2)

	optionsSelection = 1
end