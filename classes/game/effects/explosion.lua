explosion = class("explosion", entity)

local explosionImage = love.graphics.newImage("graphics/game/effects/explosion.png")
local explosionQuads = {}
for i = 1, 6 do
    explosionQuads[i] = love.graphics.newQuad((i - 1) * 48, 0, 48, 48, explosionImage:getWidth(), explosionImage:getHeight())
end

local explosionSound = love.audio.newSource("audio/explode.ogg", "static")

function explosion:initialize(x, y)
    entity.initialize(self, x, y, 48, 48)

    self.timer = 0
    self.quadi = 1

    explosionSound:play()

    physics:pushEntity(self, 3)
end

function explosion:update(dt)
    if self.quadi < #explosionQuads then
        self.timer = self.timer + 8 * dt
        self.quadi = math.floor(self.timer % 6) + 1
    else
        self.remove = true
    end
end

function explosion:draw()
    love.graphics.draw(explosionImage, explosionQuads[self.quadi], self.x, self.y)
end