raccoon = class("raccoon", boss)

local raccoonImage = love.graphics.newImage("graphics/game/enemies/raccoon.png")
local raccoonQuads = {}
for x = 1, 2 do
    raccoonQuads[x] = love.graphics.newQuad((x - 1) * 132, 0, 132, 156, raccoonImage:getWidth(), raccoonImage:getHeight())
end

function raccoon:initialize()
    self.image = raccoonImage
    self.quads = raccoonQuads

    self.float = true
    boss.initialize(self, (1280 - 132) / 2, 720 * (1 / 3), 132, 156, 8)

    self.shootTimer = timer:new(math.random(1, 2), function(self)
        self:shoot()
        self.shootTimer:setMaxTime(math.random(2, 3))
    end, nil, self)
end

function raccoon:update(dt)
    boss.update(self, dt)
    if self.health > 0 then
        self.shootTimer:update(dt)
    end
end

function raccoon:shoot()
    local center = self:getCenter()

    local bullets = 
    {
        {
            rocket:new(self.x, self.y - 12, {-300, -150}),
            rocket:new(self.x + self.width, self.y - 12, {300, -150})
        },

        {
            rocket:new(center.x - 3, self.y - 12, {0, -150}),
        }
    }

    local rand = love.math.random(1, 2)

    for i = 1, #bullets[rand] do
        physics:pushEntity(bullets[rand][i], 2)
    end
end