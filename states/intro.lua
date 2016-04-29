local bubbles = {}

function introInit()
	introTurtleFade = 1
	introPotionFade = 0

	introTimer = 0

	warningMessage =
	{
		"This game auto saves.",
		"Do not turn off the power",
		"when you see this icon",
		"between screens.",
		"",
		"3D Mode is supported."
	}

	introBatQuadi = 1
	introBatTimer = 0

	mainFont = love.graphics.newFont("graphics/monofonto.ttf", 32)
	warningFont = love.graphics.newFont("graphics/monofonto.ttf", 24)
end

function introUpdate(dt)
	introTimer = introTimer + dt
	if introTimer > 1 and introTimer < 4 then
		introTurtleFade = math.max(introTurtleFade - 0.6 * dt, 0)
		introPotionFade = math.min(introPotionFade + 0.6 * dt, 1)
	end

	if introTimer > 6 then
		util.changeState("title", 1)
		introTimer = 0
	elseif introTimer > 4 then
		introPotionFade = math.max(introPotionFade - 0.6 * dt, 0)
	end

	if love.math.random(10) == 1 then
		createBubble()
	end

	for k, v in pairs(bubbles) do
		v:update(dt)
	end

	introBatTimer = introBatTimer + 8 * dt
	introBatQuadi = math.floor(introBatTimer % 3) + 1
end

function introDraw()
	love.graphics.setScreen("top")

	love.graphics.setDepth(-INTERFACE_DEPTH)

	love.graphics.setColor(255, 255, 255, 255 * introTurtleFade)
	love.graphics.draw(introImage, util.getWidth() / 2 - introImage:getWidth() / 2, util.getHeight() / 2 - introImage:getHeight() )

	love.graphics.setFont(mainFont)
	love.graphics.print("A game by TurtleP", util.getWidth() / 2 - mainFont:getWidth("A game by TurtleP") / 2, util.getHeight() / 2 + mainFont:getHeight() / 2)

	love.graphics.setColor(255, 255, 255, 255 * introPotionFade)

	for k, v in pairs(bubbles) do
		v:draw()
	end

	love.graphics.setDepth(NORMAL_DEPTH)

	love.graphics.draw(potionImage, util.getWidth() / 2 - potionImage:getWidth() / 2, util.getHeight() / 2 - potionImage:getHeight() / 2)

	love.graphics.setScreen("bottom")

	love.graphics.setColor(255, 255, 255, 255)

	love.graphics.setColor(255, 0, 0)

	love.graphics.print("Warning", util.getWidth() / 2 - mainFont:getWidth("Warning") / 2, 20)

	love.graphics.setColor(255, 255, 255)

	love.graphics.setFont(warningFont)

	for y = 1, #warningMessage do
		local v = warningMessage[y]
		love.graphics.print(v, util.getWidth() / 2 - warningFont:getWidth(v) / 2, 65 + (y - 1) * 24)
	end

	love.graphics.draw(batImage, batQuads[introBatQuadi][2], util.getWidth() / 2 - 16, 170)
	love.graphics.draw(batImage, batQuads[introBatQuadi][1], util.getWidth() / 2 - 16, 170)
end

function skipIntro()
	if introTimer > 0.5 then
		util.changeState("title")
	end
end

function createBubble()
	local newBubble = {x = 0, y = 0, speed = 0, size = 0, states = {'bottom', 'top'}}

	newBubble.speed = math.random(50, 125)
	newBubble.size = 32
	newBubble.x = math.random(-400, 400)
	newBubble.y = love.graphics.getHeight() + newBubble.size
	newBubble.img = love.graphics.newImage("graphics/intro/bubble.png")

	function newBubble:update(dt)
		self.y = self.y - self.speed * dt
	end

	function newBubble:draw()
		love.graphics.draw(self.img, self.x, self.y)
	end

	table.insert(bubbles, newBubble)
end