powerup = class("powerup")

function powerup:init(x, y, t)
	self.x = x
	self.y = y

	self.width = 18
	self.height = 18

	self.active = true
	self.passive = true

	self.gravity = 0

	self.speedx = 0
	self.speedy = 100

	self.t = self:getType(t)

	self.i = t
end

function powerup:draw()
	love.graphics.setDepth(-0.5)

	love.graphics.draw(powerupImage, powerupQuads[self.i], self.x, self.y)

	love.graphics.setDepth(0)
end

function powerup:getType(i)
	local returnType = "shotgun"

	if i == 2 then
		returnType = "time"
	elseif i == 3 then
		returnType = "shield"
	elseif i == 4 then
		returnType = "laser"
	elseif i == 5 then
		returnType = "freeze"
	elseif i == 6 then
		returnType = "anti"
	elseif i == 7 then
		returnType = "nobullets"
	elseif i == 8 then
		returnType = "nopower"
	elseif i == 9 then
		returnType = "mega"
	elseif i == 10 then
		returnType = "oneup"
	end

	return returnType
end