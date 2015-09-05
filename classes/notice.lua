class "notice" {
	t = ""
}

notices = {}

function notice:__init(text, isWarn, maxtime)
	self.width = font3:getWidth(text) + 6 * scale
	self.height = font3:getHeight(text) + 6 * scale
	self.x = 0
	self.y = 0-font3:getHeight(text)
	self.timer = 0
	self.maxtime = maxtime or 2
	self.offset = 0
	self.text = text
	self.stateoldfont = love.graphics.getFont()
	self.triggered = false
	self.start = self.y
	if isWarn then
		self.fontcolor = {240, 56, 56}
	else 
		self.fontcolor = {255, 255, 255}
	end

	table.insert(notices, self)
end

function notice:getPos()
	for i = #notices, 1, -1 do
		if notices[i] == self then
			return i
		end
	end
end

function notice:remove()
	for i = #notices, 1, -1 do
		if notices[i] == self then
			table.remove(notices, i)
		end
	end
end 

function notice:draw()
	love.graphics.push()

	love.graphics.translate(0, self.offset)

	love.graphics.setColor(32, 32, 32, 192)

	love.graphics.rectangle("fill", self.x * scale, self.y * scale, font3:getWidth(self.text), font3:getHeight(self.text) + 2 * scale)

	love.graphics.setColor(255, 255, 255)

	love.graphics.rectangle("line", self.x * scale, self.y * scale, font3:getWidth(self.text), font3:getHeight(self.text) + 2 * scale)

	--love.graphics.draw(graphics["prompt"], self.x, self.y, 0, scale, scale)

	love.graphics.setFont(font3)

	love.graphics.setColor(self.fontcolor)

	love.graphics.print(self.text, self.x, (self.y + 3) * scale) -- font3:getHeight(self.text) / 2)

	love.graphics.pop()

	--love.graphics.setFont(self.stateoldfont)
end

function notice:update(dt)
	self.timer = self.timer + dt
	if self.y < 0 and not self.triggered then
		self.y = math.min(self.y + 90*dt, self.height)
	else 
		self.triggered = true
	end
	
	if self.triggered then
		if self.timer > 4 then
			if self.y+self.height+self.offset > self.start*scale then
				self.y = self.y - 90*dt
			else 
				self:remove()
			end
		end
	end

	if not self.dontinsert then
		if self:getPos() ~= #notices and notices[self:getPos()] and notices[self:getPos()+1] then
			self.offset = math.floor(notices[self:getPos()+1].y+notices[self:getPos()+1].height+notices[self:getPos()+1].offset+3*scale)
		end
	end
end