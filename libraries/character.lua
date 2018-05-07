local charloader = class("charloader")

characters = {}
function charloader:initialize()
	local items = love.filesystem.getDirectoryItems(CHAR_DIRECTORY)

	for i = 1, #items do
		characters[i] = self:loadCharacter(CHAR_DIRECTORY, items[i])
	end
end

function charloader:loadCharacter(path, name)
	local character = {}

	local config
	local CONFIG_PATH = path .. "/" .. name .. ".json"
	if love.filesystem.getInfo(CONFIG_PATH) then
		config = json:decode(love.filesystem.read(CONFIG_PATH))
	end

	local graphic = love.graphics.newImage(path .. "/" .. name .. "/ship.png")
	local portrait = love.graphics.newImage(path .. "/" .. name .. "/portrait.png")

	character.name = name
	character.graphic = graphic
	character.portrait = portrait

	character.width = graphic:getWidth()
	character.height = graphic:getHeight()

	return character
end

return charloader:new()