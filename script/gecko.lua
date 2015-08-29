local ability = {}

ability.name = "gecko"
ability.description = "Turns invisible (transparent) for the duration..  I guess"

function ability:init(parent)
	self.parent = parent
end

local oldTurtleDraw = turtle.draw
function ability:draw()
	turtle.draw = function(self)
		if self.name == "scuttles" then
			self.xspeed = 260

			love.graphics.setColor(255, 255, 255, 100)
			love.graphics.draw(self.img, self.x * scale, self.y * scale, 0, scale, scale)
			love.graphics.setColor(255, 255, 255)
		else
			oldTurtleDraw(self)
		end
	end
end

local oldTurtleOnCollide = turtle.onCollide
turtle.onCollide = function(self, name, data)
	if self.name == "scuttles" and self.powerup == "special" then
		return
	end

	oldTurtleOnCollide(self, name, data)
end

function ability:reset()
	turtle.draw = oldTurtleDraw
	self.parent.xspeed = 200
	turtle.onCollide = oldTurtleOnCollide
end

return ability

