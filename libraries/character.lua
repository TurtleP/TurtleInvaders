local charloader = class("charloader")

characters = {}
function charloader:initialize()
	local items = love.filesystem.getDirectoryItems(CHAR_DIRECTORY)
	for index, name in ipairs(items) do
		if name:sub(-4) == ".png" then
			table.remove(items, index)
		end
	end

	for i = 1, #items do
		local data = self:loadCharacter(CHAR_DIRECTORY, items[i])

		if data then
			table.insert(characters, data)
		end 
	end
end

function charloader:loadCharacter(path, name)
	local character = {}

	local config = {}
	local CONFIG_PATH = path .. "/" .. name .. "/config"
	if love.filesystem.getInfo(CONFIG_PATH .. ".lua") then
		config = require(CONFIG_PATH)
	end

	local graphic = nil
	if love.filesystem.getInfo(path .. "/" .. name .. "/ship.png") then
		graphic = love.graphics.newImage(path .. "/" .. name .. "/ship.png")
	else
		return false
	end
	
	local portrait = love.graphics.newImage(path .. "/default.png")
	if love.filesystem.getInfo(path .. "/" .. name .. "/portrait.png") then
		portrait = love.graphics.newImage(path .. "/" .. name .. "/portrait.png")
	end

	character.name = name
	character.graphic = graphic
	character.portrait = portrait

	character.width = graphic:getWidth()
	character.height = graphic:getHeight()

	if not config.init then
		return character
	end
	
	for field, value in pairs(config) do
		character[field] = value
	end
	character:init()

	return character
end

return charloader:new()