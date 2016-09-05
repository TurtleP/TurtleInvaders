function winInit()
	smallFont = love.graphics.newFont("graphics/monofonto.ttf", 28 * scale)
	headerFont = love.graphics.newFont("graphics/monofonto.ttf", 36 * scale)

	--clientScores = {{"", 200, love.math.random(#gameCharacters)}, {"ayylmao", 1000, love.math.random(#gameCharacters)}, {"", 420, love.math.random(#gameCharacters)}}
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

	rivalsFade = 0

	rivalsFireworkDelay = 0
	rivalsFireworkMaxTime = 0
	rivalsFireworks = {}
end

function winUpdate(dt)
	for i = #rivalsFireworks, 1, -1 do
		if rivalsFireworks[i].remove then
			table.remove(rivalsFireworks, i)
		end
	end

	for k, v in pairs(rivalsFireworks) do
		v:update(dt)
	end

	if rivalsFireworkMaxTime < 8 then
		if rivalsFireworkDelay < 0.2 then
			rivalsFireworkDelay = rivalsFireworkDelay + dt
		else
			table.insert(rivalsFireworks, explosion:new(love.math.random((util.getWidth() / scale) * 0.25, (util.getWidth() / scale) * 0.75), love.math.random((util.getHeight() / scale) * 0.25, (util.getHeight() / scale) * 0.50)))
			rivalsFireworkDelay = 0
		end
		rivalsFireworkMaxTime = rivalsFireworkMaxTime + dt
	else
		rivalsFade = math.min(rivalsFade + 0.4 * dt, 1)
		if rivalsFade == 1 then
			util.changeState("highscore")
			rivalsFireworkMaxTime = 0
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
	
	for k, v in pairs(rivalsFireworks) do
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