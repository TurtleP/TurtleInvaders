function winInit()
	smallFont = love.graphics.newFont("graphics/monofonto.ttf", 28 * scale)
	headerFont = love.graphics.newFont("graphics/monofonto.ttf", 36 * scale)

	clientScores = {{"", 200, love.math.random(#gameCharacters)}, {"ayylmao", 1000, love.math.random(#gameCharacters)}, {"", 420, love.math.random(#gameCharacters)}}
	table.sort(clientScores, function(a, b) return a[2] > b[2] end)

	for k = 1, #clientScores do
		local x, y = util.getWidth() / 2 - 23 * scale, util.getHeight() - (platformImage:getHeight() * scale + 20 * scale)
		if k == 2 then
			x, y = util.getWidth() / 2 - ((platformImage:getWidth() * scale) / 2), util.getHeight() - 50 * scale
		elseif k == 3 then
			x, y = util.getWidth() / 2 + (46 * scale) / 2, util.getHeight() - 50 * scale
		elseif k == 4 then
			return
		end
		clientScores[k][4] = newWinPortrait(x, y, k, clientScores[k][3])
	end

	playerCursorColors =
	{
		{255, 55, 0},
		{0, 55, 255},
		{255, 205, 0},
		{55, 255, 9}
	}

	confettiObjects = {}

	for i = 1, 120 do
		confettiObjects[i] = newConfetti(util.getWidth() / 2, -(40 * scale))
	end

	rivalsFade = 0
end

function winUpdate(dt)
	for i = #confettiObjects, 1, -1 do
		if confettiObjects[i].remove then
			table.remove(confettiObjects, i)
		end
	end

	for k, v in pairs(confettiObjects) do
		v:update(dt)
	end

	if #confettiObjects == 0 then
		rivalsFade = math.min(rivalsFade + 0.4 * dt, 1)
		if rivalsFade == 1 then
			util.changeState("highscore")
		end
	end
end

function winDraw()
	love.graphics.setFont(headerFont)
	love.graphics.print("Rivals Winner:", util.getWidth() / 2 - headerFont:getWidth("Rivals Winner:") / 2, util.getHeight() * 0.035)
	love.graphics.print(clientScores[1][1], util.getWidth() / 2 - headerFont:getWidth(clientScores[1][1]) / 2, util.getHeight() * 0.2)

	love.graphics.draw(platformImage, util.getWidth() / 2 - (platformImage:getWidth() * scale) / 2, util.getHeight() - platformImage:getHeight() * scale)

	love.graphics.setFont(smallFont)

	love.graphics.print("1", util.getWidth() / 2 - smallFont:getWidth("1") / 2, util.getHeight() - (22 * scale + smallFont:getHeight() / 2))

	love.graphics.print("2", util.getWidth() / 2 - ((platformImage:getWidth() * scale) / 2) + (23 * scale) - smallFont:getWidth("2") / 2, util.getHeight() - (14 * scale + smallFont:getHeight() / 2))

	love.graphics.print("3", util.getWidth() / 2 + (46 * scale) / 2 + (23 * scale) / 2 + smallFont:getWidth("3") / 2, util.getHeight() - (14 * scale + smallFont:getHeight() / 2))

	for k, v in pairs(clientScores) do
		if v[4] then
			v[4]:draw()
		end
	end
	
	for k, v in pairs(confettiObjects) do
		v:draw()
	end

	love.graphics.setColor(0, 0, 0, 255 * rivalsFade)
	love.graphics.rectangle("fill", 0, 0, util.getWidth(), util.getHeight())

	love.graphics.setColor(255, 255, 255, 255)
end

function newWinPortrait(x, y, place,i)
	local portrait = {}

	portrait.x = x
	portrait.y = y

	portrait.width = 46
	portrait.height = 40

	portrait.character = gameCharacters[i]
	portrait.place = place
	function portrait:draw()
		if self.character.animated then
			love.graphics.draw(self.character.graphic, self.character.quads[1], (self.x + (self.width * scale) / 2) - self.character.width * scale / 2, (self.y - (self.character.height * scale) / 2) - 4 * scale)
		else
			love.graphics.draw(self.character.graphic, (self.x + (self.width * scale) / 2) - (self.character.graphic:getWidth() * scale) / 2, (self.y - (self.character.graphic:getHeight() * scale) / 2) - 4 * scale)
		end
	end

	return portrait
end

function newConfetti(x, y)
	local confetti = {}

	confetti.x = x
	confetti.y = y

	confetti.speed = love.math.random(60, 120)
	confetti.speedx = love.math.random(-80, 80)

	local colors = 
	{
		{255, 0, 0},
		{0, 255, 0},
		{0, 0, 255}
	}

	confetti.rotation = 0
	confetti.direction = math.floor(love.math.random())

	confetti.color = colors[love.math.random(#colors)]

	function confetti:update(dt)
		self.y = self.y + self.speed * dt
		self.x = self.x + self.speedx * dt

		if self.direction == 1 then
			self.rotation = self.rotation + 16 * dt
		else
			self.rotation = self.rotation - 16 * dt
		end

		if self.y > util.getHeight() then
			self.remove = true
		end
	end

	function confetti:draw()
		love.graphics.setColor(self.color)
		love.graphics.draw(confettiImage, self.x + confettiImage:getWidth() / 2, (self.y + confettiImage:getWidth() / 2) * scale, self.rotation, scale, scale, confettiImage:getWidth() / 2, confettiImage:getHeight() / 2)
	end

	return confetti
end