local megacannon = class("megacannon", powerup)

megacannon.time = 10
megacannon.isBullet = true
megacannon.trackPlayer = {true, false}
megacannon.timeoutOnFire = true

local megaLaserImage = love.graphics.newImage("graphics/game/effects/megabeam.png")
local megaLaserQuads = {}
for i = 1, 4 do
    table.insert(megaLaserQuads, love.graphics.newQuad((i - 1) * 66, 0, 66, 66, megaLaserImage:getWidth(), megaLaserImage:getHeight()))
end

local megaLaserBaseImage = love.graphics.newImage("graphics/game/effects/megabase.png")
local megaLaserBaseQuads = {}
for y = 1, 2 do
    for x = 1, 4 do
        table.insert(megaLaserBaseQuads, love.graphics.newQuad((x - 1) * 240, (y - 1) * 240, 240, 240, megaLaserBaseImage:getWidth(), megaLaserBaseImage:getHeight()))
    end
end

local megaLaserBoomImage = love.graphics.newImage("graphics/game/effects/megaboom.png")
local megaLaserBoomQuads = {}
for y = 1, 5 do
    for x = 1, 3 do
        table.insert(megaLaserBoomQuads, love.graphics.newQuad((x - 1) * 240, (y - 1) * 240, 240, 240, megaLaserBaseImage:getWidth(), megaLaserBaseImage:getHeight()))
    end
end

function megacannon:initialize(x, y)
    powerup.initialize(self, nil, x, y, 240, 186)

    self.timer = 0
    self.quadi = vector(1, 1)

    self.shouldTimeout = true
end

function megacannon:update(dt)
    self.timer = self.timer + 10 * dt
    self.quadi.y = math.floor(self.timer % #megaLaserBaseQuads) + 1
    self.quadi.x = math.floor(self.timer % #megaLaserQuads) + 1

    local ret = physics:checkBounds(self.x + (120 - 33), 0, 66, 462, {"enemy"})
    
    for k, v in ipairs(ret) do
        v:die(true)
        state:call("setShakeValue", 10)
    end
end

function megacannon:draw()
    for i = 1, math.floor(self.y / 66) + 1 do
        love.graphics.draw(megaLaserImage, megaLaserQuads[self.quadi.x], self.x + (120 - 33), self.y - (i * 66))
    end
    love.graphics.draw(megaLaserBaseImage, megaLaserBaseQuads[self.quadi.y], self.x, self.y)
end

return megacannon