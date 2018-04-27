function creditsInit()
	local text = 
	{
		"A game by TurtleP",
		"",
		"Originally for PC/Mobile",
		"",
		"Programmed with Lua",
		"Made with Love Potion",
		"",
		":: Notes/Thoughts ::",
		"There is a 2 font limit",
		"There's only 44MB of RAM",
		"",
		"Fonts had to be cleared..",
		"..then re-made each state",
		"",
		":: Graphics ::",
		"Jael Clark - Hatninja",
		"HugoBDesigner",
		"Chase6897",
		"Qwertyman",
		"Idiot9.0",
		"Jorichi",
		"Polybius",
		"Renhoek",
		"FuriousHedgehog",
		"Cake",
		"SauloFX",
		"TurretBot"
		"",
		":: Audio ::",
		"Kyle Prior",
		"Saint Happyfaces",
		"",
		":: Testers ::",
		"ihaveamac",
		"Melon Bread",
		"",
		"Find more games at my site:",
		"http://TurtleP.github.io/"
	}

	creditsText = {}
	for k = 1, #text do
		creditsCreateText(text[k])
	end

	logoFont = love.graphics.newFont("graphics/monofonto.ttf", 46)
	mainFont = love.graphics.newFont("graphics/monofonto.ttf", 24)

	creditsY = 240
end

function creditsUpdate(dt)
	for k, v in pairs(creditsText) do
		v[2] = v[2] - 25 * dt
	end
end

function creditsDraw()
	love.graphics.setScreen("top")

	love.graphics.setDepth(-INTERFACE_DEPTH)
	
	love.graphics.setColor(255, 255, 255)

	love.graphics.setFont(logoFont)

	love.graphics.setColor(255, 0, 0)
	love.graphics.print("Turtle:", util.getWidth() / 2 - logoFont:getWidth("Turtle:") / 2, 10)

	love.graphics.setColor(0, 255, 0)
	love.graphics.print("Invaders", util.getWidth() / 2 - logoFont:getWidth("Invaders") / 2, 50)

	love.graphics.setColor(255, 255, 255)

	love.graphics.setFont(mainFont)

	for k = 1, #creditsText do
		if creditsText[k][2] < 0 and creditsText[k][3] == "bottom" then
			creditsText[k][3] = "top"
			creditsText[k][2] = 240
		end
		
		if creditsText[k][3] == "top" then
			love.graphics.setScreen("top")

			love.graphics.setScissor(0, 140, 400, 100)
		else
			love.graphics.setScreen("bottom")
		end

		love.graphics.print(creditsText[k][1], util.getWidth() / 2 - mainFont:getWidth(creditsText[k][1]) / 2, creditsText[k][2])

		if love.graphics.getScreen() == "top" then
			love.graphics.setScissor()
		end
	end
end

function creditsKeyPressed(key)
	util.changeState("options")
end

function creditsCreateText(text)
	table.insert(creditsText, {text, 240 + (#creditsText - 1) * 30, "bottom"})
end
