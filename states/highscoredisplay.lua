function highscoredisplay_load(from_menu, score)
	state = "highscoredisplay"

	whitelist = 
	{
		"a", "b", "c", "d",
		"e", "f", "g", "h",
		"i", "j", "k", "l",
		"m", "n", "o", "p",
		"q", "r", "s", "t",
		"u", "v", "w", "x",
		"y", "z", "0", "1", 
		"2", "3", "4", "5", 
		"6", "7", "8", "9", 
		" "
	}
	
	highi = 1
	whitelisti = 1
	joyname = {}

	joynamei = 1
	for k = 1, 10 do
		joyname[k] = ""
	end

	chari = 0
	highscorelimit = 10
	high = 0

	if score and score > 0 then
		for k = 1, 10 do
			if (score > highscore) then
				high = k
				highi = k
				break
			end

			if (score > highscorestable[k][3]) then
				high = k
				highi = k-1
				break
			end
		end

		if high ~= 0 then
			for i = 10, high + 1, -1 do
				highscorestable[i] = {highscorestable[i - 1][1], highscorestable[i - 1][2], highscorestable[i - 1][3]}
			end
			highscorestable[high] = {"", difficultytypes[difficultyi], score}
		else
			if not from_menu then
				menu_load()
			end
		end
	else
		high = nil --in case it was set, we don't want that
		if not from_menu then
			menu_load()
		end
	end

	ranktable = {"Top:", "2nd:", "3rd:", "4th:", "5th:",
				 "6th:", "7th:", "8th:", "9th:", "10th:"}

	scrolly = 0
	smoothscroll = scrolly
	scrollrate = 4

	cursory = 206*scale
	scoremode = true

	header = "High Scores:"
	highfade = 1
	highfadetimer = 0
end

function highscoredisplay_draw()
	love.graphics.setFont(scoresfont)

	love.graphics.setColor(0, 128, 0)
	love.graphics.print(header, (love.window.getWidth()/2-scoresfont:getWidth(header)/2)-2*scale, 18*scale)
	love.graphics.setColor(255, 255, 255)
	love.graphics.print(header, love.window.getWidth()/2-scoresfont:getWidth(header)/2, 20*scale)
	--[[DISPLAY: | Place | Name | Difficulty | Score |]]

	--highscoredisplay_displayTable()

	--[[love.graphics.setColor(2, 111, 193)
	love.graphics.print("Top: ", 40*scale, 128*scale)
	love.graphics.setColor(255, 255, 255)
	love.graphics.print("Top: ", 42*scale, 130*scale)]]

	for k = 1, #ranktable do
		if k == 1 then
			love.graphics.setColor(2, 111, 193)
			love.graphics.print(ranktable[k] .. " " .. highscorestable[k][1] .. "\t" .. highscorestable[k][2] .. "\t" .. comma_value(highscorestable[k][3]), 40*scale, 128*scale)

			love.graphics.setColor(255, 255, 255, 255)
			love.graphics.print(ranktable[k] .. " " .. highscorestable[k][1] .. "\t" .. highscorestable[k][2] .. "\t" .. comma_value(highscorestable[k][3]), 42*scale, 130*scale)
		else
			love.graphics.setScissor(1*scale, 194*scale, 658*scale, 105*scale)

			love.graphics.push()

			love.graphics.translate(0, -smoothscroll)

			love.graphics.setColor(173, 0, 0, 255)
			love.graphics.print(ranktable[k] .. " " .. highscorestable[k][1] .. "\t" .. highscorestable[k][2] .. "\t" .. comma_value(highscorestable[k][3]), 40*scale, (168+(k-1)*36)*scale)

			love.graphics.setColor(255, 255, 255, 255)
			love.graphics.print(ranktable[k] .. " " .. highscorestable[k][1] .. "\t" .. highscorestable[k][2] .. "\t" .. comma_value(highscorestable[k][3]), 42*scale, (170+(k-1)*36)*scale)

			love.graphics.setScissor()

			love.graphics.pop()	
		end
	end
end

function highscoredisplay_update(dt)
	if highi < 7 then
		smoothscroll = smoothscroll + ((((highi-1)*(36*scale))-smoothscroll)*scale)*scrollrate*dt
	else 
		smoothscroll = smoothscroll + ((((7-1)*(36*scale))-smoothscroll)*scale)*scrollrate*dt
	end
end

function highscoredisplay_keypressed(k)
	if high == nil then
		if k == "s" or k == "down" then
			highscoredisplay_movecursor(false)
		elseif k == "w" or k == "up" then
			highscoredisplay_movecursor(true)
		end

		if k == "return" or k == "escape" then
			highscoredisplay_movecursor(nil, true)
		end

		if k == "right" or k == "d" then
			highscoredisplay_movecursor(nil, nil, nil, true)
		elseif k == "left" or k == "a" then
			highscoredisplay_movecursor(nil, nil, nil, false)
		end
	else 
		if k == "backspace" then
			highscoredisplay_movecursor(nil, nil, true)
		end

		if k == "return" or k == "escape" then
			highscoredisplay_movecursor(nil, true)
		end
	end
