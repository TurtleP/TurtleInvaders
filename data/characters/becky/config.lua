return
{
    width = 120,
    height = 120,

    init = function(self)
        self.quads = {}
        for i = 1, 3 do
            self.quads[i] = love.graphics.newQuad((i - 1) * 120, 0, 120, 120, 360, 120)
        end

        self.timer = 0
        self.quad = 1

        self.shieldQuads = {}
        for i = 1, 4 do
            self.shieldQuads[i] = love.graphics.newQuad((i - 1) * 132, 0, 132, 132, 528, 132)
        end

        self.shieldTimer = 0
        self.shieldRate = 8
        self.shieldQuadi = 1

        self.shieldSize = vector(132, 132)
    end,

    shieldUpdate = function(self, dt)
        self.shieldTimer = self.shieldTimer + self.shieldRate * dt
        self.shieldQuadi = math.floor(self.shieldTimer % #self.shieldQuads) + 1
    end,

    shieldDraw = function(self)
        local center = self:getCenter()

        local x = center.x - (self.shieldSize.x / 2)
        local y = center.y - (self.shieldSize.y / 2)

        love.graphics.draw(self.shield, self.shieldQuads[self.shieldQuadi], x, y)
    end,

    animate = function(self, dt)
        self.timer = self.timer + 3 * dt
        self.quad = math.floor(self.timer % #self.quads) + 1
    end,

    render = function(self)
        love.graphics.draw(self.graphic, self.quads[self.quad], self.x, self.y)
    end
}