--[[
	Directional Pad Input

	Makes a D-Pad which is awesome
--]]

class "dinput" {}

function dinput:__init(keys)
	
	local scale = getFullScale() --should work
	
	self.x = 10

	self.y = (love.window.getHeight() / scale) - 160

	self.width = 45
	self.height = 45

	self.areas =
	{
		{x = self.x + self.width, y = self.y, width = self.width, height = self.height},
		{x = self.x + (self.width * 2), y = self.y + self.height, width = self.width, height = self.height },
		{x = self.x + self.width, y = self.y + (self.height * 2), width = self.width, height = self.height},
		{x = self.x, y = self.y + self.height, width = self.width, height = self.height}
	}

	self.keys = {unpack(keys)}

	self.graphic = love.graphics.newImage("gfx/android/dpad.png")

	self.pressedGraphic = love.graphics.newImage("gfx/android/dpadpressed.png")

	dpadquads = {}

	for y = 1, 2 do
		for x = 1, 2 do
			table.insert( dpadquads, love.graphics.newQuad((x - 1)*135, (y-1)*135, 135, 135, self.pressedGraphic:getWidth(), self.pressedGraphic:getHeight()) )
		end
	end

	self.pressed = 0
	self.id = 0
end

function dinput:setID(id)
	self.id = id + 1
end

function dinput:draw()
	love.graphics.setColor(255, 255, 255, 200)

	love.graphics.push()

	if state == "game" and not paused then
		love.graphics.setScissor(self.x * scale, (self.y + self.height) * scale, (self.width * 3) * scale, self.height * scale) 
	end

	if self.pressed > 0 then
		love.graphics.draw(self.pressedGraphic, dpadquads[self.pressed], self.x * scale, self.y * scale, 0, scale, scale)
	else
		love.graphics.draw(self.graphic, self.x * scale, self.y * scale, 0, scale, scale)
	end

	if state == "game" and not paused then
		love.graphics.setScissor() 
	end

	love.graphics.pop()
end

function dinput:touchPressed(id, x, y, pressure)
	for k = 1, #self.areas do
		local v = self.areas[k]

		if CheckCollision(v.x, v.y, v.width, v.height, x / scale, y / scale, 8, 8) then
			self.pressed = k

			self:setID(id)

			love.keypressed(self.keys[k])
		end
	end
end

function dinput:touchReleased(id, x, y, pressure)
	if self.pressed > 0 then
		if id + 1 == self.id then

			love.keyreleased(self.keys[self.pressed])

			self.pressed = 0
		end
	end
end