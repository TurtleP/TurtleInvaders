timer = class("timer")

function timer:initialize(max, callback, condition, ...)
    self.timer = 0
    self.maxTime = max

    self.args = {...}

    self.callback = callback or function()

    end

    self.condition = condition or function()
        return true
    end
end

function timer:update(dt)
    if self.maxTime <= 0 then
        return
    end

    if self.condition(unpack(self.args)) then
        print("yeet")
        self.timer = self.timer + dt
        if self.timer >= self.maxTime then
            self.callback(unpack(self.args))
            self.timer = self.timer - self.maxTime
        end
    end
end

function timer:forceCallback()
    self.callback(unpack(self.args))
end

function timer:reset()
    self.timer = 0
end

function timer:getMaxTime()
    return self.maxTime
end

function timer:setMaxTime(amount)
    self.maxTime = amount
    self:reset()
end

function timer:addMaxTime(amount, dontAllowReset)
    self.maxTime = math.min(self.maxTime + amount, 60)

    if not dontAllowReset then
        self.timer = 0
    end
end
