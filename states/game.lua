function gameInit()
	starFields = {}

	for fieldCount = 1, 3 do
		starFields[fieldCount] = {}
		for starCount = 1, math.floor(50 / fieldCount) do
			table.insert(starFields[fieldCount], star:new(love.math.random(0, util.getWidth()), love.math.random(0, util.getHeight()), fieldCount))
		end
	end

	playerData = gameCharacters[1]

	objects = {}
	objects["bat"] = {}
	objects["bullet"] = {}
	objects["boss"] = {}

	explosions = {}

	objects["player"] = 
	{
		player:new(playerData)
	}

	objects["barrier"] = 
	{
		barrier:new(-16, 0, 16, util.getHeight()),
		barrier:new(util.getWidth(), 0, 16, util.getHeight())
	}

	enemyTimer = timer:new(3, function()
		table.insert(objects["bat"], bat:new(love.math.random(0, util.getWidth() - 30), -14))
	end)

	currentWave = 0
	score = 0
	gameOver = false
	
	gameNextWave()

	waveFont = love.graphics.newFont("graphics/monofonto.ttf", 46)
	hudFont = love.graphics.newFont("graphics/monofonto.ttf", 28)
	
	displayInfo = display:new()

	state = "game"
end

function gameNextWave()
	currentWave = currentWave + 1

	waveText = "Wave " .. currentWave

	currentWaveFade = 1

	waveAdvanceSound:play()
end

function gameAddScore(add)
	score = math.max(0, score + add)
end

function gameUpdate(dt)
	
	for k, v in pairs(objects) do
		for j, w in pairs(v) do
			if w.remove then
				table.remove(objects[k], j)
			end
		end
	end

	for k = #explosions, 1, -1 do
		if explosions[k].remove then
			table.remove(explosions, k)
		end
	end

	for k, v in pairs(explosions) do
		v:update(dt)
	end

	if gameOver then
		return
	end

	for fieldCount = 1, #starFields do
		local v = starFields[fieldCount]

		for k, s in pairs(v) do
			s:update(dt)
		end
	end

	enemyTimer:update(dt)

	for k, v in pairs(objects) do
		for j, w in pairs(v) do
			if w.update then
				w:update(dt)
			end
		end
	end

	currentWaveFade = math.max(currentWaveFade - 0.6 * dt, 0)

	physicsupdate(dt)

	displayInfo:update(dt)
end

function gameDraw()
	love.graphics.setScreen("top")

	for fieldCount = 1, #starFields do
		local v = starFields[fieldCount]

		for k, s in pairs(v) do
			s:draw()
		end
	end

	for k, v in pairs(objects["bat"]) do
		v:draw()
	end

	for k, v in pairs(objects["bullet"]) do
		v:draw()
	end

	for k, v in pairs(objects["player"]) do
		v:draw()
	end

	for k, v in pairs(explosions) do
		v:draw()
	end
	
	love.graphics.setFont(waveFont)
	
	if currentWaveFade > 0 then
		love.graphics.setDepth(-0.5)

		love.graphics.setColor(255, 255, 255, 255 * currentWaveFade)
		love.graphics.print(waveText, util.getWidth() / 2 - waveFont:getWidth(waveText) / 2, util.getHeight() / 2 - waveFont:getHeight() / 2)

		love.graphics.setColor(255, 255, 255, 255)

		love.graphics.setDepth(0)
	end

	if gameOver then
		love.graphics.print("Game Over", util.getWidth() / 2 - waveFont:getWidth("Game Over") / 2, util.getHeight() / 2 - waveFont:getHeight() / 2)
	end

	love.graphics.setScreen("bottom")

	if displayInfo then
		displayInfo:draw()
	end
end

function gameKeyPressed(key)
	if not objects["player"][1] then
		return
	end

	if key == "cpadleft" then
		objects["player"][1]:moveLeft(true)
	elseif key == "cpadright" then
		objects["player"][1]:moveRight(true)
	elseif key == "b" then
		objects["player"][1]:shoot()
	end
end

function gameKeyReleased(key)
	if not objects["player"][1] then
		return
	end

	if key == "cpadleft" then
		objects["player"][1]:moveLeft(false)
	elseif key == "cpadright" then
		objects["player"][1]:moveRight(false)
	end
end

function gameCreateExplosion(self)
	table.insert(explosions, explosion:new(self.x + (self.width / 2) - 8, self.y + (self.height / 2) - 8))
end