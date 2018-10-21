local frostbullet = class("frostbullet", powerup)

frostbullet.isBullet = true
function frostbullet:initialize(x, y, speed)
	powerup.initialize(self, x, y, 6, 6)
	
	self:setSpeedY(speed)

	self.mask = { false, true, false }
end

function frostbullet:draw()
	love.graphics.setColor(0.259, 0.6474, 0.961)
	love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)

	love.graphics.setColor(1, 1, 1)
end

function frostbullet:floor(name, data)
	if name == "player" then
		local powerups = state:get("powerups")
		data:setPowerup(powerups[2])
	end
end

return frostbullet