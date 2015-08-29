class "barrier" {
	x, y
}

function barrier:__init(x, w)
	self.x = x
	self.y = 0
	self.width = w
	self.height = love.window.getHeight()
end