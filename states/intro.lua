function intro_load()
	state = "intro"

	updateBox = util.fancyBox(300, 150, 300, 120, 0.25, nil, nil, "An update for Turtle: Invaders is available. Would you like to download the update?")

	updateBox.onMax = function()
		laterButton = gui:new("button", (updateBox.x + 30) * scale, (updateBox.y + updateBox.maxHeight) * scale - 30 * scale, "Later", function() updatePrompt = false end)
		laterButton:setUnHoverColor({255, 0, 0})

		confirmButton = gui:new("button", (updateBox.x + updateBox.maxWidth - 100) * scale, (updateBox.y + updateBox.maxHeight) * scale - 30 * scale, "Okay", function() love.system.openURL(updateURL) updatePrompt = false end)
		confirmButton:setUnHoverColor({0, 255, 0})
	end
	
	updatePrompt = true
end

function intro_update(dt)
	if newVersion and updatePrompt then
		updateBox:update(dt)
		return
	end
end

function intro_draw()

	if newVersion and updatePrompt then
		updateBox:draw()

		if laterButton then
			laterButton:draw()
			confirmButton:draw()
		end

		return
	end
end

function intro_mousepressed(x, y, b)
	if newVersion and updatePrompt then

		if laterButton then
			laterButton:mousepressed(x, y, b)
			confirmButton:mousepressed(x, y, b)
		end
		return
	end
end