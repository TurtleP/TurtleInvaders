class "explosion" {
	x, y
}

function explosion:__init(x, y, t)
	self.x = x
	self.y = y
	self.timer = 0
	self.quadno = 1
	self.graphic = explosionimg
	self.quad = explosionquads
	self.kill = false
	self.t = t or "bat"

	if self.t ~= "coon" then
		self.width = 16
		self.height = 16
		self.scale = scale
	else 
		self.width = 48
		self.height = 48
		self.scale = scale+2
	end
	self.oldfont = love.graphics.getFont()
end

function explosion:draw()
	love.graphics.draw(self.graphic, self.quad[self.quadno], self.x*scale, self.y*scale, 0, self.scale, self.scale)
end

function explosion:update(dt)
	if self.quadno < 6 then
		self.timer = math.min(self.timer + 15*dt)
		self.quadno = math.floor(self.timer%6)+1
	else
		self.kill = true
	end

	for k, v in pairs(objects["turtle"]) do
		if CheckCollision(self.x, self.y, self.width, self.height, v.ui.x, v.ui.y, v.ui.width, v.ui.height) then
			v.ui:FadeIn()
		else 
			v.ui:FadeOut()
		end
	end
end