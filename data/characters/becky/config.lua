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
	end,

	update = function(self, dt)
		self.timer = self.timer + 3 * dt
		self.quad = math.floor(self.timer % #self.quads) + 1
	end,

	draw = function(self)
		love.graphics.draw(self.graphic, self.quads[self.quad], self.x, self.y)
	end
}