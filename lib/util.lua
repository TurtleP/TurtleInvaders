util = 
{
	VERSION = "1.0_CONDENSED",
	DESC = "A library made by Jeremy Postelnek just for the sake of making life easier. This version is taken from a future game, Super Block Dude, but there's only two functions I needed, so yeah.",
	AUTHOR = "Jeremy Postelnek"
}

--[[
	*simpleTimer
	@param delay The time it takes to fire the function
	@param funct The function to fire after the delay
	Useful .. for something? I used it for the player death in Block dude. Slow death animation. Then respawned.
--]]

timers = {}
function util.simpleTimer(delay, funct)
	table.insert(timers, {time = delay, func = funct})
end

--[[
	*updateTimers
	@param dt The time passed (aka Delta Time)
	Updates all timers, and fires their function when it is at 0. Then removes it.
--]]

function util.updateTimers(dt)
	if #timers > 0 then
		for k = 1, #timers do
			if timers[k] then
				if timers[k].time > 0 then
					timers[k].time = timers[k].time - dt
				else
					timers[k].func()
					table.remove(timers, k)
				end
			end
		end
	end
end

function util.fancyBox(screenX, screenY, w, h, divisor, colorIn, colorBorder, text, font)

	local fancyBox = {}

	fancyBox.timer = 0

	fancyBox.maxWidth = w
	fancyBox.maxHeight = h

	fancyBox.x = 0
	fancyBox.y = 0
	fancyBox.width = 0
	fancyBox.height = 0

	fancyBox.screenX = screenX
	fancyBox.screenY = screenY
	fancyBox.divisor = divisor or 3

	fancyBox.colorIn = colorIn or {32, 32, 32}
	fancyBox.colorBorder = colorBorder or {255, 255, 255}

	fancyBox.text = text
	fancyBox.func = func
	fancyBox.maxTimer = 1

	fancyBox.doneMax = false 
	fancyBox.shouldOpen = true
	fancyBox.openUp = true
	fancyBox.font = font

	function fancyBox:update(dt)
		if not self.shouldOpen then
			return
		end

		self.x = self.screenX-(self.maxWidth*self.timer)/2
		self.y = self.screenY-(self.maxHeight*self.timer)/2
		self.width = self.maxWidth*self.timer
		self.height = self.maxHeight*self.timer

		if self.openUp then
			self.timer = math.min(self.timer + dt / self.divisor, 1)
		else
			self.timer = math.max(self.timer - dt / self.divisor, 0)
		end

		if self.timer == self.maxTimer then
			if not self.doneMax then
				self:onMax()
				self.doneMax = true
			end
		end
	end

	function fancyBox:draw()
		love.graphics.setScissor(self.x * scale, self.y * scale, self.width * scale, self.height * scale)

		love.graphics.setFont(self.font)
		
		love.graphics.setColor(self.colorIn)
		love.graphics.rectangle("fill", self.x * scale, self.y * scale, self.width * scale, self.height * scale)

		love.graphics.setColor(self.colorBorder)
		love.graphics.rectangle("line", self.x * scale, self.y * scale, self.width * scale, self.height * scale)

		if self.text then
			love.graphics.printf(self.text, self.x * scale + 4 * scale, self.y * scale + 18 * scale, (self.maxWidth - 8) * scale, "center")
		end

		love.graphics.setScissor()
	end

	function fancyBox:onMax()
		--yay callback thing
	end

	function fancyBox:setOpen(open)
		self.openUp = open
	end

	function fancyBox:setShouldOpen(open)
		self.shouldOpen = open
	end

	return fancyBox

end