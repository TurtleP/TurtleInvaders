function loadingInit(loadState, ...)
	loadingBati = 1
	loadingBatTimer = 0

	--clear the fonts anyways
	util.clearFonts()

	loadingDuration = 1

	loadingState = loadState

	loadingArg = {...}
end

function loadingUpdate(dt)
	loadingBatTimer = loadingBatTimer + 8 * dt
	loadingBati = math.floor(loadingBatTimer % 3) + 1

	if loadingDuration > 0 then
		loadingDuration = loadingDuration - dt
	else
		util.changeState(loadingState, unpack(loadingArg))
	end
end

function loadingDraw()
	love.graphics.setScreen("top")

	love.graphics.draw(batImage, batQuads[loadingBati][2], util.getWidth() - 32, (util.getHeight() - 28) + math.sin(love.timer.getTime() * 2) * 4)
	love.graphics.draw(batImage, batQuads[loadingBati][1], util.getWidth() - 32, (util.getHeight() - 28) + math.sin(love.timer.getTime() * 2) * 4)
end