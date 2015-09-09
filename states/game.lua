function game_load()
	state = "game"

	make_tables()
	
	game_SetupSelf(gamemodes[gamemodei]:lower(), difficultytypes[difficultyi])

	combovalue = 0
	combotimeout = 0
	batskilled = 0
	earthquake = 0
end

function newenemy(x, y, i, relay) 
	if not gameover and not paused and state == "game" and #objects["enemies"] < maxbatsonscreen then

		if not i then
			batid = batid + 1
			i = batid
		end

		table.insert(objects.enemies, enemy:new(x, y, i))

		if not relay then
			table.insert(onlinetriggers, "spawnenemy;" .. x .. ";" .. y .. ";" .. i)
		end
	end
end

function dropPowerup(x, y, t, relay)
	table.insert(objects.powerups, powerup:new(x, y, t))

	if clientonline and isnetworkhost and not relay then
		table.insert(onlinetriggers, "powerspawn;" .. t .. ";" .. x .. ";" .. y .. ";")
	end
end

function make_tables()
	objects = {}

	objects.turtle = {}
	objects.enemies = {}

	objects.powerups = {}
	objects.explosions = {}

	objects.powerup = {}

	objects.barrier = {}

	objects.boss = {}

	objects.phoenixfire = {}
	objects.phoenixshield = {}

	objects.bullets = {}

	objects.shieldparticles = {}
	objects.phoenixdeath = {}

	objects.food = {}

	objects.core = {}
	
	phantoments = {}
	combotext = {}
	fizzles = {}
end

function wave()
	playsound("nextwave")
	
	killcount = 0
	waven = waven + 1

	wavetext = "WAVE " .. waven

	wavefade = 1
	
	if gamemodei ~= 2 then
		checkforBoss()
	end
end

function checkforBoss()
	if objects.boss[1] == nil then
		if waven == bosswavestart then
			objects.boss[1] = boss:new(bossHP[difficultyi][1])
		elseif waven == coonwave then
			objects.boss[1] = spaceraccoon:new(bossHP[difficultyi][2])
		elseif waven == phoenixwave then
			objects.boss[1] = spacephoenix:new(bossHP[difficultyi][3])
		end
	end
end

function addScore(n, reason)
	if type(score) == "number" then
		local combovalue = n * combo

		local val = n --score we got from kills, etc
		if combovalue ~= 0 then
			val = combovalue --we've multiplied by fuckin uh combos.. LEGIT!
		end

		if combo == 7 then
			unlockAchievement("combomadness")
		end

		score = score + combovalue

		if score < 0 then
			score = 0
		end
	end
end

function game_SetupSelf(mode, difficulty)
	bosswavestart = 6
	coonwave = 18
	phoenixwave = 32

	cron_time = 1.5
	local hp = 3

	if difficulty == "easy" then
		cron_time = 2
	elseif difficulty == "hard" then --HARDCORE PARKOUR
		cron_time = 1
	end

	enemyclock = cron.every(cron_time, 
		function() 
			newenemy(love.math.random(5, 568), 0) 
		end)

	gradientfade = 1
	earthquake = 0
	
	fieldmovement = 0
	
	gameendtimer = 0
	combo = 0
	
	--general stuff, yay
	waven = 0
	killcount = 0
	batsescaped = 0
	bulletsshot = 0

	wave()

	local names = gameData

	if clientonline or netplay then
		names = nameData
	end



	for k = 1, #gameData do
		if gameData[k] then
			objects.turtle[k] = turtle:new((25+(k-1)*80), 280 + (math.abs(characters[gameData[k]].height - 40)), k, hp, gameData[k], names[k])
		end
	end

	deadturtles = {}
	
	paused = false

	pausefade = 1

	loadFonts()

	movestars = true

	--Doing it for THE LOLz

	objects.barrier[1] = barrier:new(0, 0)
	objects.barrier[2] = barrier:new(600, 0)

	gamepausemenu = pausemenu:new()

	game_finishtimer = 0
	game_finishfade = 0
end

function remove_objects()
	for k, v in pairs(objects) do
		for j = #v, 1, -1 do
			local w = v[j]
			
			if w.kill then
				if k == "boss" and w.type ~= "phoenix" then
					playsound("bossdefeat")
				end

				if w.onRemove then
					w:onRemove()
				end

				table.remove(v, j)

				if k == "boss" then
					audio["boss"]:setLooping(false)
					love.audio.stop(audio["boss"])
				
					wave()
				elseif objects["boss"][1] ~= nil then
					if objects.boss[1].type == "phoenix" then
						objects.boss[1]:addBats(-1)
					end
				end
			end
		end
	end

	for k = #fizzles, 1, -1 do
		if fizzles[k].kill then
			table.remove(fizzles, k)
		end
	end

	for k = #combotext, 1, -1 do
		if combotext[k].kill then
			table.remove(combotext, k)
		end
	end

	for k = #phantoments, 1, -1 do
		if phantoments[k].kill then
			table.remove(phantoments, k)
		end
	end
