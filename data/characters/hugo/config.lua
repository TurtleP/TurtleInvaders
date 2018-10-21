return
{
    width = 120,
    height = 84,

    init = function(self)
        self.quads = {}
        for i = 1, 12 do
            self.quads[i] = love.graphics.newQuad((i - 1) * 120, 0, 120, 84, 120*12, self.height)
        end

        self.timer = 0
        self.quad = 1
    end,

    animate = function(self, dt)
        self.timer = self.timer + 6 * dt
        self.quad = math.floor(self.timer % 12) + 1
    end,

    render = function(self)
        love.graphics.draw(self.graphic, self.quads[self.quad], self.x, self.y)
    end
}