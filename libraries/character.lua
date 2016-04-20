function loadCharacters()
	local characters =
	{
		"turtle",
		"gabe",
		"idiot9.0",
		"hugo",
		"astronomic",
		"furious",
		"qwerty",
		"saulo",
		"polybius"
	}

	gameCharacters = {}
	for k = 1, #characters do
		if createCharacter(characters[k]) then
			gameCharacters[k] = createCharacter(characters[k])
		else
			print("Error: Could not load: " .. characters[k])
		end
	end
end

function createCharacter(name)
	local character = {}

	if love.filesystem.isFile("characters/" .. name .. "/data.txt") then
		character.name = name

		local data = love.filesystem.read("characters/" .. name .. "/data.txt")

		local dataSplit = data:split(";")

		for k = 1, #dataSplit do
			local v = dataSplit[k]:split(":")

			if tonumber(v[2]) then
				character[v[1]] = tonumber(v[2])
			else
				character[v[1]] = v[2]
			end
		end
	else
		return false
	end

	character.graphic = love.graphics.newImage("characters/" .. name .. "/ship.png")
	
	character.width = character.graphic:getWidth()
	character.height = character.graphic:getHeight()

	return character
end
