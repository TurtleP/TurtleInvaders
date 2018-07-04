roulette = class("roulette")

local powerupsImage = love.graphics.newImage("graphics/game/ui/powerups.png")
local powerupsQuads = {}
for i = 1, powerupsImage:getWidth() / 32 do
    powerupsQuads[i] = love.graphics.newQuad((i - 1) * 32, 0, 32, 32, powerupsImage:getWidth(), powerupsImage:getHeight())
end

function roulette:initialize(data, x, y)
    self.data = data

    self.index = 1
    self.cycles = 0
    self.maxCycles = 20
    self.finalStop = self.maxCycles + 3
    self.lifeTime = -1

    self.timer = timer:new(0.075, function(self)
        if self.cycles < self.finalStop then
            local lastIndex = self.index

            repeat
                self.index = love.math.random(1, #self.data)
            until self.index ~= lastIndex

            self.cycles = self.cycles + 1
            if self.cycles >= self.maxCycles then
                self.timer:addMaxTime(0.3, true)
            end
        else
            local player = state:get("player")
            
            if player:getPowerup() then
                return
            end

            player:setPowerup(self.data[self.index])
        end
    end, nil, self)

    self.x = x
    self.y = y
end

function roulette:update(dt)
    self.timer:update(dt)
end

function roulette:draw()
    love.graphics.draw(powerupsImage, powerupsQuads[self.index], self.x, self.y)
end