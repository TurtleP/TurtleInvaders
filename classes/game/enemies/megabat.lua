megabat = class("megabat", boss)

local megaBatImage = love.graphics.newImage("graphics/game/enemies/boss.png")
local megaBatQuads = {}
for x = 1, 3 do
    megaBatQuads[x] = love.graphics.newQuad((x - 1) * 176, 0, 176, 90, megaBatImage:getWidth(), megaBatImage:getHeight())
end

function megabat:initialize()
    self.image = megaBatImage
    self.quads = megaBatQuads

    boss.initialize(self, (1280 - 176) / 2, 720 * (1 / 3), 176, 90, 6)

    self.shootTimer = timer:new(math.random(1, 2), function(self)
        self:shoot()
        self.shootTimer:setMaxTime(math.random(0.03, 0.08))
    end, nil, self)
end

function megabat:update(dt)
    boss.update(self, dt)

    if self.health > 0 then
        if self:getHealth() < self:getMaxHealth() / 2 then
            self.shootTimer:update(dt)
        end
    end
end

function megabat:shoot()
    local center = self:getCenter()

    local bullets = 
    {
        {
            bullet:new(self.x, self.y + self.height + 6, {-300, 600}),
            bullet:new(self.x + self.width, self.y + self.height + 6, {300, 600})
        },

        {
            bullet:new(center.x - 3, self.y + self.height + 6, {0, 600}),
        }
    }

    local rand = love.math.random(1, 2)

    for i = 1, #bullets[rand] do
        physics:pushEntity(bullets[rand][i], 2)
    end
end