fizzle = class("fizzle")

function fizzle:init(object, quadType)
	self.x = object.x
	self.y = object.y

	print(self.x, self.y)
	if object.quadi then
		self.quadi = object.quadi

		local graphic, quads = batImage, batQuads[self.quadi][1]
		if quadType == "powerup" then
			graphic = powerupImage
			quads = powerupQuads[self.quadi]
		end
		self.graphic = graphic
		self.quads = quads
	end

	self.width = object.width
	self.height = object.height

	self.fizzleFade = 1

	self.t = quadType
end

function fizzle:update(dt)
	self.fizzleFade = math.max(0, self.fizzleFade - 0.6 * dt)

	if self.fizzleFade == 0 then
		self.remove = true
	end
end

function fizzle:draw()
	love.graphics.setColor(128, 128, 128, 255 * self.fizzleFade)

	if not self.quadi then
		love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
		return
	end
	love.graphics.draw(self.graphic, self.quads, self.x, self.y)

	if self.t == "bat" then
		love.graphics.draw(self.graphic, batQuads[self.quadi][2], self.x, self.y)
	end

	love.graphics.setColor(255, 255, 255, 255)
end