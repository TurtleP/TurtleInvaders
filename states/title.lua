function titleInit(selection)
	print(warningFont)
	titleOptions =
	{
		{"New Game", function() util.changeState("charSelect") end},
		{"Options Menu", function() util.changeState("options") end},
	--	{"Online Co-Op", function() end},
		{"Highscores", function() util.changeState("highscore", true) end}
	}

	menuSelectioni = selection or 1
	menuBatQuadi = 1

	menuBatTimer = 0

	mainFont = love.graphics.newFont("graphics/monofonto.ttf", 30)
	logoFont = love.graphics.newFont("graphics/monofonto.ttf", 46)

	if not menuSong:isPlaying() then
		menuSong:play()
	end
	
	superPlayer = true
	
	if bossSong then
		bossSong:stop()
	end
end

function titleUpdate(dt)
	menuBatTimer = menuBatTimer + 8 *dt
	menuBatQuadi = math.floor(menuBatTimer % 3) + 1
end

function titleDraw()
	love.graphics.setScreen("top")

	love.graphics.setDepth(-INTERFACE_DEPTH)
	
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
		love.graphics.print(v, util.getWidth() / 2 - mainFont:getWidth(v) / 2, 120 + (k - 1) * 30)
	end

	love.graphics.draw(batImage, batQuads[menuBatQuadi][2], 200 - mainFont:getWidth(titleOptions[menuSelectioni][1]) / 2 - 32, 132 + ((menuSelectioni - 1) * 30))
	love.graphics.draw(batImage, batQuads[menuBatQuadi][1], 200 - mainFont:getWidth(titleOptions[menuSelectioni][1]) / 2 - 32, 132 + ((menuSelectioni - 1) * 30))

	love.graphics.setDepth(NORMAL_DEPTH)
end

function titleKeyPressed(key)
	if key == "cpadup" or key == "up" then
		menuSelectioni = math.max(menuSelectioni - 1, 1)
	elseif key == "cpaddown" or key == "down" then
		menuSelectioni = math.min(menuSelectioni + 1, #titleOptions)
	elseif key == "a" then
		titleOptions[menuSelectioni][2]()
	end
end