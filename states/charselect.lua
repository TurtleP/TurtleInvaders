function charSelectInit()
	charSelections = {}
	for x = 1, #gameCharacters do
		charSelections[x] = newCharSelection(20 + math.mod( (x - 1), 5 ) * 60, 20 + math.floor( (x - 1) / 5 ) * 60, x)
	end

	chooseFont = love.graphics.newFont("graphics/monofonto.ttf", 40)
	abilityFont = love.graphics.newFont("graphics/monofonto.ttf", 18)

	currentCharacterSelection = 1
	
	charBats = {}

	charTimer = timer:new(2, function()
		local temp = bat:new(love.math.random(370), -14)
		temp.screen = "top"

		table.insert(charBats, temp)
	end)
end

function charSelectUpdate(dt)
	charTimer:update(dt)

	for k, v in pairs(charBats) do
		local width = 400
		if v.screen == "top" then
			if v.y > util.getHeight() then
				v.x = v.x - 40
				v.y = 0
				v.screen = "bottom"
			end
		else
			width = 320
		end

		if v.y > util.getHeight() or v.x + v.width < 0 or v.x > width then
			table.remove(charBats, k)
		end

		v:update(dt)

		v.x = v.x + v.speedx * dt
		v.y = v.y + v.speedy * dt
	end
end

function charSelectDraw()
	for k, v in pairs(charBats) do
		love.graphics.setScreen(v.screen)

		v:draw()
	end

	love.graphics.setScreen("top")

	love.graphics.setDepth(-INTERFACE_DEPTH)

	for fieldCount = 1, #starFields do
		local v = starFields[fieldCount]

		for k, s in pairs(v) do
			s:draw()
		end
	end

	love.graphics.setFont(chooseFont)
	love.graphics.print("Choose a character", util.getWidth() / 2 - chooseFont:getWidth("Choose a character") / 2, 20)
	love.graphics.line(36, 65, chooseFont:getWidth("Choose a character"), 65)

	if charSelections then
		local selectedCharacter = charSelections[currentCharacterSelection].char
		love.graphics.print(selectedCharacter.name:gsub("^%l", string.upper), util.getWidth() / 2 - chooseFont:getWidth(selectedCharacter.name:gsub("^%l", string.upper)) / 2, 80)

		love.graphics.setFont(abilityFont)

		local description = selectedCharacter.ability.description
		if not description then
			description = "Abilities.. WHAT ARE THOSE?"
		end
		love.graphics.print(description, util.getWidth() / 2 - abilityFont:getWidth(description) / 2, 200)

		if selectedCharacter.animated then
			love.graphics.draw(selectedCharacter.graphic, selectedCharacter.quads[1], util.getWidth() / 2 - selectedCharacter.width / 2, 164 - selectedCharacter.graphic:getHeight() / 2)
		else
			love.graphics.draw(selectedCharacter.graphic, util.getWidth() / 2 - selectedCharacter.width / 2, 164 - selectedCharacter.graphic:getHeight() / 2)
		end
	end
	
	love.graphics.setDepth(NORMAL_DEPTH)

	love.graphics.setScreen("bottom")

	for fieldCount = 1, #starFields do
		local v = starFields[fieldCount]

		for k, s in pairs(v) do
			s:draw()
		end
	end

	for k, v in pairs(charSelections) do
		if currentCharacterSelection == k then
			love.graphics.push()

			love.graphics.translate(40, 240)
			
			local offset = math.floor((math.sin(love.timer.getTime() * math.pi * 2) + 1) / 2 * 3)
			love.graphics.line(v.x - offset, v.y - offset, (v.x + 8) - offset, v.y - offset)
			love.graphics.line(v.x - offset, v.y - offset, v.x - offset, (v.y + 8) - offset)

			love.graphics.line((v.x + v.width - 8) + offset, v.y - offset, (v.x + v.width) + offset, v.y - offset)
			love.graphics.line((v.x + v.width) + offset, v.y - offset, (v.x + v.width) + offset, (v.y + 8) - offset)

			love.graphics.line((v.x + v.width) + offset, (v.y + v.height - 8) + offset, (v.x + v.width) + offset, (v.y + v.height) + offset)
			love.graphics.line((v.x + v.width - 8) + offset, (v.y + v.height) + offset, (v.x + v.width) + offset, (v.y + v.height) + offset)

			offset = math.floor((math.sin(love.timer.getTime() * math.pi * 2) + 1) / 2 * 3)
			love.graphics.line(v.x - offset, (v.y + v.height) + offset, (v.x + 8) - offset, (v.y + v.height) + offset)
			love.graphics.line(v.x - offset, (v.y + v.height - 8) + offset, (v.x - offset), (v.y + v.height) + offset)

			love.graphics.pop()
		end
		v:draw()
	end
end

function charSelectKeyPressed(key)
	if key == "cpadright" then
		currentCharacterSelection = math.min(currentCharacterSelection + 1, #gameCharacters)
	elseif key == "cpadleft" then
		currentCharacterSelection = math.max(currentCharacterSelection - 1, 1)
	elseif key == "a" then
		util.changeState("game", charSelections[currentCharacterSelection].char)
	elseif key == "b" then
		util.changeState("title", 1)
	end
end

function charSelectMousePressed(x, y, button)
	for k, v in pairs(charSelections) do
		if v:mousepressed(x, y, button) then
			currentCharacterSelection = k

			v.taps = v.taps + 1
			if v.taps == 2 then
				util.changeState("game", charSelections[currentCharacterSelection].char)
			end
		else
			v.taps = 0
		end
	end
end

function newCharSelection(x, y, chari)
	local charselect = {}

	charselect.x = x
	charselect.y = y

	charselect.width = 40
	charselect.height = 40

	charselect.char = gameCharacters[chari]

	charselect.taps = 0

	function charselect:draw()
		local character = self.char

		if character.animated then
			love.graphics.draw(character.graphic, character.quads[1], self.x + (self.width / 2) - character.width / 2, self.y + (self.height / 2) - character.height / 2)
			return
		end	
		love.graphics.draw(character.graphic, self.x + (self.width / 2) - character.width / 2, self.y + (self.height / 2) - character.height / 2)
	end

	function charselect:mousepressed(x, y, button)
		return x > self.x and x < self.x + self.width and y > self.y and y < self.y + self.height
	end

	return charselect
end