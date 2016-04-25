function charSelectInit()
	charSelections = {}
	for x = 1, #gameCharacters do
		charSelections[x] = newCharSelection(20 + (x - 1) * 60, 20, x)
	end

	chooseFont = love.graphics.newFont("graphics/monofonto.ttf", 40)
	abilityFont = love.graphics.newFont("graphics/monofonto.ttf", 16)

	currentSelection = 1
end

function charSelectUpdate(dt)
	
end

function charSelectDraw()
	if charChangingState then
		return
	end

	love.graphics.setScreen("top")

	love.graphics.setFont(chooseFont)
	love.graphics.print("Choose a character", util.getWidth() / 2 - chooseFont:getWidth("Choose a character") / 2, 20)

	local selectedCharacter = charSelections[currentSelection].char
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

	love.graphics.setScreen("bottom")

	for k, v in pairs(charSelections) do
		if currentSelection == k then
			love.graphics.draw(cursorImage, v.x, v.y)
		end
		v:draw()
	end
end

function charSelectKeyPressed(key)
	if key == "cpadright" then
		currentSelection = math.min(currentSelection + 1, #gameCharacters)
	elseif key == "cpadleft" then
		currentSelection = math.max(currentSelection - 1, 1)
	elseif key == "a" then
		util.changeState("loading", "game", charSelections[currentSelection].char)
	end
end

function newCharSelection(x, y, chari)
	local charselect = {}

	charselect.x = x
	charselect.y = y

	charselect.width = 40
	charselect.height = 40

	charselect.char = gameCharacters[chari]

	function charselect:draw()
		local character = self.char

		if character.animated then
			love.graphics.draw(character.graphic, character.quads[1], self.x + (self.width / 2) - character.width / 2, self.y + (self.height / 2) - character.height / 2)
			return
		end	
		love.graphics.draw(character.graphic, self.x + (self.width / 2) - character.width / 2, self.y + (self.height / 2) - character.height / 2)
	end

	return charselect
end