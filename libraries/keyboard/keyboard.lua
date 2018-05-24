local keyboard = class("keyboard")

local button = require 'libraries.keyboard.button'

local COLOR = {0.871, 0.871, 0.871}
local CURSORCOLOR = {0.208, 0.690, 0.682}

--85x56
local KEYS = 
{
	"1", "2", "3", "4", "5", "6", "7", "8", "9", "0", "-",
	"q", "w", "e", "r", "t", "y", "u", "i", "o", "p", "/", 
	"a", "s", "d", "f", "g", "h", "j", "k", "l", ":", "'",
	"z", "x", "c", "v", "b", "n", "m", ",", ".", "?", "!" 
}

local ROWS = 4
local COLUMNS = 11

function keyboard:initialize(hint, limit, callback)
	self.hint = hint
	self.limit = limit or 30

	self.text = ""
	self.fade = 0

	
	self.x = 0
	self.y = 340
	
	self.width = 1280
	self.height = love.graphics.getHeight() - self.y / 2

	self.buttons = {}
	for x = 1, COLUMNS do
		self.buttons[x] = {}
		for y = 1, ROWS do
			local text = KEYS[COLUMNS * (y - 1) + x]

			if text then
				self.buttons[x][y] = button:new(text, 107 + (x - 1) * 87, self.y + 46 + (y - 1) * 58)
			end
		end
	end

	self.buttons[12] = {}
	for y = 1, 5 do
		self.buttons[12][y] = {}
	end
	
	self.buttons[12][1] = button:new("DEL", 1066, self.y + 46, 106, nil, "button_text")
	self.buttons[12][2] = button:new("RETURN", 1066, self.y + 104, 106, 114, nil, nil, "button_text")
	self.buttons[12][3] = button:new("OK", 1066, self.y + 220, 106, 114, "okay", "general")
	
	self.buttons[1][5] = button:new("SHIFT", 107, self.y + 278, 172, nil, "general", nil, "button_text")
	self.buttons[2][5] = button:new("#+=", 281, self.y + 278, nil, nil, "general", nil, "button_text")
	self.buttons[3][5] = button:new("SPACE", 368, self.y + 278, 694, nil, "general", nil, "button_text")

	self.cursor = {x = 1, y = 1}

	self.font = love.graphics.newFont(24)
	self.smallFont = love.graphics.newFont(14)

	self.textBar = {x = (love.graphics.getWidth() - 512) / 2, y = love.graphics.getHeight() * 0.3}

	self.pushHeight = 0
	self.callback = callback or function() return true end
end

function keyboard:setOpen(value)
	self.open = value
end

function keyboard:isOpen()
	return self.open
end

function keyboard:submit()
	if self.callback(self) then
		self.open = false
	end
end

function keyboard:update(dt)
	if self.open then
		self.pushHeight = math.min(self.pushHeight + (self.height * 2) * dt, self.height)
	else
		self.pushHeight = math.max(self.pushHeight - (self.height * 2) * dt, 0)
	end
end

function keyboard:draw()
	if not self.open then
		return
	end

	love.graphics.push()
	love.graphics.translate(0, self.height - self.pushHeight)

	love.graphics.setColor(0.1, 0.1, 0.1, 0.8)
	love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())

	love.graphics.setColor(COLOR)
	love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)

	for x = 1, #self.buttons do
		for y = 1, #self.buttons[x] do
			local button = self.buttons[x][y]
			
			if button.draw then
				button:draw()
				
				if self.cursor.x == x and self.cursor.y == y then
					love.graphics.setColor(CURSORCOLOR[1], CURSORCOLOR[2], CURSORCOLOR[3], 1 * (math.sin(math.pi * love.timer.getTime() * 2) + 0.5))
					love.graphics.rectangle("line", button.x, button.y, button.width, button.height)
				end
			end
		end
	end

	love.graphics.setFont(self.font)

	
	if self.text == "" then
		love.graphics.setColor(1, 1, 1, 0.5)
		love.graphics.print(self.hint, self.textBar.x, self.textBar.y - self.font:getHeight())
	else
		love.graphics.setColor(1, 1, 1, 1)
		love.graphics.print(self.text, self.textBar.x, self.textBar.y - self.font:getHeight())
	end
	
	love.graphics.setFont(self.smallFont)
	love.graphics.print(#self.text .. "/" .. self.limit, self.textBar.x + (512 - self.smallFont:getWidth(#self.text .. "/" .. self.limit)), self.textBar.y)
	love.graphics.rectangle("fill", self.textBar.x, self.textBar.y, 512, 1)

	love.graphics.pop()
end

function keyboard:gamepadpressed(joystick, button)
	if button == "dpright" then
		if not self:moveCursor(1) then
			self.cursor.x = 12
			self.cursor.y = 3
			return
		end 
		self.cursor.x = math.min(self.cursor.x + 1, 12)
	elseif button == "dpleft" then
		if not self:moveCursor(-1) then
			self.cursor.x = self.cursor.x - 1
			return
		end 
		self.cursor.x = math.max(self.cursor.x - 1, 1)
	elseif button == "dpup" then
		self.cursor.y = math.max(self.cursor.y - 1, 1)
	elseif button == "dpdown" then
		if not self:moveCursor(0, 1) then
			repeat
				self.cursor.y = math.min(self.cursor.y + 1, 5)
				self.cursor.x = math.min(self.cursor.x - 1, 1)
			until self.buttons[self.cursor.x][self.cursor.y] ~= nil
			return
		end 
		self.cursor.y = math.min(self.cursor.y + 1, 5)
	elseif button == "a" then
		if self.buttons[self.cursor.x][self.cursor.y]:getText() then
			self.text = self.text .. self.buttons[self.cursor.x][self.cursor.y]:getText()
		else
			self.buttons[self.cursor.x][self.cursor.y]:doFunction(self)
		end
	end
end

function keyboard:moveCursor(x, y)
	if not y then
		y = 0
	end

	if self.cursor.x + x > 0 and self.cursor.x + x < 13 then
		if self.cursor.y + y > 0 and self.cursor.y + y < 6 then
			if self.buttons[self.cursor.x + x][self.cursor.y + y] then
				return self.buttons[self.cursor.x + x][self.cursor.y + y] ~= nil
			else
				return nil
			end
		end
	end
end

function keyboard:delete()
	if #self.text > 0 then
		self.text = self.text:sub(1, -2)
	end
end

function keyboard:toggleCaps()
	for k, v in pairs(self.buttons) do
		for j, w in pairs(v) do
			if w.isSpecial and not w:isSpecial() then
				w:toggleCaps()
			end
		end
	end
end

return keyboard

