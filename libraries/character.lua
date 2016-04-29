function loadCharacters()
	local characters =
	{
		"turtle",
		"gabe",
		"idiot",
		"hugo",
		"astro",
		"furious",
		"qwerty",
		"saulo",
		"polybius",
		"scuttles"
	}

	table.sort(characters)

	gameCharacters = {}
	
	for k = 1, #characters do
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

	if love.filesystem.isFile("characters/" .. name .. "/" .. character.ability .. ".lua") then
		local abilityFunction = dofile("characters/" .. name .. "/" .. character.ability .. ".lua")
		character.ability = abilityFunction
	end

	character.quads = {}
	if character.animated then
		for k = 1, character.animationframes do
			character.quads[k] = love.graphics.newQuad((k - 1) * character.width, 0, character.width, character.height, character.graphic:getWidth(), character.graphic:getHeight())
		end
	end

	if love.filesystem.isFile("characters/" .. name .. "/shield.png") then
		character.shieldImage = love.graphics.newImage("characters/" .. name .. "/shield.png")

		character.shieldQuads = {}
		if character.shieldcount then
			for k = 1, (character.shieldcount or 2) do
				character.shieldQuads[k] = love.graphics.newQuad((k - 1) * character.shieldwidth, 0, character.shieldwidth, character.shieldheight, character.shieldImage:getWidth(), character.shieldImage:getHeight())
			end
		end
	end

	return character
end