end

function game_draw()
	if earthquake > 0 then
		love.graphics.translate(round(tremorx), round(tremory))
	end

	for i = #starfield, 1, -1 do
		love.graphics.setScissor(0, 0, gameW * scale, gameH * scale)
			love.graphics.setPointSize(i/2)
			local yadd = starfield[i].position
			love.graphics.setColor(255, 255, 255)
			for a = 1, 2 do
				local p = 0
				if a == 1 then p = -gameH end
				for j = 1, #starfield[i].chunks[a] do
					local v = starfield[i].chunks[a][j]
					love.graphics.point(v.x*scale+.5, (v.y+yadd+p)*scale+.5)
				end
			end
		love.graphics.setScissor()
	end

	if #phantoments > 0 then
		for i, v in pairs(phantoments) do
			v:draw()
		end
	end

	for i, v in pairs(objects) do
		for j, w in pairs(v) do

			love.graphics.setScissor(0, 0, gameW * scale, gameH * scale)

			if i == "turtle" then
				w:drawAbility()
			end

			if i ~= "enemies" then
				if w.draw then
					w:draw()
				end
			end

			if i == "turtle" then
				w.ui:draw()
				w:drawShield()
			end

			if i == "enemies" then
				w:draw()
			end

			love.graphics.setScissor()

			if w.draws then
				if w.dir then
					if w.dir == "left" then
						w.scale = -scale
					else
						w.scale = scale
					end
				end
			end
		end
	end

	for k, v in pairs(objects.phoenixfire) do
		v:drawself()
	end

	love.graphics.setColor(255, 255, 255)

	for k, v in pairs(objects.phoenixshield) do
		v:drawshield()
	end
	
	for k, v in pairs(fizzles) do
		v:draw()
	end
	
	--UI FOR WHAT THE STATUS IS
	
	love.graphics.setFont(font1.lrg)
	
	if not gameover then
		love.graphics.setColor(255, 255, 255, 255*wavefade)
		love.graphics.print("Wave " .. waven, 300 * scale - font1.lrg:getWidth("Wave " .. waven) / 2, 150 * scale -font1.lrg:getHeight("Wave " .. waven) / 2)
		love.graphics.setColor(255, 255, 255, 255)
	end

	love.graphics.setFont(font2)

	love.graphics.print("SCORE: " .. comma_value(score), (gameW / 2) * scale - font2:getWidth("SCORE: " .. comma_value(score)) / 2 , 5*scale)

	if gameover then
		love.graphics.setFont(font1.lrg)
		love.graphics.setColor(255, 255, 255)
		love.graphics.print("GAME OVER!", 300 * scale - font1.lrg:getWidth("GAME OVER!") / 2, 150 * scale -font1.lrg:getHeight("GAME OVER!") / 2)
		love.graphics.setFont(font2)
	end

	if paused then
		--love.graphics.setLineWidth(1)
		love.graphics.setColor(0, 0, 0, 180*pausefade)
		love.graphics.rectangle("fill", 0, 0, width*16*scale, height*16*scale)

		love.graphics.setColor(255, 255, 255)
		gamepausemenu:draw()
	end

	if game_finishfade > 0 then
		love.graphics.setColor(255, 255, 255, 255*game_finishfade)
		love.graphics.rectangle("fill", 0, 0, gameW, gameH)
	end
end

function game_updateGameOver(dt, Gameover)

	gameendtimer = gameendtimer + dt
	
	if not Gameover then
		if not gameoversound then
			playsound("gameover")
			gameoversound = true
		end
	end

	if gameendtimer > 4 then
		highscoredisplay_load(false, score)
	end
end

