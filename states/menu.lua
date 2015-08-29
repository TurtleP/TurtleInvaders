function menu_load(fromsettings, fromhighscore, fromcoop)
	menuscrolly = 0
	menu_batquadi = 1
	score = 0

	suspended = false 

	love.audio.stop(audio["credits"])

	menu_selectioni = 1
	minselecti = 1

	if fromcoop then
		saveData("netplay")

		menu_selectioni = 2
	elseif fromsettings then
	--	savesettings()
		saveData("settings")

		menu_selectioni = 3
	elseif fromhighscore then
		saveData("highscores")
		
		loadData("highscores")

		menu_selectioni = 4
	end

	gameData = {}

	loadData("highscores")

	settings_selectioni = 1

	state = "menu"

	if audio["menu"]:isStopped() then
		playsound("menu")
	end

	love.audio.stop(audio["boss"])
	love.audio.stop(audio["finalboss"])

	menu_battimer = 0
	

	gameover = false

	players = 1
	menustate = "main"

	menu_items = 
	{
		{t = "New Game", func = partymode_load},
		{t = "Online Co-Op", func = netplay_load},
		{t = "Options Menu", func = settings_load},
		{t = "Highscores", func = function() highscoredisplay_load(true) end},
	}
	
	joydelay = 1
end

function menu_draw(alpha)
	local a = alpha or 255

	love.graphics.setColor(255, 0, 0, a)

	love.graphics.setFont(font1.lrg)

	x = (600 * scale) / 2

	love.graphics.print("Turtle:", x-font1.lrg:getWidth("Turtle:")/2, 36*scale)

	love.graphics.setColor(0, 255, 0, a)
	love.graphics.setFont(font1.xl)
	love.graphics.print("Invaders", x-font1.xl:getWidth("Invaders")/2, 76*scale)

	love.graphics.setColor(255, 255, 255, a)
		
	love.graphics.setFont(font3)
	love.graphics.print("(C) 2015 Tiny Turtle Industries", x-font3:getWidth("(C) 2014 Tiny Turtle Industries")/2, 120*scale)

	
	love.graphics.setFont(menubuttonfont)
	
	local batx = math.floor(x-menubuttonfont:getWidth(menu_items[menu_selectioni].t)/2)
			
	love.graphics.draw(graphics["bat"], batquads[menu_batquadi], batx-32*scale, (182 + (menu_selectioni - 1) * 30) * scale,0, scale, scale)
	love.graphics.draw(graphics["bateyes"], batquads[menu_batquadi], batx-32*scale, (182 + (menu_selectioni - 1) * 30) * scale,0, scale, scale)

	for k = 1, #menu_items do
		love.graphics.print(menu_items[k].t, x - menubuttonfont:getWidth(menu_items[k].t) / 2, (182 + (k - 1) * 30) * scale)
	end

	love.graphics.setFont(font3)
end

function menu_update(dt)
	menu_battimer = math.min(menu_battimer + 8*dt)
	menu_batquadi = math.floor(menu_battimer%3)+1
end

function menu_keypressed(k)
	if k == "s" or k == "down" then
		menu_movecursor(true)
	end

	if k == "w" or k == "up" then
		menu_movecursor(false)
	end

	if k == "return" or k == " " then
		menu_movecursor(nil, nil, true)
	end
		
	if k == "escape" then
		menu_movecursor(nil, nil, false)
	end

	if k == "escape" then
		menu_movecursor(nil, nil, nil, true)
	end	
end

function menu_joystickaxis(joystick, axis, value)
	if axis == "lefty" then
		if value == 1 then
			
		elseif value == -1 then
			
		end
	end
end

function menu_joystickpressed(joystick, button)
	if button == "a" then
		menu_movecursor(nil, nil, true)
	end

	if button == "dpdown" then
		menu_movecursor(true)
	elseif button == "dpup" then
		menu_movecursor(false)
	end

	if button == "b" then 
		love.event.push("quit")
	end
end

function menu_movecursor(down, right, enter, space)
	if  down ~= nil then
		if down then
			if menu_selectioni < #menu_items then
				menu_selectioni = menu_selectioni + 1
			end
		else --up
			if menu_selectioni > minselecti then
				menu_selectioni = menu_selectioni - 1
			end
		end
	end

	if enter ~= nil then
		if enter then
			if menu_items[menu_selectioni].func then
				menu_items[menu_selectioni].func()
			end
		end
	end

	if space ~= nil then
		if space then
			love.event.quit()
		else
			credits_load()
		end
	end
end