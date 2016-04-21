--[[
	FOR NINTENDO 3DS ONLY

	You may use this for -Love Potion- only!
	This is to allow filesystem calls to be made
	without the need to understand io operation.

	Only works for Love Potion 1.0.8

	TurtleP
--]]

if not love.filesystem then
	love.filesystem = {}

	function love.filesystem.isFile(path)
		return io.open(path)
	end

	function love.filesystem.isDirectory(path)
		return love.filesystem.isFile(path):read(1) == 21
	end
	
	function love.filesystem.write(path, data)
		if path and data then
			local file = io.open(path, "w")

			if file then
				file:write(data)

				file:flush()

				file:close()
			else
				error("Could not create file!")
			end
		else
			error("Could not write file: " .. path .. "!")
		end
	end

	function love.filesystem.read(path)
		if path then
			local file = io.open(path, "r")

			if file then
				return file:read()
			else
				error("Could not read file, does not exist!")
			end
		else
			assert(type(path) == "string", "String expected, got " .. type(path))
		end
	end

	function love.filesystem.remove(path)
		if path then
			os.remove(path)
		end
	end

	local function fsize(file)
		local startf = file:seek("start")

		local sizeof = file:seek("end")

		file:seek("set", startf)

		return sizeof
	end

	function love.filesystem.getDirectoryItems(path)
		if type(path) ~= "string" then
			error("String expected, got " .. type(path))
		else
			if love.filesystem.isDirectory(path) then

			end
		end
	end

	function love.filesystem.loadFile(path)
		local path = path
		if _EMULATEHOMEBREW then
			return love.filesystem.load(path)()
		end
		return dofile(path)
	end
end

if not love.graphics.scale then
	function love.graphics.scale(scalarX, scalarY)
		--do nothing
	end
end

if not love.graphics.setDefaultFilter then
	function love.graphics.setDefaultFilter(min, max) 
		--do nothing
	end
end

if not love.audio.setVolume then
	function love.audio.setVolume(volume)
		--do nothing
	end
end

if not love.math then
	love.math = {}

	function love.math.random(...)
		return math.random(...)
	end
end