function game_update(dt)
	if gameover or paused then
		if pausefade < 1 then --YOU COPIED ME >:(
			pausefade = math.min(pausefade + 3 * dt, 1) --fade out
		end

		--[[for i, v in pairs(deadturtles) do
			v:update(dt)
		end]]

		for i, v in pairs(objects.explosions) do
			v:update(dt)
		end

		remove_objects()
		
		gamepausemenu:update(dt)
		
		if gameover then
			game_updateGameOver(dt)
		end
		
		return
	end

	physics:update(dt)

	wavefade = math.max(wavefade-dt*0.5, 0)

	if #phantoments > 0 then
		for i, v in pairs(phantoments) do
			v:update(dt)
		end
	end

	for k, v in pairs(fizzles) do
		v:update(dt)
	end

	--Star Stuff
	
	if objects.boss[1] then
		movestars = false 
	else 
		movestars = true
	end
	
	if movestars then
		for i = 1, #starfield do
			starfield[i].position = starfield[i].position + dt*fieldspeed*((i-1)/2)
			if starfield[i].position >= gameH then
				starfield[i].position = math.offset(starfield[i].position, 0, gameH, gameH)
				starfield[i].chunks = {makeStarChunk(i), table.copy(starfield[i].chunks[1])}
			end
		end
	end

	remove_objects()

	if audio["bossdefeat"]:isStopped() and objects.boss[1] == nil then
		if audio["menu"]:isStopped() then
			playsound("menu")
			audio["menu"]:setLooping(true)
		end
	end

	game_checkForCore(dt)

	for i, v in pairs(objects) do
		for j, w in pairs(v) do	
			if w.update then
				w:update(dt)
			end
		end
	end
				
	if killcount == ( ( 20 * waven ) / 2 ) and objects.boss[1] == nil then
		wave()
	end
						
	if earthquake > 0 then
		earthquake = math.max(0, earthquake-dt*earthquake*2-0.001)
		tremorx = (love.math.random()-.5)*2*earthquake
		tremory = (love.math.random()-.5)*2*earthquake
	end

	if not paused then
		if audio["bossdefeat"]:isStopped() then
			if not clientonline or (clientonline and isnetworkhost) then
				enemyclock:update(dt)
			end
		end
	end

	if waven > phoenixwave and gamemodei ~= 2 then
		--do ... something?
		if noliveslost == false then
			noliveslost = true
		end

		game_finishtimer = game_finishtimer + dt 
		game_finishfade = math.min(game_finishfade+dt, 1)
		game_updateGameOver(dt, true)
	end
end

function game_joystickpressed(joystick, button)
	if not paused and not gameover then
		for k, v in pairs(objects.turtle) do
			v:joystickpressed(joystick, button)
		end
	end

	if joystick:isDown(5) then
		gamepausemenu:movecursor(nil, nil, false)
	end
end

function game_joystickaxis(joystick, axis, value)
	for k, v in pairs(objects.turtle) do
		if not paused and not gameover then
			v:joystickaxis(joystick, axis, value)
		end
	end

	if paused then
		if axis == 2 then
			if value == 1 then
				gamepausemenu:movecursor(false)
			elseif value == -1 then 
				gamepausemenu:movecursor(true)
			end
		elseif axis == 1 then
			if value == 1 then
				gamepausemenu:movecursor(nil, true)
			elseif value == -1 then
				gamepausemenu:movecursor(nil, false)
			end
		end

		if button == "b" then
			gamepausemenu:movecursor(nil, nil, true)
		end
	end
end

function game_keyreleased(k)
	if not paused and not gameover then
		for i, v in pairs(objects.turtle) do
			if controls[v.num] then
				if k == controls[v.num][2] then
					v:stopright()
				elseif k == controls[v.num][1] then
					v:stopleft()
				end
			end
		end
	end
end

function game_keypressed(k)
	if not paused and not gameover then
		for i, v in pairs(objects.turtle) do
			if controls[v.num] then
				v:keypressed(k)
				if k == controls[v.num][2] then
					v:moveright()
				elseif k == controls[v.num][1] then
					v:moveleft()
				elseif k == controls[v.num][4] then
					v:specialUp()
				end
			end
		end
	end

	if k == "escape" then
		if clientonline then
			if not client:isHosting() then
				return
			end
		end
	  	gamepausemenu:movecursor(nil, nil, false)

	  	if not paused then
	  		pausefade = 0
	  	end
	end

	if paused then
		if k == "down" or k == "s" then
			gamepausemenu:movecursor(false)
		elseif k == "up" or k == "w" then
			gamepausemenu:movecursor(true)
		end

		if k == "right" or k == "d" then
			gamepausemenu:movecursor(nil, true)
		elseif k == "left" or k == "a" then
			gamepausemenu:movecursor(nil, false)
		end

		if k == "return" or k == " " then
			gamepausemenu:movecursor(nil, nil, true)
		end
	end

	if k == "1" then
		objects["turtle"][1]:setPowerup("shield", false)
	end
end

function checkAudio()
	--these are musics
	if musicvolume > 0 then
		if state == "game" then
			if audio["menu"]:isStopped() and objects.boss[1] == nil then
				playsound("menu");audio["menu"]:setLooping(true)
			elseif objects.boss[1] then
				if audio["boss"]:isStopped() then
					if objects.boss[1].type ~= "phoenix" then
						playsound("boss");audio["boss"]:setLooping(true)
					end 
				elseif audio["finalboss"]:isStopped() and objects.boss[1].type == "phoenix" then
					playsound("finalboss");audio["finalboss"]:setLooping(true)
				end
			end
		else
			if audio["menu"]:isStopped() then
				playsound("menu")
			end
		end
	end
end

function game_checkForCore(dt)
	if coretimer > 0 then
		coretimer = coretimer - dt 
	else 
		local shouldSpawn = love.math.random(1000)
		--clearly it works
		if shouldSpawn < 10 then
			objects.core[1] = core:new()
		else 
			coretimer = love.math.random(12)
		end
	end
end