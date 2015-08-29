local ability = {}

ability.name = "portal"
ability.description = "Shoots portals to the side of the screen. Players can use these to travel long distances quickly."

function ability:init(turtle)
	self.gunimage = love.graphics.newImage("characters/hugo/guns.png")
	
	self.gunquads = {}
	for i = 1, 8 do
		table.insert(self.gunquads, love.graphics.newQuad(0, (i-1)*(self.gunimage:getHeight()/8), self.gunimage:getWidth(), self.gunimage:getHeight()/8, self.gunimage:getWidth(), self.gunimage:getHeight()))
	end
		
	self.portalimage = love.graphics.newImage("characters/hugo/portal.png")
	self.portalgrad = love.graphics.newImage("characters/hugo/portalgrad.png")
	self.shooting = love.graphics.newImage("characters/hugo/shooting.png")
	self.portalColors = {{0, 128, 255, 255}, {255, 128, 0, 255}}

	self.portals = {timer = 0, maxtime = {gun = .5, firing = .25, opening = .25, closing = .25}, anim = "gun", glow = 0, maxglow = .5}
	
	--[[	There will be 4 animations for my character (Hugo):
			 - "gun": popping-up guns and charging portals
			 - "firing": firing the actual portals
			 - "opening": opening portals
			 - "closing": closing portals
	]]

	self.parent = turtle
	self.width = turtle.width
	self.height = turtle.height

	self.passive = false
end

local oldTurtleCheck = turtle.checkBarriers
local oldTurtleDraw = turtle.draw

function ability:update(dt)
	if self.portals.anim == "gun" and self.portals.timer == 0 then
		self.portals.timer = self.portals.maxtime[self.portals.anim]
	end

	if self.portals.anim == "opening" then
		self.portals.glow = math.max(0, self.portals.glow-dt)
		if self.portals.glow == 0 then
			self.portals.glow = self.portals.maxglow
		end
	end
		
	if self.portals.timer > 0 then
		self.portals.timer = math.max(self.portals.timer - dt, 0)
		if self.portals.timer == 0 then
			if self.portals.anim == "gun" then
				self.portals.anim = "firing"
				self.portals.timer = self.portals.maxtime[self.portals.anim]
			elseif self.portals.anim == "firing" then
				self.portals.anim = "opening"
				self.portals.timer = self.portals.maxtime[self.portals.anim]
				self.portals.glow = self.portals.maxglow
			elseif self.portals.anim == "closing" then
				self.portals.anim = "gun"
				self.portals.glow = self.portals.maxglow
			end
		end
	end
	
	if self.portals.timer/self.portals.maxtime[self.portals.anim] <= 0 and self.portals.anim ~= "closing" and self.portals.anim ~= "gun" and self.portals.anim ~= "opening" and self.portals.anim ~= "firing" then
		self.portals.anim = "closing"
		self.portals.timer = self.portals.maxtime[self.portals.anim]
	end

	if self.parent.ui.poweruptimer > 0 then
		turtle.checkBarriers = function(self)
			if self.x < -self.width/2 then
				self.x = 600+self.x
			elseif self.x+self.width/2 > 600 then
				self.x = self.x - 600
			end
		end
	else
		turtle.checkBarriers = oldTurtleCheck
		turtle.draw = oldTurtleDraw
	end
end

function ability:reset()
	turtle.checkBarriers = oldTurtleCheck
end

