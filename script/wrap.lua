local ability = {}
ability.passive = true

ability.name = "Wrap"
ability.description = "Able to wrap around the screen"

function ability:init(parent)
	self.parent = parent
end

local oldCollCheck = turtle.checkBarriers
function ability:update(dt)
	turtle.checkBarriers = function(self)
		if self.name ~= "gabe" then
			oldCollCheck(self)
		else
			if self.x < -self.width/2 then
				self.x = 600+self.x
			elseif self.x+self.width/2 > 600 then
				self.x = self.x - 600
			end
		end
	end
end

function ability:reset()
	turtle.checkBarriers = oldCollCheck
end


local oldTurtleDraw = turtle.draw
function ability:draw()
	turtle.draw = function (self)
		if self.name ~= "gabe" then
			oldTurtleDraw(self)
		else
			love.graphics.setColor(255, 255, 255, 255*self.invis)
			
			love.graphics.draw(self.img, self.x*scale, self.y*scale, 0, scale, scale)
			if self.x < 0 then
				love.graphics.draw(self.img, self.x*scale+600*scale, self.y*scale, 0, scale, scale)
			elseif self.x+self.width > 600 * scale then
				love.graphics.draw(self.img, self.x*scale-600*scale, self.y*scale, 0, scale, scale)
			end
		end
	end
end

return ability