class "phantoment" {}

function phantoment:__init(graphic, quad, x, y, t)
	self.graphic = graphic
	self.quad = quad
	self.x = x
	self.y = y
	self.alpha = 255

	self.t = t

	self.color = getPowerColor("none")
	table.insert(self.color, 4, self.alpha)
	self.c = c
end

function phantoment:update(dt)
	self.alpha = math.max(0, self.alpha-120*dt)

	self.color[4] = self.alpha

	if self.alpha <= 0 then
		self.kill = true
	end
end

function phantoment:draw()
	love.graphics.setColor(255, 255, 255, self.alpha)

	if self.quad then
		love.graphics.draw(self.graphic, self.quad, self.x * scale, self.y * scale, 0, scale, scale)
	else 
		love.graphics.draw(self.graphic, self.x * scale, self.y * scale, 0, scale, scale)
		if self.quad then
			love.graphics.setColor(self.c)
			love.graphics.draw(self.quad, self.x * scale, self.y * scale, 0, scale, scale)
			love.graphics.setColor(255, 255, 255, 255)
		end
	end

	if self.t == "bat" then
		love.graphics.setColor(self.color)
		love.graphics.draw(graphics["bateyes"], self.quad, self.x * scale, self.y * scale, 0, scale, scale)
	end

	love.graphics.setColor(255, 255, 255, 255)
end