function ability:draw()
	if self.portals.timer > 0 and self.portals.anim == "gun" then
		local quad = math.floor((self.portals.maxtime[self.portals.anim]-self.portals.timer)/self.portals.maxtime[self.portals.anim]*(#self.gunquads))+1
		love.graphics.draw(self.gunimage, self.gunquads[quad], (self.parent.x+self.width/2-self.gunimage:getWidth()/2)*scale, (self.parent.y+self.height/2-self.gunimage:getHeight()/(#self.gunquads)/2)*scale, 0, scale, scale)
	else
		if self.portals.anim == "firing" then
			local x1 = (self.portals.timer/self.portals.maxtime[self.portals.anim])*((self.parent.x+self.width/2)-self.width/2)
			local x2 = ((self.parent.x+self.width/2)+self.shooting:getWidth())+(1-self.portals.timer/self.portals.maxtime[self.portals.anim])*(love.window.getWidth()/scale-(self.parent.x+self.width/2))
				
			love.graphics.setColor(self.portalColors[1])
			love.graphics.draw(self.shooting, x1*scale, (self.parent.y+self.height/2-self.shooting:getHeight()/2)*scale, 0, scale, scale)
			love.graphics.setColor(self.portalColors[2])
			love.graphics.draw(self.shooting, x2*scale-self.shooting:getWidth()*scale, (self.parent.y+self.height/2-self.shooting:getHeight()/2)*scale, 0, -scale, scale)
		end
			
		turtle.draw = function(self)
			love.graphics.setColor(255, 255, 255, 255*self.invis)
			if self.isAnimated then
				love.graphics.draw(self.img, self.animationQuads[self.animationQuad], self.x*scale, self.y*scale, 0, scale, scale)
				if self.x < 0 then
					love.graphics.draw(self.img, self.animationQuads[self.animationQuad], self.x*scale+600*scale, self.y*scale, 0, scale, scale)
				elseif self.x+self.width > 600 * scale then
					love.graphics.draw(self.img, self.animationQuads[self.animationQuad], self.x*scale-600*scale, self.y*scale, 0, scale, scale)
				end
			else
				love.graphics.draw(self.img, self.x*scale, self.y*scale, 0, scale, scale)
				if self.x < 0 then
					love.graphics.draw(self.img, self.x*scale+600*scale, self.y*scale, 0, scale, scale)
				elseif self.x+self.width > 600 * scale then
					love.graphics.draw(self.img, self.x*scale-600*scale, self.y*scale, 0, scale, scale)
				end
			end
		end
				
		if self.portals.anim == "opening" then
			local fact = 1-(self.portals.timer/self.portals.maxtime[self.portals.anim])
			local fact2 = self.portals.glow/self.portals.maxglow
				
			--First portal, opening
			love.graphics.setColor(self.portalColors[1][1], self.portalColors[1][2], self.portalColors[1][3], math.max(55, 55+100*math.sin(fact2*math.pi)))
			love.graphics.draw(self.portalgrad, 0, (self.parent.y+self.height/2-self.portalgrad:getHeight()*fact/2)*scale, 0, scale, scale*fact)
			love.graphics.setColor(self.portalColors[1])
			love.graphics.draw(self.portalimage, 0, (self.parent.y+self.height/2-self.portalimage:getHeight()*fact/2)*scale, 0, scale, scale*fact)
				
			--Second portal, opening
			love.graphics.setColor(self.portalColors[2][1], self.portalColors[2][2], self.portalColors[2][3], math.max(55, 55+100*math.sin(fact2*math.pi)))
			love.graphics.draw(self.portalgrad, 600 * scale, (self.parent.y+self.height/2-self.portalgrad:getHeight()*fact/2)*scale, 0, -scale, scale*fact)
			love.graphics.setColor(self.portalColors[2])
			love.graphics.draw(self.portalimage, 600 * scale, (self.parent.y+self.height/2-self.portalimage:getHeight()*fact/2)*scale, 0, -scale, scale*fact)
		end
	end

	if self.portals.anim == "closing" then
		local fact = self.portals.timer/self.portals.maxtime[self.portals.anim]
		local fact2 = self.portals.glow/self.portals.maxglow
			
		--First portal, closing
		love.graphics.setColor(self.portalColors[1][1], self.portalColors[1][2], self.portalColors[1][3], math.max(55, 55+100*math.sin(fact2*math.pi)))
		love.graphics.draw(self.portalgrad, 0, (self.parent.y+self.height/2-self.portalgrad:getHeight()*fact/2)*scale, 0, scale, scale*fact)
		love.graphics.setColor(self.portalColors[1])
		love.graphics.draw(self.portalimage, 0, (self.parent.y+self.height/2-self.portalimage:getHeight()*fact/2)*scale, 0, scale, scale*fact)
			
		--Second portal, closing
		love.graphics.setColor(self.portalColors[2][1], self.portalColors[2][2], self.portalColors[2][3], math.max(55, 55+100*math.sin(fact2*math.pi)))
		love.graphics.draw(self.portalgrad, 600 * scale, (self.parent.y+self.height/2-self.portalgrad:getHeight()*fact/2)*scale, 0, -scale, scale*fact)
		love.graphics.setColor(self.portalColors[2])
		love.graphics.draw(self.portalimage, 600 * scale, (self.parent.y+self.height/2-self.portalimage:getHeight()*fact/2)*scale, 0, -scale, scale*fact)
	end
end

return ability