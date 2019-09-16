display = class("display")

local healthImage = love.graphics.newImage("graphics/game/health.png")
local healthQuads = {}
for i = 1, 2 do
    healthQuads[i] = love.graphics.newQuad((i - 1) * 28, 0, 28, 26, healthImage:getWidth(), healthImage:getHeight())
end

function display:initialize(entity)
    self.entity = entity
end

function display:draw()
    local Health = self.entity:get(Components.Health)

    love.graphics.setFont(Fonts.HUD)

    love.graphics.setColor(1, 1, 1, 0.75)
    love.graphics.print(self.entity.name:upper(), 10 * _env.SCALE, 10 * _env.SCALE)

    for i = 1, Health:GetMax() do
        local quad = healthQuads[1]
        if i > Health:GetAmount() then
            quad = healthQuads[2]
        end
        love.graphics.draw(healthImage, quad, (10 + (i - 1) * 16) * _env.SCALE, 31.5 * _env.SCALE)
    end
end
