timer = class("timer")

function timer:initialize(max, callback, condition)
    self.timer = 0
    self.maxTime = max

    self.callback = callback or function() end
    self.condition = condition or function() return true end
end

function timer:update(dt)
    if self.maxTime <= 0 then
        return
    end

    if self.condition() then
        self.timer = self.timer + dt
        if self.timer >= self.maxTime then
            self.callback()
            self.timer = self.timer - self.maxTime
        end
    end
end

function timer:reset()
	self.timer = 0
end

function timer:getMaxTime()
    return self.maxTime
end

function timer:addMaxTime(amount)
    self.maxTime = math.min(self.maxTime + amount, 60)
    self.timer = 0
end