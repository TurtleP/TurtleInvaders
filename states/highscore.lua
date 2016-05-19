function highscoreInit(menu)
	highscoreFromMenu = menu

	mainFont = love.graphics.newFont("graphics/monofonto.ttf", 24)
	logoFont = love.graphics.newFont("graphics/monofonto.ttf", 36)

	local highi
	if not highscoreFromMenu then
		for x = 1, #highscores do
			if score > highscores[x][3] then
				highi = x
				break
			end
		end

		if not highi then
			util.changeState("title", 1)
		else
			for i = #highscores, highi + 1, -1 do
				highscores[i] = {highscores[i - 1][1], highscores[i - 1][2], highscores[i - 1][3]}
			end

			highscores[highi] = {"", difficulties[difficultyi], score}
	
			keyboardInput = keyboard:new("Enter your intials.", 6)
		
			keyboardInput:open()
			
			keyboardInput.onReturn = function()
				highscores[highi][1] = keyboardInput:getText()

				saveSettings()

				util.changeState("title", 1)

				keyboardInput = nil
			end
		end
	end
end

function highscoreUpdate(dt)
	if keyboardInput then
		keyboardInput:update(dt)
	end
end

function highscoreDraw()
	love.graphics.setScreen("top")

	for fieldCount = 1, #starFields do
		local v = starFields[fieldCount]

		for k, s in pairs(v) do
			s:draw()
		end
	end

	love.graphics.setDepth(-INTERFACE_DEPTH)

	love.graphics.setFont(logoFont)

	love.graphics.setColor(65, 168, 95)
	love.graphics.print("High Scores", (util.getWidth() / 2 - logoFont:getWidth("High Scores") / 2) - 1, 29)

	love.graphics.setColor(255, 255, 255)
	love.graphics.print("High Scores", util.getWidth() / 2 - logoFont:getWidth("High Scores") / 2, 30)

	love.graphics.setFont(mainFont)

	for k = 1, #highscores do
		local highString = k .. ". " .. highscores[k][1] .. "    " .. highscores[k][2] .. "    " .. highscores[k][3]

		local color = {44, 130, 201}
		if k > 1 then
			color = {255, 73, 56}
		end

		love.graphics.setColor(unpack(color))
		love.graphics.print(highString, (util.getWidth() / 2 - mainFont:getWidth(highString) / 2) - 1, (100 + (k - 1) * 32) - 1)

		love.graphics.setColor(255, 255, 255)
		love.graphics.print(highString, util.getWidth() / 2 - mainFont:getWidth(highString) / 2, 100 + (k - 1) * 32)
	end

	love.graphics.setDepth(NORMAL_DEPTH)

	love.graphics.setScreen("bottom")

	for fieldCount = 1, #starFields do
		local v = starFields[fieldCount]

		for k, s in pairs(v) do
			s:draw()
		end
	end

	if keyboardInput then
		keyboardInput:draw()
	end
end

function highscoreMousePressed(x, y, button)
	if keyboardInput then
		keyboardInput:mousepressed(x, y, button)
	end
end

function highscoreKeyPressed(key)
	if highi then
		if key == "a" then
            keyboardInput:onReturn()
        end
		return
	end

	if key == "b" then
		if highscoreFromMenu then
			util.changeState("title", 3)
		end
	end
end