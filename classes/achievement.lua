achievement = class("achievement")

function achievement:init(index, niceName)
	self.index = index

	self.unlocked = false
	self.display = false

	self.title = niceName
	self.reverse = false
	self.fade = 1
end

function achievement:update(dt)
	if not self.display then
		return
	end

	self.fade = math.max(self.fade - dt / 2, 0)
end

function achievement:draw()
	if not self.display then
		return
	end
	
	local x, y = (love.graphics.getWidth() / scale) / 2 - achievementUnlockedImage:getWidth() / 2, (love.graphics.getHeight() / scale) / 2 + achievementUnlockedImage:getHeight()

	love.graphics.setColor(255, 255, 255, 255 * self.fade)
	love.graphics.draw(achievementUnlockedImage, x, y)

	love.graphics.setFont(achievementFont)
	love.graphics.print(self.title, (x + achievementUnlockedImage:getWidth() / 2) - achievementFont:getWidth(self.title) / 2, y + achievementFont:getHeight())
end

function achievement:unlock(display)
	if self.unlocked then
		return
	end

	self.unlocked = true
		
	if not display then
		return
	end

	self.display = true

	saveSettings()
end