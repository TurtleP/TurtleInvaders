function gameInit(playerData)
	objects = {}
	objects["bat"] = {}
	objects["bullet"] = {}
	objects["boss"] = {}
	objects["powerup"] = {}
	objects["fire"] = {}
	objects["misc"] = {}

	powerupList =
	{
		"shotgun",
		"shield",
		"laser",
		"anti",
		"nobullets",
		"mega"
	}

	if netplayOnline then
		table.insert(powerupList, "blindness")
		table.insert(powerupList, "freeze")
		table.insert(powerupList, "confusion")
		table.insert(powerupList, "bomb")
	end

	megaCannon = nil

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
		barrier:new(love.graphics.getWidth() / scale, -64, 16, util.getHeight() + 64)
	}

	local time = 1.15
	if difficultyi == 2 then
		time = 1
	elseif difficultyi == 3 then
		time = 0.9
	end

	batCount = 0

	enemyTimer = timer:new(time, 
		function(self)
			gameSpawnBat(love.math.random(love.graphics.getWidth() / scale), -14, {love.math.random(-30, 30), love.math.random(30, 90)})
		end
	)

	waveTimer = timer:new(14,
		function(self)
			if objects["boss"][1] then
				return
			end

			--Boss wave number - 1 because offsets
			if gameModei == 1 then --also we don't want bosses in our freaking endless mode
				if currentWave == 5 then
					local speeds = {-120, 120}
					
					objects["boss"][1] = megabat:new(speeds[love.math.random(#speeds)])
				elseif currentWave == 17 then
					objects["boss"][1] = raccoon:new()
				elseif currentWave == 29 then
					objects["boss"][1] = phoenix:new()
				end
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

	hudFont = love.graphics.newFont("graphics/monofonto.ttf", 20 * scale)
	pauseFont = love.graphics.newFont("graphics/monofonto.ttf", 20 * scale)
	
	waveFont = love.graphics.newFont("graphics/monofonto.ttf", 32 * scale)

	achievementFont = love.graphics.newFont("graphics/monofonto.ttf", 16 * scale)

	displayInfo = display:new()
	gamePauseMenu = pausemenu:new()

	batKillCount = 0
	abilityKills = 0
	
	winFade = 0
	gameFinished = false
	
	shakeValue = 0
end

function gameSpawnBat(x, y, velocity)
	table.insert(objects["bat"], bat:new(x, y, velocity))
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

	score = math.max(score + add, 0)
end

function gameDropPowerup(x, y, oneUp)
	if oneUp then
		table.insert(objects["powerup"], powerup:new(x, y, 10))
		return
	end

	if objects["player"][1]:getPowerup() ~= "none" or objects["boss"][1] or abilities[1].initialize then
		return
	end

	displayInfo:startRoulette()
end

function gameUpdate(dt)
	if not gameOver then
		if paused then
			return
		end
	end
	
	if gameFinished then
		winFade = math.min(winFade + 0.4 * dt, 1)
		
		if winFade == 1 then
			if netplayOnline then
				util.changeState("win")
				return
			end
			util.changeState("highscore")
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
			if netplayOnline then
				return
			end
			util.changeState("highscore")
		end
		return
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

	if mobileMode then
		if tapIsHeld then
			tapTimer = tapTimer + dt
		end

		if tapTimer > 0.5 then
			if not objects["player"][1] then
				return
			end
		
			objects["player"][1]:triggerAbility()
			tapTimer = 0
		end
	
		if not accelerometerJoystick or controlTypei == 2 then
			return
		end
		
		local axisX = accelerometerJoystick:getAxis(currentAxis)

		local deadzone = currentDeadZone
		if axisX > deadzone then
			objects["player"][1]:moveRight(true)
		elseif axisX < -deadzone then
			objects["player"][1]:moveLeft(true)
		elseif axisX > -deadzone and axisX < deadzone then
			objects["player"][1]:moveRight(false)
			objects["player"][1]:moveLeft(false)
		end
	end
end

function gameDraw()
	love.graphics.push()

	if shakeValue > 0 and not paused then
		love.graphics.translate(love.math.random() * shakeValue * scale, 0)
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

	for k, v in pairs(objects["powerup"]) do
		v:draw()
	end

	for k, v in pairs(objects["boss"]) do
		v:draw()
	end

	for k, v in pairs(objects["fire"]) do
		v:draw()
	end

	for k, v in pairs(objects["misc"]) do
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

	love.graphics.pop()

	love.graphics.setFont(waveFont)

	if currentWaveFade > 0 then
		love.graphics.setColor(255, 255, 255, 255 * currentWaveFade)
		love.graphics.print(waveText, util.getWidth() / 2 - waveFont:getWidth(waveText) / 2, util.getHeight() / 2 - waveFont:getHeight() / 2)

		love.graphics.setColor(255, 255, 255, 255)
	end

	if gameOver then
		currentWaveFade = 0
		love.graphics.print("Game Over", util.getWidth() / 2 - waveFont:getWidth("Game Over") / 2, util.getHeight() / 2 - waveFont:getHeight() / 2)
	end

	love.graphics.setFont(hudFont)
	if displayInfo then
		displayInfo:draw()
	end

	if paused then
		love.graphics.setColor(0, 0, 0, 140)

		love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
		
		love.graphics.setColor(255, 255, 255, 255)

		gamePauseMenu:draw()
	end
	
	if gameFinished then
		love.graphics.setColor(0, 0, 0, 255 * winFade)
		love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
		
		love.graphics.setColor(255, 255, 255, 255)
	end
end

function gameKeyPressed(key)
	if key == "escape" then
		if currentWaveFade == 0 then
			if not gameOver then
				paused = not paused

				if paused then
					pauseSound:play()
				end
			end
		end
	end
	
	if paused then
		gamePauseMenu:keyPressed(key)
		return
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

function gameGamePadPressed(joystick, button)
	if button == "start" then
		if currentWaveFade == 0 then
			if not gameOver then
				paused = not paused

				if paused then
					pauseSound:play()
				end
			end
		end
	end
	
	if paused then
		gamePauseMenu:keyPressed(key)
		return
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

function gameGamePadReleased(joystick, button)
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

function gameTouchMoved(id, x, y, dx, dy, pressure)
	if controlTypei ~= 2 then
		return
	end

	if not swipeID then
		swipeID = id
		
		tapIsHeld = false
		tapTimer = 0
	else
	    if id ~= swipeID then
	        return
	    end
	end

	local deadzone = 20
	if dx > deadzone then
		objects["player"][1]:moveRight(true)
		objects["player"][1]:moveLeft(false)
	elseif dx < -deadzone then
		objects["player"][1]:moveLeft(true)
		objects["player"][1]:moveRight(false)
	end
end

function gameTouchPressed(id, x, y, pressure)
	if isTapped(util.getWidth() * 0.005, util.getHeight() - (pauseImage:getHeight() + 2) * scale, 16 * scale, 16 * scale) then
		paused = not paused
		return
	end
	
	if paused then
		gamePauseMenu:touchPressed(x, y)
	else
		if controlTypei == 2 then
			if id == swipeID then
				return
			else
				tapIsHeld = true
			end
		else
			tapIsHeld = true
		end

		if not objects["player"][1] then
			return
		end
		
		objects["player"][1]:shoot()
	end
end

function gameTouchReleased(id, x, y, pressure)
	tapIsHeld = false
	tapTimer = 0

	if controlTypei == 2 then
		if id ~= swipeID then
			return
		end

		if objects["player"][1] then
			objects["player"][1]:moveRight(false)
			objects["player"][1]:moveLeft(false)
		end

		swipeID = nil
	end
end