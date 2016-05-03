function highscoreInit(menu)
	highscoreFromMenu = menu

	mainFont = love.graphics.newFont("graphics/monofonto.ttf", 24)
	logoFont = love.graphics.newFont("graphics/monofonto.ttf", 36)

	highScoreStarLayers = {}
	for k = 1, 3 do
		highScoreStarLayers[k] = {}
		for x = 1, 100 / k do
			table.insert(highScoreStarLayers[k], star:new(love.math.random(400), love.math.random(240), k))
		end
	end

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
			highscores[highi] = {"", difficulties[difficultyi], score}
	
			keyboardInput = keyboard:new("Enter your intials.", 6)
		
			keyboardInput.onReturn = function()
				highscores[highi][1] = keyboardInput:getText()

				saveSettings()

				util.changeState("title", 1)
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

	for layer = 1, 3 do
		for j, w in pairs(highScoreStarLayers[layer]) do
			w:draw()
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
		local highString = k .. ". " .. highscores[k][1] .. "\t" .. highscores[k][2] .. "\t" .. highscores[k][3]

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

	for layer = 1, 3 do
		for j, w in pairs(highScoreStarLayers[layer]) do
			w:draw()
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
	if key == "b" then
		if highscoreFromMenu then
			util.changeState("title", 3)
		end
	end
end