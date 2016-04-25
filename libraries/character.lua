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
	
	gameCharacters[1] = createCharacter("turtle")
	for k = 2, #characters do
		if createCharacter(characters[k]) then
			table.insert(gameCharacters, createCharacter(characters[k]))
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
			elseif util.toBoolean(v[2]) then
				character[v[1]] = util.toBoolean(v[2])
			else
				character[v[1]] = v[2]
			end
		end
		if #dataSplit == 1 then
			return false
		end
	else
		return false
	end

	character.graphic = love.graphics.newImage("characters/" .. name .. "/ship.png")

	character.quads = {}
	if character.animated then
		for k = 1, character.animationframes do
			character.quads[k] = love.graphics.newQuad((k - 1) * character.width, 0, character.width, character.height, character.graphic:getWidth(), character.graphic:getHeight())
		end
	end

	return character
end
