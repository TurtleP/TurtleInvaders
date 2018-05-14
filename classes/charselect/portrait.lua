local portrait = class("portrait")

function portrait:initialize(character, x, y)
	self.character = character

	self.x = x
	self.y = y

	self.width = 96
	self.height = 96
end

function portrait:draw(font)
	love.graphics.draw(self.character.portrait, self.x, self.y)
	love.graphics.print(self.character.name, self.x + (self.width / 2) - font:getWidth(self.character.name) / 2, self.y + self.height)
end

function portrait:getGraphic()
	return self.character.graphic
end

function portrait:getCharacterName()
	return self.character.name
end

return portrait