end

function highscoredisplay_displayTable()
	local score

	for i, v in ipairs(highscorestable) do
		score = comma_value(v[3])

		if i == 1 then
			love.graphics.setColor(2, 111, 193)
			love.graphics.print(v[1], 100*scale, 128*scale)
			love.graphics.setColor(255, 255, 255)
			love.graphics.print(v[1], 102*scale, 130*scale)
				
			love.graphics.setColor(105,105,105)
			love.graphics.print(v[2], (love.window.getWidth()/2-scoresfont:getWidth(v[2])/2)-2*scale, 128*scale)
			love.graphics.setColor(255, 255, 255)
			love.graphics.print(v[2], love.window.getWidth()/2-scoresfont:getWidth(v[2])/2, 130*scale)

			love.graphics.setColor(184,134,11)
			love.graphics.print(score, 424*scale, 128*scale)
			love.graphics.setColor(255, 255, 255)
			love.graphics.print(score, 426*scale, 130*scale)
		else 
			love.graphics.setScissor(1*scale, 194*scale, 658*scale, 105*scale)
				
			love.graphics.push()

			love.graphics.translate(0, -smoothscroll)

			love.graphics.setColor(105,105,105)
			love.graphics.print(v[2], (love.window.getWidth()/2-scoresfont:getWidth(v[2])/2)-2*scale, (168+(i-1)*36)*scale)
			love.graphics.setColor(255, 255, 255)
			love.graphics.print(v[2], love.window.getWidth()/2-scoresfont:getWidth(v[2])/2, (170+(i-1)*36)*scale)

			love.graphics.setColor(202, 135, 2)
			love.graphics.print(score, 424*scale, (168+(i-1)*36)*scale)
			love.graphics.setColor(255, 255, 255)
			love.graphics.print(score, 426*scale, (170+(i-1)*36)*scale)

			love.graphics.pop()

			love.graphics.setScissor()
		end
	end
end

function highscoredisplay_joystickpressed(joy, button)
	if high ~= nil and high > 0 then
		local id = joy:getID()
		if id == 1 then
			if joy:isDown(12) then
				highscoredisplay_movecursor(nil, nil, true)
			elseif joy:isDown(5) then
				highscoredisplay_movecursor(nil, true)
			elseif joy:isDown(11) then
				highscoredisplay_movecursor(nil, nil, false)
			end
		end
	elseif high == nil then
		if joy:isDown(12) then
			highscoredisplay_movecursor(nil, nil, false)
		end
	end
end

function highscoredisplay_joystickaxis(joy, axis, value)
	if axis == 2 then
		if value == 1 then
			highscoredisplay_movecursor(false)
		elseif value == -1 then
			highscoredisplay_movecursor(true)
		end
	elseif axis == 1 then
		if value == 1 then
			highscoredisplay_movecursor(nil, nil, nil, true)
		elseif value == -1 then
			highscoredisplay_movecursor(nil, nil, nil, false)
		end
	end
end

function highscoredisplay_movecursor(up, back, del, right)
	if up ~= nil then
		if not up then
			if highi < 9 then
				highi = highi + 1
				cursory = cursory + 36*scale
			end
		else 
			if highi > 1 then
				highi = highi - 1
				cursory = cursory - 36*scale
			end
		end
	end

	if back ~= nil then
		if back and high == nil then
			menu_load(false, true)
		elseif back and high ~= 0 and high ~= nil then
			if string.len(highscorestable[high][1]) > 0 then
				if not clientonline then 
					menu_load(false, true)
				else
					client_connectToLobby() --hopefully works yay
				end
			end
		end
	end

	if del ~= nil then
		if del then
			if joynamei > 1 then
				joynamei = joynamei - 1
			end
			whitelisti = 1
			joyname[joynamei] = ""
	
			if #highscorestable[high][1] > 0 then

				highscorestable[high][1] = string.sub(highscorestable[high][1], 1, -2)
			end
		else
			if not clientonline then 
				menu_load(false, true)
			else
				client_connectToLobby() --hopefully works yay
			end
		end
	end
end

function highscoredisplay_textinput(u)
	if high and high ~= 0 then
		for i = 1, #whitelist do
			if u == whitelist[i] then
				if #highscorestable[high][1] < highscorelimit then
			
					highscorestable[high][1] = highscorestable[high][1] .. u
				end
			end
		end
	end
end

function loadProper(v)
	--v is what we need, yo
	for j, w in ipairs(v) do
		if j == 1 then
			highscore = w[3]
		end
		highscorestable[j] = {w[1], w[2], w[3]}
	end
end