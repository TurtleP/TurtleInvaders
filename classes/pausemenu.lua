pausemenu = class("pausemenu")

function pausemenu:init()
	self.options = 
	{
		{"Continue", 
			function() 
				paused = false 
			end
		},
		{"Exit to Title", 
			function() 
				util.changeState("title") 
			end
		},
		{"Quit to Home",
			function()
				love.event.quit()
			end
		},
	}

	self.selection = 1
end

function pausemenu:draw()
	local x, y, w, h = 128, 71, 144, 98

	love.graphics.setFont(pauseFont)

	love.graphics.print("Game Paused", x + (w / 2) - pauseFont:getWidth("Game Paused") / 2, y)

	for k = 1, #self.options do
		local v = self.options[k]
		if self.selection == k then
			love.graphics.setColor(255, 255, 255)
		else
			love.graphics.setColor(128, 128, 128)
		end

		love.graphics.print(v[1], x + (w / 2) - pauseFont:getWidth(v[1]) / 2, (y + 28) + (k - 1) * 22)
	end

	love.graphics.setColor(255, 255, 255)
end

function pausemenu:keyPressed(key)
	if key == "cpaddown" or key == "down" then
		self.selection = math.min(self.selection + 1, #self.options)
	elseif key == "cpadup" or key == "up" then
		self.selection = math.max(self.selection - 1, 1)
	elseif key == "a" then
		self.options[self.selection][2]()
	elseif key == "b" then
		paused = false
	end
end