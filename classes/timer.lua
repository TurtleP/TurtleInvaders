timer = class("timer")

function timer:init(time, callback)
	self.time = 0
	self.maxTime = time

	self.callback = callback
end

function timer:update(dt)
	if self.time < self.maxTime then
		self.time = self.time + dt
	else
		self.time = self.time - self.maxTime
		self.callback()
	end
end