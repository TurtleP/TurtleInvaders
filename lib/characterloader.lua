characterloader = {}

characters = {}

function characterloader:loadchar(name)
	local folder = "characters/" .. name .. "/"
	if not love.filesystem.exists(folder .. "ship.png") then
		return false
	end

	local lfs = love.filesystem

	local char = {}

	char.graphic = love.graphics.newImage(folder .. "ship.png")
	
	char.name = name:lower()
	char.width = char.graphic:getWidth()
	char.height = char.graphic:getHeight()

	--set vars BEFORE THINGS HAPPEN AGH
	char.shieldAnimSpeed = 0.25
	char.shieldInSpeed = 0.25
	char.shieldOutSpeed = 0.25
	char.isAnimated = false
	char.animationQuad = 1
	char.animationQuads = {}
	char.animationTimer = 0
	char.animationSpeed = 0.25
	if love.filesystem.exists(folder .. "data.txt") then
		local t = love.filesystem.read(folder .. "data.txt")
		local lua = JSON:decode(t)

		for k, v in pairs(lua) do
			local var, val = k, v
			
			if var == "shieldanimspeed" and tonumber(val) and tonumber(val) > 0 then
				char.shieldAnimSpeed = tonumber(val)
			elseif var == "shieldinspeed" and tonumber(val) and tonumber(val) > 0 then
				char.shieldInSpeed = tonumber(val)
			elseif var == "shieldoutspeed" and tonumber(val) and tonumber(val) > 0 then
				char.shieldOutSpeed = tonumber(val)
			elseif var == "animated" and val == true then
				char.isAnimated = true
			elseif var == "animationspeed" and tonumber(val) and tonumber(val) > 0 then
				char.animationSpeed = tonumber(val)
			elseif var == "animationframes" and tonumber(val) and tonumber(val) > 0 and math.mod(tonumber(val), 1) == 0 then
				char.width = char.graphic:getWidth()/tonumber(val)
				for i = 1, tonumber(val) do
					table.insert(char.animationQuads, love.graphics.newQuad((i-1)*char.width, 0, char.width, char.graphic:getHeight(), char.graphic:getWidth(), char.graphic:getHeight()))
				end
			elseif var == "name" then
				char.name = val:lower()
			elseif var == "ability" then
				assert(love.filesystem.exists("script/" .. val .. ".lua"), "Ability type " .. val .. " does not exist!")
				char.ability = love.filesystem.load("script/" .. val .. ".lua")()
			elseif var == "shieldwidth" then
				char.shieldwidth = val
			elseif var == "shieldheight" then
				char.shieldheight = val
			elseif var == "shieldquadcount" then
				char.shieldquadcount = val
			elseif var == "shieldincount" then
				char.shieldinquadcount = val
			elseif var == "shieldinwidth" then
				char.shieldinwidth = val
			elseif var == "shieldinheight" then
				char.shieldinheight = val
			elseif var == "shieldoutcount" then
				char.shieldoutquadcount = val
			elseif var == "shieldoutwidth" then
				char.shieldoutwidth = val
			elseif var == "shieldoutheight" then
				char.shieldoutheight = val
			elseif var == "width" then
			--	if char.isAnimated then
					char.width = val
			--	end
			elseif var == "height" then
			--	if char.isAnimated then
					char.height = val
			--	end
			end
		end
	end

	if lfs.exists(folder .. "shield.png") then
		char.shieldimg = love.graphics.newImage(folder .. "shield.png")

		if char.shieldquadcount then
			char.shieldquads = {}
			for i = 1, char.shieldquadcount do
				char.shieldquads[i] = love.graphics.newQuad((i-1)*char.shieldwidth, 0, char.shieldwidth, char.shieldheight, char.shieldimg:getWidth(), char.shieldimg:getHeight())
			end
		end
	end
	
	if lfs.exists(folder .. "shield-in.png") then
		char.shieldin = love.graphics.newImage(folder .. "shield-in.png")
		char.shieldinquads = {}
		
		if char.shieldinquadcount then
			for i = 1, char.shieldinquadcount do
				char.shieldinquads[i] = love.graphics.newQuad((i-1)*char.shieldinwidth, 0, char.shieldinwidth, char.shieldinheight, char.shieldin:getWidth(), char.shieldin:getHeight())
			end
		end
	end
	
	if lfs.exists(folder .. "shield-out.png") then
		char.shieldout = love.graphics.newImage(folder .. "shield-out.png")
		char.shieldoutquads = {}
		
		if char.shieldoutquadcount then
			for i = 1, char.shieldoutquadcount do
				char.shieldoutquads[i] = love.graphics.newQuad((i-1)*char.shieldoutwidth, 0, char.shieldoutwidth, char.shieldoutheight, char.shieldout:getWidth(), char.shieldout:getHeight())
			end
		end
	end

	if not char.isAnimated and (char.graphic:getWidth() > 40 or char.graphic:getHeight() > 40 or char.graphic:getWidth() < 15 or char.graphic:getHeight() < 15) then
		return
	end

	return char
end

function characterloader:loadChars()
	local v = love.filesystem.getDirectoryItems("characters/")
	
	local lfs = love.filesystem
	
	--Hugo: Had to put this here, otherwise it'd constantly repeat already-loaded characters
	gamechars = {}

	for k = #v, 1, -1 do
		if v[k] == "turtle" then
			table.remove(v, k)
		end
	end

	gamechars[1] = "turtle"

	characters["turtle"] = self:loadchar("turtle")
	
	for j = 1, #v do
		if lfs.isDirectory("characters/" .. v[j]) then
			local try = self:loadchar(v[j])
			if try then
				characters[v[j]] = try
				table.insert(gamechars, v[j])
			end
		end
	end

	debugLoadTime("characters")
end