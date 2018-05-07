local title = class("title")

function title:load(item)
	self.options = 
	{
		"New Game",
		"Settings",
		"Highscores"
	}

	self.banner = love.graphics.newImage("graphics/title/banner-plain-hi.png")

	self.optionFont = love.graphics.newFont("graphics/upheval.ttf", 80)
	self.copyrightFont = love.graphics.newFont("graphics/upheval.ttf", 40)

	self.arrowImage = love.graphics.newImage("graphics/title/arrow.png")
	self.arrowQuads = {}
	for i = 1, 21 do
		self.arrowQuads[i] = love.graphics.newQuad((i - 1) * 24, 0, 24, 24, self.arrowImage:getWidth(), self.arrowImage:getHeight())
	end
	self.arrowQuad = 1
	self.arrowTimer = 0

	self.optionSelection = item or 1

	titleSong:play()
end

function title:update(dt)
	self.arrowTimer = self.arrowTimer + 16 * dt
	self.arrowQuad = math.floor(self.arrowTimer % 21) + 1
end

function title:draw()
	love.graphics.setColor(1, 1, 1, 1)
	love.graphics.draw(self.banner, (WINDOW_WIDTH - self.banner:getWidth()) / 2, WINDOW_HEIGHT * 0.05)

	love.graphics.setFont(self.copyrightFont)
	love.graphics.print(COPYRIGHT .. " 2018 TurtleP", (WINDOW_WIDTH - self.copyrightFont:getWidth(COPYRIGHT .. " 2018 TurtleP")) / 2, WINDOW_HEIGHT * 0.05 + self.banner:getHeight() + 16)

	love.graphics.setFont(self.optionFont)
	for i = 1, #self.options do
		if self.optionSelection == i then
			love.graphics.draw(self.arrowImage, self.arrowQuads[self.arrowQuad], (WINDOW_WIDTH - self.optionFont:getWidth(self.options[i]:upper())) / 2 - 48 + math.sin(self.arrowTimer / 2) * 6, WINDOW_HEIGHT * 0.62 + (i - 1) * 80 + 28)
		end
		love.graphics.print(self.options[i]:upper(), (WINDOW_WIDTH - self.optionFont:getWidth(self.options[i]:upper())) / 2, WINDOW_HEIGHT * 0.62 + (i - 1) * 80)
	end
end

function title:gamepadpressed(joy, button)
	if joy:getID() ~= 1 then
		return
	end

	if button == "a" then
		if self.optionSelection == 1 then
			state:change("charselect")
		elseif self.optionSelection == 2 then
			state:change("settings")
		else
			state:change("highscores")
		end
	elseif button == "dpdown" then
		self.optionSelection = math.min(self.optionSelection + 1, 3)
	elseif button == "dpup" then
		self.optionSelection = math.max(self.optionSelection - 1, 1)
	end
end

function title:destroy()
	self.options = nil
	self.banner = nil
	self.optionFont = nil
	self.copyrightFont = nil
end

return title