class "gui" {}

function gui:__init(...)
	args = {...}
	
	self.oldfont = love.graphics.getFont()
	self.t = args[1]
	self.x = args[2]
	self.y = args[3]

	self.oldx = self.x
	self.oldy = self.y
	
	self.hover = false
	self.active = true 
	self.font = font4
	
	if args[1] == "imagebutton" then
		self.width = args[4]
		self.height = args[5]
	
		self.backColor = {255, 255, 255}

		self.hoverColor = {255, 255, 255, 128}
		self.currentColor = self.backColor
		
		if type(args[6]) == "string" then
			self.image = love.graphics.newImage(args[6])
		else 
			self.image = args[6]
		end
		
		self.quad = args[7] or love.graphics.newQuad(0, 0, 16, 16, 16, 16)
		
		self.func = args[8]
		self.args = args[9] or {}
	elseif args[1] == "scrollbar" then
		self.width = args[4]
		self.height = args[5]
	
		self.backColor = {127, 127, 127, 127}
		self.barwidth = args[6]
		self.barheight = args[7]
		
		self.barx = args[2]
		self.bary = args[3]
		self.step = args[8]
		
		self.dragging = false 
		
		self.scrollbarUnhighlight = {0, 0, 0}
		self.scrollbarHighlight = {180, 180, 180}
		self.currentColor = self.scrollbarUnhighlight
		self.value = 0
		
	elseif args[1] == "button" then
		self.width = font4:getWidth(args[4])+4*scale
		self.height = 21*scale
	
		self.text = args[4]
		self.func = args[5]
		self.args = args[6]

		self.textColor = {255, 255, 255}
		self.highlightColor = {255, 255, 255}
		self.unHighlightColor = {200, 200, 200}
		self.backgroundColor = {0, 0, 0}
		
	elseif args[1] == "menu" then
		self.text = args[4] .. ">"
		self.texts = args[5]
		self.open = false
		self.selectioni = 1
		self.timer = 0 
		
		self.width = args[6]
		self.height = args[7]
		
		self.textColor = {0, 0, 0}
		self.itemBackColor = {229, 229, 229, 255}
		self.itemBorderColor = {202, 202, 200, 255}
		self.hoverColor = {127, 127, 127}
		
		self.items = {}
		for k = 1, #self.texts do
			local t = self.texts[k]
			self.items[k] = gui:new("button", self.x, self.y + (k-1) * 11 * scale, t,
			function()
				self.selectioni = k
				self.open = false 
			end, {})
		end
	elseif args[1] == "text" then
		self.text = args[4]
		self.textColor = {0, 0, 0}
		
		self.width = 4*scale*#args[4]
		self.height = 8*scale
	elseif args[1] == "checkbox" then
		self.text = args[4]
		self.checked = args[5]

		self.textColor = {0, 0, 0}
		self.highlightColor = {127, 127, 127}
		self.unHighlightColor = {0, 0, 0}

		self.width = (9*scale)+(8*#self.text)
		self.height = 7*scale
	elseif args[1] == "dropdown" then
		local empty = ""

		for k = 1, args[6] do
			empty = empty .. " "
		end

		self.width = font4:getWidth(empty)+(4*scale)
		self.height = 21*scale

		self.textColor = {255, 255, 255}
		self.highlightColor = {255, 255, 255}
		self.unHighlightColor = {200, 200, 200}
		self.currentColor = unHighlightColor

		self.items = args[4]
		self.func = args[5]

		self.itemi = 1
		self.open = false
		self.maxdelay = 0.2
		self.delay = maxdelay
		self.backgroundColor = {0, 0, 0}
	elseif args[1] == "textfield" then
		self.maxchars = args[4]
		self.text = args[5]

		local empty = ""
		for k = 1, args[4] do
			empty = empty .. " "
		end

		self.fakeText = args[6] or ""

		self.width = font4:getWidth(empty)+2*scale --dat fixed width font doe
		self.height = 21*scale

		self.highlightColor = {255, 255, 255}
		self.unHighlightColor = {200, 200, 200}
		self.backgroundColor = {0, 0, 0}

		self.timer = 0
		self.input = false
		self.drawinput = false
	end
end

function gui:keypressed(key)
	if self.t == "textfield" then
		if self.input then
			if key == "backspace" then
				self.text = self.text:sub(1, -2)
			end
		end
	end
end

function gui:update(dt)
	if not self.active then
		return
	end
	
	if self.t == "scrollbar" then
		if self.barwidth > self.barheight then
			self.bary = self.y 
		else
			self.barx = self.x
		end

		if self.dragging then
			if self.barwidth > self.barheight then
				self.value = (mouse.X()-self.dragging[1]) / (self.dragging[2]-self.dragging[1])
			else
				self.value = (mouse.Y()-self.dragging[1]) / (self.dragging[2]-self.dragging[1])
			end
		end
		
		--Hugo: This all is good to leave outside an "if", since makes itself fixed in any problem with external changes
		self.value = math.max(0, math.min(self.value, 1))
		if self.barwidth > self.barheight then
			self.bary = self.y
			self.barx = math.floor(self.x+(self.value*(self.width-self.barwidth)))
		else
			self.barx = self.x
			self.bary = math.floor(self.y+(self.value*(self.height-self.barheight)))
		end
	elseif self.t == "menu" then
		if self.open then
			self.timer = math.min(self.timer + dt/0.5, 1)
			
			for k = 1, #self.items do
				self.items[k].x = math.min(self.x + ((self.width-1 + self.width/2) - font["gui"]:getWidth(self.items[k]:getText())/2) * self.timer, self.items[k].x + ((self.width-1 + self.width/2) - font["gui"]:getWidth(self.items[k]:getText())/2))
				self.items[k]:update(dt)
			end
		else 
			for k = 1, #self.items do
				self.timer = 0
				self.items[k].x = self.items[k].oldx
			end
		end
	elseif self.t == "dropdown" then
		if self.open then
			self.delay = math.max(self.delay - dt, 0)
		else
			self.delay = self.maxdelay
		end
	elseif self.t == "textfield" then
		if self.input then
			self.timer = self.timer + 2*dt

			if math.floor(self.timer)%2 == 0 then
				self.drawinput = true
			else
				self.drawinput = false
			end
		else
			self.timer = 0
		end
	end
end

function gui:draw()
	if not self.active then
		return
	end

	love.graphics.setFont(self.font)

	if self.t == "imagebutton" then
		love.graphics.setColor(self.currentColor)
		
		if self.quad then
			love.graphics.draw(self.image, self.quad, self.x, self.y, 0, scale, scale)
		else
			love.graphics.draw(self.image, self.x, self.y, 0, scale, scale)
		end
		
		self.hover = self:inHighlight(self.x, self.y, self.width, self.height)
		if self.hover then
			self.currentColor = self.hoverColor
		else
			self.currentColor = self.backColor
		end
		
		love.graphics.setColor(255, 255, 255)
	elseif self.t == "scrollbar" then
		love.graphics.setColor(self.backColor)
		love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
		
		self.hover = self:inHighlight(self.barx, self.bary, self.barwidth, self.barheight)
		if self.hover then
			self.currentColor = self.scrollbarHighlight
		else
			self.currentColor = self.scrollbarUnhighlight
		end
		
		love.graphics.setColor(self.currentColor)
		if self.barwidth > self.barheight then
			love.graphics.rectangle("fill", self.barx, self.y, self.barwidth, self.barheight)
		else
			love.graphics.rectangle("fill", self.x, self.bary, self.barwidth, self.barheight)
		end
		love.graphics.setColor(255, 255, 255)
	elseif self.t == "menu" then
		self.hover = self:inHighlight(self.x, self.y, self.width, self.height)
		
		if self.open then
			love.graphics.setScissor(self.x+self.width-(2*scale), self.y-(2*scale), self.width+(4*scale), (11*scale*#self.items)+(4*scale))
			
			love.graphics.setColor(self.itemBackColor)
			love.graphics.rectangle("fill", self.x + (self.width-(1*scale)) * self.timer, self.y, self.width, 11*scale*#self.items)
			
			for k = 1, #self.items do
				love.graphics.setColor(self.itemBorderColor)
				love.graphics.rectangle("line", self.x + (self.width-(1*scale)) * self.timer, self.y + (k-1)*11*scale, self.width, 11*scale)
			end
			
			for k = 1, #self.items do
				self.items[k]:draw()
			end
			
			love.graphics.setScissor()
		end
		
		love.graphics.setColor(self.textColor)
		if self.hover then
			love.graphics.setColor(self.hoverColor)
		end
		love.graphics.print(self.items[self.selectioni]:getText() .. " >", self.x, self.y)
	elseif self.t == "button" then
		self.hover = self:inHighlight(self.x, self.y, self.width, self.height)
		
		love.graphics.setColor(self.backgroundColor) 
		love.graphics.rectangle("fill", self.x+(1*scale), self.y+(1*scale), self.width-(2*scale), self.height-(2*scale))

		love.graphics.setColor(self.textColor)
		love.graphics.print(self.text, self.x+(self.width/2)-font4:getWidth(self.text)/2, self.y+(2*scale)+(self.height/2)-font4:getHeight(self.text)/2)

		love.graphics.setColor(self.unHighlightColor)
		if self.hover then
			love.graphics.setColor(self.highlightColor)
		end
		love.graphics.rectangle("line", self.x, self.y, self.width, self.height)

	elseif self.t == "text" then
		love.graphics.setColor(self.textColor)
		love.graphics.print(self.text, self.x, self.y)
	elseif self.t == "checkbox" then
		love.graphics.setColor(self.textColor)

		self.hover = self:inHighlight(self.x, self.y, self.width, self.height)
		
		local check = ""
		if self.checked then
			check = "X"
		end

		love.graphics.print(check, self.x+(0.7*scale), self.y-(2*scale))

		local color = self.unHighlightColor
		if self.hover then
			color = self.highlightColor
		end
		love.graphics.setColor(color)
		love.graphics.rectangle("line", self.x, self.y, 6*scale, 6*scale)

		love.graphics.print(self.text, self.x+(9*scale), self.y-(2*scale))
	elseif self.t == "dropdown" then
		self.hover = self:inHighlight(self.x, self.y, self.width, self.height)
		if self.hover then
			self.currentColor = self.highlightColor
		else
			self.currentColor = self.unHighlightColor
		end
		
		love.graphics.setColor(self.currentColor)
		love.graphics.rectangle("line", self.x, self.y, self.width, self.height)

		love.graphics.setColor(self.backgroundColor) 
		love.graphics.rectangle("fill", self.x+(1*scale), self.y+(1*scale), self.width-(2*scale), self.height-(2*scale))

		love.graphics.setColor(255, 255, 255)

		--if not self.open then
		love.graphics.print(self.items[self.itemi], self.x+(2*scale), self.y+(2*scale)+((22*scale)/2)-font4:getHeight(self.items[self.itemi])/2)
			
		if self.open then
			self.height = (#self.items+1)*22*scale
			for k = 1, #self.items do
				love.graphics.setColor(255, 255, 255)

				love.graphics.line(self.x+(2*scale), self.y+(22*scale)+(k-1)*22*scale, self.x+(self.width-2*scale), self.y+(22*scale)+(k-1)*22*scale)

				love.graphics.setColor(127, 127, 127)
				if self:inHighlight(self.x, self.y+(21*scale)+(k-1)*22*scale, self.width, 21*scale) then
					love.graphics.setColor(255, 255, 255)
				end

				love.graphics.print(self.items[k], self.x+(2*scale), self.y+((24*scale)+((22*scale)/2)-font4:getHeight(self.items[k])/2)+(k-1)*22*scale)	
			end
		else
			self.height = 22*scale
		end

		love.graphics.setColor(255, 255, 255)
		love.graphics.draw(graphics["dropdownarrow"], self.x+(self.width)-((2*scale)+graphics["dropdownarrow"]:getWidth()*scale), self.y+((22*scale)/2)+(2*scale)-graphics["dropdownarrow"]:getHeight()*scale, 0, scale, scale)
	elseif self.t == "textfield" then
		self.hover = self:inHighlight(self.x, self.y, self.width, self.height)
		if self.hover then
			self.currentColor = self.highlightColor
		else
			self.currentColor = self.unHighlightColor
		end
		
		love.graphics.setColor(self.currentColor)
		love.graphics.rectangle("line", self.x, self.y, self.width, self.height)

		love.graphics.setColor(self.backgroundColor) 
		love.graphics.rectangle("fill", self.x+(1*scale), self.y+(1*scale), self.width-(2*scale), self.height-(2*scale))

		if self.fakeText and self.text == "" then
			love.graphics.setColor(255, 255, 255, 120)
			love.graphics.print(self.fakeText, self.x+(2*scale), self.y+(2*scale)+(self.height/2)-font4:getHeight(self.text)/2)
		elseif (self.fakeText or self.fakeText == nil) and self.text ~= "" then
			love.graphics.setColor(255, 255, 255)
			love.graphics.print(self.text, self.x+(2*scale), self.y+(2*scale)+(self.height/2)-font4:getHeight(self.text)/2)
		end

		love.graphics.setColor(255, 255, 255)
		if self.drawinput then
			love.graphics.setScissor(self.x, self.y, self.width, self.height)
			love.graphics.print("|", self.x+(2*scale)+font4:getWidth(self.text)+1*scale, self.y+(2*scale)+(self.height/2)-font4:getHeight("|")/2)
			love.graphics.setScissor()
		end
	end

	love.graphics.setColor(255, 255, 255)
end

function gui:getText()
	if self.text and self.t ~= "menu" then
		return self.text 
	elseif self.t == "menu" then
		return self.items[self.selectioni]:getText():gsub(">", "")
	end
end

function gui:setFont(font)
	self.font = font

	if self.t == "button" then
		self.width = font:getWidth(self.text)
		self.height = font:getHeight(self.text)
	end
end

function gui:setTextColor(color)
	if self.textColor then
		self.textColor = color
	end
end

function gui:setHoverColor(color)
	if self.hoverColor then
		self.hoverColor = color
	elseif self.highlightColor then
		self.highlightColor = color
	end
end

function gui:setUnHoverColor(color)
	if self.unHighlightColor then
		self.unHighlightColor = color
	end
end

function gui:textinput(t)
	if self.t == "textfield" then
		if self.input then
			if #self.text < self.maxchars then
				self.text = self.text .. t
			end
		end
	end
end

function gui:mousepressed(x, y, button)
	if not self.active then
		return
	end

	if self.hover and self.t ~= "scrollbar" and self.t ~= "menu" and self.t ~= "checkbox" and self.t ~= "dropdown" and self.t ~= "textfield" then
		if self.args then
			self.func(unpack(self.args))
		else
			self.func()
		end
	elseif self.hover and self.t == "scrollbar" then
		if button == "l" then
			if self.barwidth > self.barheight then
				self.dragging = {self.x+(x-self.barx), self.x+self.width-self.barwidth+(x-self.barx)}
			else
				self.dragging = {self.y+(y-self.bary), self.y+self.height-self.barheight+(y-self.bary)}
			end
		end
	elseif self.t == "menu" then
		if self.open then
			for k = 1, #self.items do
				self.items[k]:mousepressed(x, y, button)
			end
		end
		
		if self.hover then
			self.open = not self.open
		else 
			self.open = false
		end
	elseif self.t == "checkbox" then
		if button == "l" then
			self.checked = not self.checked
		end
	elseif self.t == "dropdown" then
		if button == "l" then
			if self.hover then
				self.open = true
			end

			if self.delay == 0 then
				for k = 1, #self.items do
					if self:inHighlight(self.x, self.y+(21*scale)+(k-1)*22*scale, self.width, 21*scale) then
						self.itemi = k
						self.open = false
					end
				end
				self.open = false

				if self.func then
					self.func()
				end
			end
		end
	elseif self.t == "textfield" then
		if button == "l" then
			if self.hover then
				self.drawinput = true
				self.input = true
			else
				self.drawinput = false
				self.input = false
			end
		end
	end
end

function gui:mousereleased(x, y, button)
	if (self.hover or not self.hover) and self.t == "scrollbar" then
		if button == "l" then
			self.dragging = false
		end
	end
end

function gui:inHighlight(x, y, width, height)
	local mx, my = mouse.X(), mouse.Y()

	return (mx >= x) and (mx <= x + width) and (my >= y) and (my <= y+ height)
end