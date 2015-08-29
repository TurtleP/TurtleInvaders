--yay credits

function credits_load()
	state = "credits"

	creditsscroll = 0

	love.audio.stop(audio["menu"])
	playsound("credits")

	creditsoldfont = love.graphics.getFont()
end

function credits_update(dt)
	menu_update(dt)

	if creditsscroll < #creditstext * 21 * scale + font4:getHeight(creditstext[#creditstext]) / 2 then
		creditsscroll = creditsscroll + 60 * dt
	end
end

function credits_draw()
	menu_draw(30)

	love.graphics.setColor(255, 255, 255)

	love.graphics.push() 

	love.graphics.translate(0, -creditsscroll)

	love.graphics.setFont(font4)

	for k = 1, #creditstext do
		local v = creditstext[k]

		love.graphics.print(v, 300 * scale - font4:getWidth(v) / 2, 300 * scale + (k - 1) * 21 * scale)
	end

	love.graphics.pop()

	love.graphics.setFont(creditsoldfont)
end

function credits_keypressed(key)
	if key == "escape" then
		settings_load()
	end
end

function credits_joystickpressed(joystick, button)
	if button == "b" then
		settings_load()
	end
end