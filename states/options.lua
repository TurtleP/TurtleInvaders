function optionsInit()
	optionTabs = {"General", "Controls"}

	optionsX = 20
	optionsY = 20
	optionsWidth = 360
	optionsHeight = 200

	util.clearFonts()
	
	mainFont = love.graphics.newFont("graphics/absender.ttf", 24)
	logoFont = love.graphics.newFont("graphics/absender.ttf", 16)

	optionsSelection = 1
	optionsTab = 1
end

function optionsDraw()
	love.graphics.setScreen("top")

	love.graphics.setFont(mainFont)

	love.graphics.setColor(32, 32, 32, 200)

	love.graphics.rectangle("fill", optionsX, optionsY, optionsWidth, optionsHeight)

	love.graphics.setColor(255, 255, 255, 255)
	love.graphics.rectangle("line", optionsX, optionsY, optionsWidth, optionsHeight)

	--GENERAL
	love.graphics.setColor(127, 127, 127)
	if optionsTab == 1 then
		love.graphics.setColor(255, 255, 255)

		love.graphics.print("Controls", optionsX + 4, optionsY + 120)
	end
	love.graphics.print("General", optionsX + 4, optionsY + 8)

	

	--ACHIEVEMENTS
	love.graphics.setColor(127, 127, 127)
	if optionsTab == 2 then
		love.graphics.setColor(255, 255, 255)
	end
	love.graphics.print("Achievements", optionsX + 100, optionsY + 8)

	love.graphics.setColor(127, 127, 127)
	if optionsTab == 3 then
		love.graphics.setColor(255, 255, 255)
	end
	love.graphics.print("Cheats", optionsX + 256, optionsY + 8)

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

		--CONTROLS
		love.graphics.setColor(127, 127, 127)
		if optionsSelection == 5 then
			love.graphics.setColor(255, 255, 255)
		end
		love.graphics.print("Enable directional pad: " .. tostring(util.toBoolean(directionalPadEnable)), optionsX + 16, optionsY + 144)

		love.graphics.setColor(127, 127, 127)
		if optionsSelection == 6 then
			love.graphics.setColor(255, 255, 255)
		end
		love.graphics.print("Shoot: " .. controls["shoot"], optionsX + 16, optionsY + 165)

		love.graphics.setColor(127, 127, 127)
		if optionsSelection == 7 then
			love.graphics.setColor(255, 255, 255)
		end
		love.graphics.print("Use ability: " .. controls["ability"], optionsX + 16, optionsY + 185)
	end
end

function optionsKeyPressed(key)
	if key == "cpaddown" then
		optionsSelection = math.min(optionsSelection + 1, 7)
	elseif key == "cpadup" then
		optionsSelection = math.max(optionsSelection - 1, 1)
	elseif key == "cpadright" then
		if optionsSelection == 1 then
			difficultyi = math.min(difficultyi + 1, #difficulties)
		elseif optionsSelection == 2 then
			gameModei = math.min(gameModei + 1, #gameModes)
		end
	elseif key == "cpadleft" then
		if optionsSelection == 1 then
			difficultyi = math.max(difficultyi - 1, 1)
		elseif optionsSelection == 2 then
			gameModei = math.max(gameModei - 1, 1)
		end
	elseif key == "a" then

	elseif key == "b" then
		util.changeState("loading", "title", 2)
	elseif key == "rbutton" then
		optionsTab = math.min(optionsTab + 1, 3)
	elseif key == "lbutton" then
		optionsTab = math.max(optionsTab - 1, 1)
	end
end
