return
{
	init = function(self)
		self.shieldQuads = {}
        for i = 1, 8 do
            self.shieldQuads[i] = love.graphics.newQuad((i - 1) * 102, 0, 102, 102, 816, 102)
        end

        self.shieldTimer = 0
        self.shieldRate = 8
		self.shieldQuadi = 1
		
		self.shieldSize = vector(self.width, self.height)
	end,

	shieldUpdate = function(self, dt)
		if self.shieldQuadi < #self.shieldQuads then
			self.shieldTimer = self.shieldTimer + self.shieldRate * dt
			self.shieldQuadi = math.floor(self.shieldTimer % #self.shieldQuads) + 1
		end
    end,

	shieldDraw = function(self)
		local center = self:getCenter()
		local x = center.x - 51
		local y = center.y - 51

        love.graphics.draw(self.shield, self.shieldQuads[self.shieldQuadi], x, y)
    end
}