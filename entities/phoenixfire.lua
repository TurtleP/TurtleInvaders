class "phoenixfire" {
   x = 0, y = 0
}

function phoenixfire:__init(x, y, r, speedx, speedy, offX, offY)
	self.x = x
	self.y = y 
	self.width = 16
	self.height = 16

	self.rotation = r 
	self.speedx = speedx
	self.speedy = speedy
	self.animationtimer = 0
	self.quadno = 1
	self.graphic = graphics["fireballs"]
	self.quad = fireballquads
   	self.offsetX = offX or 0
  	self.offsetY = offY or 0

  	self.emancipateCheck = true
end

function phoenixfire:drawself()
	love.graphics.setColor(255, 255, 255)
	love.graphics.draw(self.graphic, self.quad[self.quadno], self.x * scale, self.y * scale, self.rotation, scale, scale, self.offsetX, self.offsetY)
	love.graphics.setColor(255, 255, 255)
end

function phoenixfire:update(dt)
   self.x = self.x + self.speedx*dt
   self.y = self.y + self.speedy*dt
   self.animationtimer = math.min(self.animationtimer+12*dt)
   self.quadno = math.floor(self.animationtimer%2)+1
   
   for i, v in pairs(objects.turtle) do
		if CheckCollision(self.x,self.y,self.width,self.height,v.x,v.y, v.width, v.height) then
			if v.powerup ~= "shield" then
				v:addLife(-1)
			end
			self.kill = true
		end
	end

	for k, v in pairs(objects["turtle"]) do
		if CheckCollision(self.x, self.y, self.width, self.height, v.ui.x, v.ui.y, v.ui.width, v.ui.height) then
			v.ui:FadeIn()
		else 
			v.ui:FadeOut()
		end
	end
end