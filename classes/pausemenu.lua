class "pausemenu" {}

--this makes my life easier in making the pause menu cool

function pausemenu:__init()
	pausemenu_items = 
	{ 
		main = {"Resume Game", "Game Options", "Quit to Menu", "Quit to Desktop"},
		options = {"Music Volume", "Sound Volume", "Vsync"},
		vars = {"musicvolume", "soundvolume", "vsyncbool"}
	}

	self.maxitems = #pausemenu_items["main"]
	self.optionsitems = 3
	
	self.itemheight = 26*scale
	self.width = 220*scale
	self.height = 46*scale+self.itemheight*self.maxitems
	self.x = ((600 * scale)/2)-self.width/2
	self.y = ((300 * scale)/2)-self.height/2
	
	self.selection = 1
	self.menumove = 0
	self.options = false
	self.selecttimer = 0

	self.state = "main"
end

function pausemenu:update(dt)
	if self.selecttimer > 0 then
		self.selecttimer = math.max(0, self.selecttimer-dt)
	end
end

function pausemenu:draw()
	love.graphics.push()

	love.graphics.setFont(font4)
	love.graphics.setColor(36, 36, 36, 255)
	love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
	love.graphics.setColor(255, 255, 255, 255)
	love.graphics.rectangle("line", self.x, self.y, self.width, self.height)

	love.graphics.print("Game Paused", (self.x+(self.width)/2)-(font4:getWidth("Game Paused")/2), self.y+(16*scale))

	--[[local add = ""
	if self.state == "options" then
		add = tostring(_G[ pausemenu_items["vars"][self.selection] ])
	end

	love.graphics.print("-", self.x + (self.width / 2) - font5:getWidth(pausemenu_items[self.state][self.selection] .. add) / 2 - font4:getWidth("-"), self.y+(50*scale)+((self.selection-1)*self.itemheight))]]

	if self.state == "main" then
		love.graphics.setFont(font5)
		for i, v in ipairs(pausemenu_items["main"]) do
			local x = self.x+10*scale
			love.graphics.setColor(127, 127, 127, 255)
			if self.selection == i then
				love.graphics.setColor(255, 255, 255, 255)
				x = x + math.sin((1-self.selecttimer)*(math.pi/2))*20*scale
			end
			love.graphics.print(v, x, self.y+50*scale+(i-1)*self.itemheight)
		end
	else
		love.graphics.setFont(font5)
		
		for i, var in ipairs(pausemenu_items["vars"]) do
			local v = _G[var]
			
			love.graphics.setColor(127, 127, 127, 255)
			local font = love.graphics.getFont()
			local w = pausemenu_items["options"][i]
			
			local y = self.y+50*scale+(i-1)*self.itemheight
			local x = self.x+10*scale
			if self.selection == i then
				love.graphics.setColor(255, 255, 255, 255)
				x = x + math.sin((1-self.selecttimer)*(math.pi/2))*20*scale
			end
			
			love.graphics.print(w .. ":", x, y)
			if type(v) == "number" then
				local l = love.graphics.getLineWidth()
				love.graphics.setLineWidth(3*scale)
				local volumeSteps = 10
				for j = 1, volumeSteps do
					local x1 = x+font:getWidth(w .. ": ") + (j-1)*5*scale
					local h = font:getHeight()
					local y1 = y+(volumeSteps-j)*(h/volumeSteps)
					
					
					love.graphics.setColor(55, 55, 55, 255)
					if v >= j/volumeSteps and v > 0 then
						love.graphics.setColor(0, 155, 255, 255)
					end
					love.graphics.line(x1, y1, x1, y1+(h/volumeSteps)*j)
				end
			
				love.graphics.setLineWidth(l)
			else
				love.graphics.setColor(55, 55, 55, 255)
				
				local l = love.graphics.getLineWidth()
				love.graphics.setLineWidth(6*scale)
				
				local x1 = x + font:getWidth(w .. ": ") + 3*scale
				local y1 = y + font:getHeight()/2 - 3*scale
				local wd = 12*scale
				
				love.graphics.circle("fill", x1, y1, 3*scale, 8*scale)
				love.graphics.circle("fill", x1 + wd, y1, 3*scale, 8*scale)
				love.graphics.line(x1, y1, x1 + wd, y1)
				
				love.graphics.setLineWidth(3*scale)
				love.graphics.setColor(55, 75, 85, 255)
				
				local off = 0
				if v then
					love.graphics.setColor(0, 155, 255, 255)
					off = wd
				end
				
				love.graphics.circle("line", x1+off, y1, wd/2, 16*scale)
				love.graphics.circle("line", x1+off, y1, wd/2, 16*scale)
				
				love.graphics.setLineWidth(l)
			end
		end
		--[[love.graphics.print("Music Volume: " .. tostring(round( math.clamp(musicvolume, 0, 1) , 2 )), (self.x+(self.width)/2)-(font5:getWidth("Music Volume: " .. tostring(round( math.clamp(musicvolume, 0, 1) , 2 )))/2), self.y+50*scale+(1-1)*self.itemheight)
		love.graphics.print("Sound Volume: " .. tostring(round( math.clamp(soundvolume, 0, 1) , 2 )), (self.x+(self.width)/2)-(font5:getWidth("Sound Volume " .. tostring(round( math.clamp(soundvolume, 0, 1) , 2 )))/2), self.y+50*scale+(2-1)*self.itemheight)
		love.graphics.print("Vsync: " .. tostring(vsyncbool), (self.x+(self.width)/2)-(font5:getWidth("Vsync: " .. tostring(vsyncbool))/2), self.y+50*scale+(3-1)*self.itemheight)
		end]]
	end	

	love.graphics.pop()
end

function pausemenu:movecursor(up, right, enter)
	if up ~= nil then
		if up then
			if self.selection > 1 then
				self.selection = self.selection - 1
				self.selecttimer = 1
			end
		else 
			if self.selection < self.maxitems then
				self.selection = self.selection + 1
				self.selecttimer = 1
			end
		end
	end

	if right ~= nil then
		if right then
			if self.state == "options" then
				if self.selection == 1 then
					changeVolume(false, musicvolume + 0.1)
				elseif self.selection == 2 then
					changeVolume(soundvolume + 0.1)
				else
					vsyncbool = true
				end
			end
		else 
			if self.state == "options" then
				if self.selection == 1 then
					changeVolume(false, musicvolume - 0.1)
				elseif self.selection == 2 then
					changeVolume(soundvolume - 0.1)
				else
					vsyncbool = false
				end
			end
		end
	end

	if enter ~= nil then
		if enter then
			if self.state == "main" then
				if self.selection == 1 then
					checkAudio()
					love.audio.resume()
					paused = false
				elseif self.selection == 2 then
					self.state = "options"
					self.maxitems = 3
					self.selection = 1
					self.selecttimer = 0
				elseif self.selection == 3 then
					menu_load()
				elseif self.selection == 4 then
					love.event.quit()
				end
			end
		elseif not enter then
			if self.state == "main" then
				paused = not paused
				if paused then
					playsound("pause")
				elseif not paused then
					saveData("settings", true)
					checkAudio()
					love.audio.resume()
				end
			else
				self.maxitems = 4
				self.state = "main"
				self.selecttimer = 0
			end
		end
	end
end