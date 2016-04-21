function titleInit(selection)
	titleOptions =
	{
		{"New Game", function() util.changeState("loading", "game") end},
		{"Options Menu", function() --[[util.changeState("loading", "options")]] end},
		{"Highscores", function() end},
	}

	menuSelectioni = selection or 1
	menuBatQuadi = 1

	menuBatTimer = 0

	titleState = "main"

	util.createFonts()
end

function titleUpdate(dt)
	menuBatTimer = menuBatTimer + 8 *dt
	menuBatQuadi = math.floor(menuBatTimer % 3) + 1

	if not menuSong:isPlaying() then
		menuSong:play()
	end
end

function titleDraw()
	love.graphics.setScreen("top")

	love.graphics.setDepth(1)
	
	love.graphics.setColor(255, 255, 255, 255)

	love.graphics.setFont(logoFont)

	love.graphics.setColor(255, 0, 0)
	love.graphics.print("Turtle:", util.getWidth() / 2 - logoFont:getWidth("Turtle:") / 2, 10)

	love.graphics.setColor(0, 255, 0)
	love.graphics.print("Invaders", util.getWidth() / 2 - logoFont:getWidth("Invaders") / 2, 50)

	love.graphics.setFont(mainFont)

	love.graphics.setColor(255, 255, 255)
	for k = 1, #titleOptions do
		local v = titleOptions[k][1]
		love.graphics.print(v, util.getWidth() / 2 - mainFont:getWidth(v) / 2, 120 + (k - 1) * 32)
	end

	love.graphics.draw(batImage, batQuads[menuBatQuadi][2], 200 - mainFont:getWidth(titleOptions[menuSelectioni][1]) / 2 - 32, 132 + ((menuSelectioni - 1) * 32))
	love.graphics.draw(batImage, batQuads[menuBatQuadi][1], 200 - mainFont:getWidth(titleOptions[menuSelectioni][1]) / 2 - 32, 132 + ((menuSelectioni - 1) * 32))

	love.graphics.setDepth(0)
end

function titleKeyPressed(key)
	if key == "cpadup" or key == "dup" then
		menuSelectioni = math.max(menuSelectioni - 1, 1)
	elseif key == "cpaddown" or key == "ddown" then
		menuSelectioni = math.min(menuSelectioni + 1, #titleOptions)
	elseif key == "a" then
		titleOptions[menuSelectioni][2]()
	end
end
