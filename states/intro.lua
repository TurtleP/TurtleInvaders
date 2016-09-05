function introInit()
	introTurtleFade = 1
	introPotionFade = 0

	introTimer = 0

	warningMessage =
	{
		"Warning",
		"",
		"This game auto saves.",
		"Do not turn off the power",
		"when you see this icon",
		"",
		"between screens."
	}

	controlsMessage =
	{
		"Controls Notice",
		"",
		"This game uses the accelerometer.",
		"Please calibrate it beforehand",
		"for an optimal experience.",
		"",
		"You can change control types",
		"in the options menu."
	}

	introBatQuadi = 1
	introBatTimer = 0

	mainFont = love.graphics.newFont("graphics/monofonto.ttf", 32 * scale)
	warningFont = love.graphics.newFont("graphics/monofonto.ttf", 24 * scale)

	introTaps = 0
end

function introUpdate(dt)
	introTimer = introTimer + dt
	if introTimer > 1 and introTimer < 3 then
		introTurtleFade = math.max(introTurtleFade - dt, 0)
		introPotionFade = math.min(introPotionFade + dt, 1)
	end

	local time = 6
	if mobileMode then
		time = 10
	end

	if introTimer > time then
		util.changeState("title", 1)
		introTimer = 0
	elseif introTimer > 5 then
		introPotionFade = math.max(introPotionFade - dt, 0)
	end

	introBatTimer = introBatTimer + 8 * dt
	introBatQuadi = math.floor(introBatTimer % 3) + 1
end

function introDraw()
	love.graphics.setColor(255, 255, 255, 255 * introTurtleFade)
	love.graphics.draw(introImage, util.getWidth() / 2 - introImage:getWidth() * scale / 2, util.getHeight() * 0.2)

	love.graphics.setFont(mainFont)
	love.graphics.print("A game by TurtleP", util.getWidth() / 2 - mainFont:getWidth("A game by TurtleP") / 2, util.getHeight() * 0.65)

	love.graphics.setColor(255, 255, 255, 255 * introPotionFade)

	love.graphics.setColor(255, 255, 255, 255)

	love.graphics.setColor(255, 0, 0, 255 * introPotionFade)

--	love.graphics.print("Warning", util.getWidth() / 2 - mainFont:getWidth("Warning") / 2, 20 * scale)

	love.graphics.setColor(255, 255, 255, 255 * introPotionFade)

	love.graphics.setFont(warningFont)

	local textStartPositionY = (util.getHeight() / 2 - (warningFont:getHeight() * 6) / 2)
	for y = 1, #warningMessage do
		local v = warningMessage[y]

		if y == 1 then
			love.graphics.setColor(255, 0, 0, 255 * introPotionFade)
		else
			love.graphics.setColor(255, 255, 255, 255 * introPotionFade)
		end

		love.graphics.print(v, util.getWidth() / 2 - warningFont:getWidth(v) / 2, textStartPositionY + (y - 1) * 24 * scale)
	end

	love.graphics.draw(batImage, batQuads[introBatQuadi][2], util.getWidth() / 2 - 16 * scale, textStartPositionY + (1 + (5 - 1) * 32) * scale)
	love.graphics.draw(batImage, batQuads[introBatQuadi][1], util.getWidth() / 2 - 16 * scale, textStartPositionY + (1 + (5 - 1) * 32) * scale)

	love.graphics.setColor(255, 255, 255, 255)

	if mobileMode then
		if introPotionFade + introTurtleFade == 0 then
			local textStartPositionY = (util.getHeight() / 2 - (warningFont:getHeight() * 7) / 2)
			for y = 1, #controlsMessage do
				local v = controlsMessage[y]

				if y == 1 then
					love.graphics.setColor(0, 255, 0)
				else
					love.graphics.setColor(255, 255, 255)
				end

				love.graphics.print(v, util.getWidth() / 2 - warningFont:getWidth(v) / 2, textStartPositionY + (y - 1) * 24 * scale)
			end
		end
	end
end

function introKeyPressed(key)
	introTimersSkip()
end

function introTouchPressed(id, x, y, dx, dy, pressure)
	introTimersSkip()
end

function introTimersSkip()
	if introTimer < 3 then
		introTimer = 3
		introTurtleFade = 0
		introPotionFade = 1
	elseif introTimer < 5 then
		introTimer = 5
		introTurtleFade = 0
		introPotionFade = 0

		if not mobileMode then
			skipIntro()
		end
	elseif introTimer < 10 then
		skipIntro()
	end
end

function skipIntro()
	if introTimer > 0.5 then
		util.changeState("title")
	end
end