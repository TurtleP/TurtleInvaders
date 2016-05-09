function gameInit(playerData)
	starFields = {}

	for fieldCount = 1, 3 do
		starFields[fieldCount] = {}
		for starCount = 1, math.floor(100 / fieldCount) do
			table.insert(starFields[fieldCount], star:new(love.math.random(0, 400), love.math.random(0, util.getHeight()), fieldCount))
		end
	end

	objects = {}
	objects["bat"] = {}
	objects["bullet"] = {}
	objects["boss"] = {}
	objects["powerup"] = {}
	objects["fire"] = {}

	explosions = {}
	fizzles = {}
	abilities = {}

	objects["player"] = 
	{
		player:new(playerData)
	}

	objects["barrier"] = 
	{
		barrier:new(-16, -64, 16, util.getHeight() + 64),
		barrier:new(400, -64, 16, util.getHeight() + 64)
	}

	local time = 1.15
	if difficultyi == 1 then
		time = 1.5
	elseif difficultyi == 3 then
		time = 1
	end

	enemyTimer = timer:new(time, 
		function(self)
			table.insert(objects["bat"], bat:new(love.math.random(0, 370), -14))
		end
	)

	waveTimer = timer:new(14,
		function(self)
			if objects["boss"][1] then
				return
			end

			--Boss wave number - 1 because offsets
			if currentWave == 5 then
				objects["boss"][1] = megabat:new()
			elseif currentWave == 17 then
				objects["boss"][1] = raccoon:new()
			elseif currentWave == 29 then
				objects["boss"][1] = phoenix:new()
			end

			self.maxTimer = self.maxTimer + love.math.random(4)

			gameNextWave()
		end
	)

	paused = false
	
	currentWave = 0
	score = 0

	comboValue = 0
	comboTimeout = 0

	gameOver = false
	
	gameNextWave()

	waveFont = love.graphics.newFont("graphics/monofonto.ttf", 46)
	hudFont = love.graphics.newFont("graphics/monofonto.ttf", 28)
	
	displayInfo = display:new()

	batKillCount = 0
	abilityKills = 0

	shakeValue = 0

	objects["boss"][1] = phoenix:new()
end

function gameNextWave()
	currentWave = currentWave + 1

	waveText = "Wave " .. currentWave

	currentWaveFade = 1

	waveAdvanceSound:play()
end

function gameAddScore(add)
	if comboValue > 0 then
		add = add * comboValue

		if comboValue == 7 then
			achievements[7]:unlock(true)
		end
	end

	score = math.max(0, score + add)
end

function gameDropPowerup(x, y, oneUp, superUp)
	if oneUp then
		table.insert(objects["powerup"], powerup:new(x, y, 10, superUp))
		return
	end

	if objects["player"][1]:getPowerup() ~= "none" or objects["boss"][1] then
		return
	end

	local random, i = love.math.random()

	if random < .05 then
		i = 9
	elseif random < .1 then
		i = love.math.random(8)
	end

	if i then
		if i == lastDrop then
			gameDropPowerup(x, y, oneUp)

			return
		end

		table.insert(objects["powerup"], powerup:new(x, y, i))

		lastDrop = i
	end
end

