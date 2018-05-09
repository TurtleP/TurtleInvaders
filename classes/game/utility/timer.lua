timer = class("timer")

function timer:initialize(max, callback)
	self.timer = 0
	self.maxTime = max

	self.callback = callback or function() end
end

function timer:update(dt)
	if self.maxTime <= 0 then
		return
	end

	self.timer = self.timer + dt
	if self.timer >= self.maxTime then
		self.callback()
		self.timer = self.timer - self.maxTime
	end
end