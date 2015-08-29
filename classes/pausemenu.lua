class "pausemenu" {}

--this makes my life easier in making the pause menu cool

function pausemenu:__init()
	pausemenu_items = 
	{ 
		main = {"Resume Game", "Game Options", "Quit to Menu", "Quit to Desktop"},
		options = {"Music Volume: ", "Sound Volume: ", "Vsync: "},
		vars = {"musicvolume", "soundvolume", "vsyncbool"}
	}

	self.maxitems = #pausemenu_items["main"]
	self.optionsitems = 3
	
	self.itemheight = 26*scale
	self.width = 200*scale
	self.height = 46*scale+self.itemheight*self.maxitems
	self.x = ((600 * scale)/2)-self.width/2
	self.y = ((300 * scale)/2)-self.height/2
	
	self.selection = 1
	self.menumove = 0
	self.options = false

	self.state = "main"
end

function pausemenu:update(dt)

end

function pausemenu:draw()
	love.graphics.push()

	love.graphics.setFont(font4)
	love.graphics.setColor(36, 36, 36, 255)
	love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
	love.graphics.setColor(255, 255, 255, 255)
	love.graphics.rectangle("line", self.x, self.y, self.width, self.height)

	love.graphics.print("Game Paused", (self.x+(self.width)/2)-(font4:getWidth("Game Paused")/2), self.y+(16*scale))

	local add = ""
	if self.state == "options" then
		add = tostring(_G[pausemenu_items["vars"][self.selection]])
	end

	love.graphics.print("-", self.x + (self.width / 2) - font5:getWidth(pausemenu_items[self.state][self.selection] .. add) / 2 - font4:getWidth("-"), self.y+(50*scale)+((self.selection-1)*self.itemheight))

	if self.state == "main" then
		love.graphics.setFont(font5)
		
		love.graphics.print("Resume Game", (self.x+(self.width)/2)-(font5:getWidth("Resume Game")/2), 	self.y+50*scale+(1-1)*self.itemheight)
		love.graphics.print("Game Options", (self.x+(self.width)/2)-(font5:getWidth("Game Options")/2), self.y+50*scale+(2-1)*self.itemheight)
		love.graphics.print("Quit to Menu", (self.x+(self.width)/2)-(font5:getWidth("Quit to Menu")/2), self.y+50*scale+(3-1)*self.itemheight)
		love.graphics.print("Quit to Desktop", (self.x+(self.width)/2)-(font5:getWidth("Quit to Desktop")/2), self.y+50*scale+(4-1)*self.itemheight)
	else
		love.graphics.setFont(font5)
		
		love.graphics.print("Music Volume: " .. tostring(musicvolume), (self.x+(self.width)/2)-(font5:getWidth("Music Volume: " .. tostring(musicvolume))/2), self.y+50*scale+(1-1)*self.itemheight)
		love.graphics.print("Sound Volume: " .. tostring(soundvolume), (self.x+(self.width)/2)-(font5:getWidth("Sound Volume " .. tostring(soundvolume))/2), self.y+50*scale+(2-1)*self.itemheight)
		love.graphics.print("Vsync: " .. tostring(vsyncbool), (self.x+(self.width)/2)-(font5:getWidth("Vsync: " .. tostring(vsyncbool))/2), self.y+50*scale+(3-1)*self.itemheight)
	end	

	love.graphics.pop()
end

function pausemenu:movecursor(up, right, enter)
	if up ~= nil then
		if up then
			if self.selection > 1 then
				self.selection = self.selection - 1
			end
		else 
			if self.selection < self.maxitems then
				self.selection = self.selection + 1
			end
		end
	end

	if right ~= nil then
		if right then
			if self.state == "options" then
				if self.selection == 1 then
					changeVolume(false, musicvolume + 0.2)
				elseif self.selection == 2 then
					changeVolume(soundvolume + 0.2)
				else
					vsyncbool = true
				end
			end
		else 
			if self.state == "options" then
				if self.selection == 1 then
					changeVolume(false, musicvolume - 0.2)
				elseif self.selection == 2 then
					changeVolume(soundvolume - 0.2)
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
			end
		end
	end
end