function gameUpdate(dt)
	if not gameOver then
		if paused then
			return
		end
	end

	if comboValue > 0 then
		if comboTimeout < 1 then
			comboTimeout = comboTimeout + dt
		else
			comboValue = 0
		end
	end

	if shakeValue > 0 then
		shakeValue = math.max(0, shakeValue - shakeValue * dt)
	end

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

	for k = #fizzles, 1, -1 do
		if fizzles[k].remove then
			table.remove(fizzles, k)
		end
	end

	for k = #abilities, 1, -1 do
		if abilities[k].remove then
			table.remove(abilities, k)
		end
	end

	for k, v in pairs(abilities) do
		if v.update then
			v:update(dt)
		end
	end

	for k, v in pairs(explosions) do
		v:update(dt)
	end

	for k, v in pairs(fizzles) do
		v:update(dt)
	end

	if gameOver then
		if not gameOverSound:isPlaying() then
			util.changeState("highscore")
		end
		return
	end

	for fieldCount = 1, #starFields do
		local v = starFields[fieldCount]

		for k, s in pairs(v) do
			s:update(dt)
		end
	end

	enemyTimer:update(dt)

	waveTimer:update(dt)

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

	love.graphics.push()

	if shakeValue > 0 then
		love.graphics.translate(love.math.random() * shakeValue, love.math.random() * shakeValue)
	end

	for fieldCount = 1, #starFields do
		local v = starFields[fieldCount]

		for k, s in pairs(v) do
			s:draw()
		end
	end

	love.graphics.setDepth(ENTITY_DEPTH)

	for k, v in pairs(objects["bat"]) do
		v:draw()
	end

	for k, v in pairs(objects["bullet"]) do
		v:draw()
	end

	for k, v in pairs(objects["player"]) do
		v:draw()
	end

	for k, v in pairs(objects["powerup"]) do
		v:draw()
	end

	for k, v in pairs(objects["boss"]) do
		v:draw()
	end

	for k, v in pairs(objects["fire"]) do
		v:draw()
	end

	for k, v in pairs(explosions) do
		v:draw()
	end
	
	for k, v in pairs(abilities) do
		if v.draw then
			v:draw()
		end
	end
	
	for k, v in pairs(fizzles) do
		v:draw()
	end

	love.graphics.setDepth(NORMAL_DEPTH)

	love.graphics.pop()

	love.graphics.setFont(waveFont)
	
	love.graphics.setDepth(INTERFACE_DEPTH)

	if currentWaveFade > 0 then
		love.graphics.setColor(255, 255, 255, 255 * currentWaveFade)
		love.graphics.print(waveText, util.getWidth() / 2 - waveFont:getWidth(waveText) / 2, util.getHeight() / 2 - waveFont:getHeight() / 2)

		love.graphics.setColor(255, 255, 255, 255)
	end

	if gameOver then
		love.graphics.print("Game Over", util.getWidth() / 2 - waveFont:getWidth("Game Over") / 2, util.getHeight() / 2 - waveFont:getHeight() / 2)
	end

	if paused then
		love.graphics.setColor(0, 0, 0, 140)

		love.graphics.rectangle("fill", 0, 0, 400, 240)
		
		love.graphics.setColor(255, 255, 255, 255)

		love.graphics.print("Game Paused", util.getWidth() / 2 - waveFont:getWidth("Game Paused") / 2, util.getHeight() / 2 - waveFont:getHeight())
	end

	love.graphics.setFont(hudFont)
	
	if paused then
		love.graphics.print("Press 'B' to Quit", util.getWidth() / 2 - hudFont:getWidth("Press 'B' to Quit") / 2, util.getHeight() / 2 - hudFont:getHeight() / 2 + 8)
	end

	for k, v in pairs(achievements) do
		v:draw()
	end

	love.graphics.setDepth(NORMAL_DEPTH)

	love.graphics.setScreen("bottom")

	if displayInfo then
		displayInfo:draw()
	end
end

function gameKeyPressed(key)
	if key == "start" then
		if not gameOver then
			paused = not paused

			if paused then
				pauseSound:play()
			end
		end
	end

	if key == "b" then
		if paused then
			util.changeState("title", 1)
		end
	end

	if not objects["player"][1] or paused then
		return
	end

	if key == controls["left"] then
		objects["player"][1]:moveLeft(true)
	elseif key == controls["right"] then
		objects["player"][1]:moveRight(true)
	elseif key == controls["shoot"] then
		objects["player"][1]:shoot()
	elseif key == controls["ability"] then
		objects["player"][1]:triggerAbility()
	end
end

function gameKeyReleased(key)
	if not objects["player"][1] then
		return
	end

	if key == controls["left"] then
		objects["player"][1]:moveLeft(false)
	elseif key == controls["right"] then
		objects["player"][1]:moveRight(false)
	end
end

function gameCreateExplosion(self)
	table.insert(explosions, explosion:new(self.x + (self.width / 2) - 8, self.y + (self.height / 2) - 8))
end