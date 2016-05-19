keyboard = class("keyboard")

local keys = 
{
	"1", "2", "3", "4", "5", "6", "7", "8", "9", "0", "-", "BS",
	"q", "w", "e", "r", "t", "y", "u", "i", "o", "p", "RT", "",
	"a", "s", "d", "f", "g", "h", "j", "k", "l", "'", "=", "/",
	"z", "x", "c", "v", "b", "n", "m", ",", ".", "?", "!", "ST",
}

function keyboard:init(hint, max)
	self.text = ""

	self.hint = hint or ""

	self.x = 0
	self.y = 0

	self.width = 320
	self.height = 240

	self.buttons = {}
	for k = 1, #keys do
		self.buttons[k] = keyboardkey:new(self.x + math.mod(k - 1, 12) * 26, (self.y + 50) + math.floor((k - 1) / 12) * 26, keys[k])
	end

	self.maxChars = max or 10

	self.fade = 0
	
	self.enabled = false
end

function keyboard:update(dt)
	if self.enabled then
		self.fade = math.min(self.fade + 0.8 * dt, 1)
	else
		self.fade = math.max(self.fade - 0.8 * dt, 0)
	end
	
	for k, v in pairs(self.buttons) do
		v:update(dt)
	end
end

function keyboard:open()
	keyboardOpenSound:play()
	self.enabled = true
end

function keyboard:setHint(text)
	self.hint = text
end

function keyboard:setMaxChars(max)
	self.maxChars = max
end

function keyboard:close()
	keyboardCloseSound:play()
	self.enabled = false
end

function keyboard:isOpen()
	return self.enabled
end

function keyboard:clear()
	self.text = ""
end

function keyboard:draw()
	if #self.text == 0 then
		love.graphics.setColor(160, 160, 160, 255 * self.fade)
		
		love.graphics.print(self.hint, self.x + 2, self.y)
	else
		love.graphics.setColor(255, 255, 255, 255 * self.fade)
		
		love.graphics.print(self.text, self.x + 2, self.y)
	end
	
	love.graphics.setColor(255, 255, 255, 255 * self.fade)
	
	love.graphics.push()

	love.graphics.translate(40, 240)

	for x = 1, 26 do
		love.graphics.line(self.x + 5 + (x - 1) * 12, self.y + mainFont:getHeight(), self.x + 10 + (x - 1) * 12, self.y + mainFont:getHeight())
	end

	love.graphics.pop()

	for k, v in pairs(self.buttons) do
		v:draw(self.fade)
	end

	love.graphics.setColor(255, 255, 255, 255)
end

function keyboard:getText()
	return self.text
end

function keyboard:mousepressed(x, y, button)
	if self.fade ~= 1 then
		return
	end
	
	for k, v in pairs(self.buttons) do
		if v:mousepressed(x, y, button) then
			v.pressed = true
			if v.text == "BS" then
				self.text = self.text:sub(1, -2)
				return
			elseif v.text == "ST" then
				for i, s in pairs(self.buttons) do
					if not s.specialKey then
						s:toggleShift()
					end
				end
				return
			elseif v.text == "RT" then
				if self.onReturn then
					self.onReturn()
				end
				self:clear()
				return
			end

			if #self.text < self.maxChars then
				keyboardSound:play()

				self.text = self.text .. v.text
			end
		end
	end
end

keyboardkey = class("keyboardkey")

function keyboardkey:init(x, y, t)
	self.x = x
	self.y = y

	self.width = 26
	self.height = 26

	self.text = t

	self.shifted = false
	self.specialKey = false

	if t == "BS" or t == "ST" or t == "RT" then
		self.specialKey = true
	end

	self.pressed = false
	self.fadeTimer = 0
end

function keyboardkey:update(dt)
	if self.pressed then
		if self.fadeTimer < 1 then
			self.fadeTimer = self.fadeTimer + dt
		else
			self.pressed = false
			self.fadeTimer = 0
		end
	end
end

function keyboardkey:draw(fade)
	if not self.pressed then
		love.graphics.setColor(255, 255, 255, 255 * fade)
	end
	
	if self.pressed then
		love.graphics.setColor(unpack(util.colorFade(self.fadeTimer, 1, {255, 0, 0}, {255, 255, 255})))
	end

	love.graphics.print(self.text, (self.x + self.width / 2) - mainFont:getWidth(self.text) / 2, (self.y + self.height / 2) - mainFont:getHeight() / 2)

	if self.pressed then
		love.graphics.setColor(255, 255, 255, 255)
	end
end

function keyboardkey:mousepressed(x, y, button)
	return x > self.x and x < self.x + self.width and y > self.y and y < self.y + self.height
end

function keyboardkey:toggleShift()
	self.shifted = not self.shifted

	local text = self.text
	if self.shifted then
		self.text = self.text:upper()
	else
		self.text = self.text:lower()
	end
end