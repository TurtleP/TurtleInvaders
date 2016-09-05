function lobbyInit(playerID, playerNick)
	if not charSelections then
		charSelections = {}
		for x = 1, #gameCharacters do
			charSelections[x] = newCharSelection((love.graphics.getWidth() / scale) / 2 - 170 + (math.mod( (x - 1), 6 ) * 60), ((love.graphics.getHeight() / scale) * 0.57) - 60 + math.floor( (x - 1) / 6 ) * 60, x)
		end
	end

	if not lobbyCursors then
		lobbyCursors = {}
		lobbyCharacters = {}
	end
	
	chooseFont = love.graphics.newFont("graphics/monofonto.ttf", 40 * scale)
	mainFont = love.graphics.newFont("graphics/monofonto.ttf", 18 * scale)
	countDownFont = love.graphics.newFont("graphics/monofonto.ttf", 24 * scale)
	
	myLobbyID = playerID
	currentLobbySelection = playerID
	lobbyCursors[playerID] = newCursor(playerID)
	
	playerCursorColors =
	{
		{255, 55, 0},
		{0, 55, 255},
		{255, 205, 0},
		{55, 255, 9}
	}

	lobbyCountDown = false
	lobbyTimer = 3
	lobbyFade = 0

	chatLog = {}

	chatText = ""
	chatState = false

	lobbyInputFade = 0
end

function lobbyUpdate(dt)
	if lobbyCountDown then
		lobbyTimer = lobbyTimer - dt
		if lobbyTimer < 0 then
			lobbyFade = math.min(lobbyFade + 0.6 * dt, 1)
			if lobbyFade == 1 then
				util.changeState("game", charSelections[lobbyCursors[myLobbyID].selection].char)
			end
			lobbyTimer = 0
		end
	end

	if chatState then
		if love.keyboard.hasTextInput() then
			lobbyInputFade = math.min(lobbyInputFade + dt / 0.3, 1)
		else
			lobbyInputFade = math.max(lobbyInputFade - dt / 0.3, 0)
		end
	end
end

function lobbyDraw()
	if mobileMode then
		local position = util.getWidth() * 0.01
		
		love.graphics.draw(backImage, util.getWidth() * 0.01, util.getHeight() * 0.011)

		position = util.getWidth() * 0.06

		if chatState then
			love.graphics.draw(keyboardImage, util.getWidth() * 0.11, util.getHeight() * 0.011)
		end

		love.graphics.draw(chatImage, position, util.getHeight() * 0.011)
	end


	love.graphics.setFont(chooseFont)

	local text = "Online Rivals Lobby"
	if chatState then
		text = "Online Rivals Chat"
	end
	love.graphics.print(text, util.getWidth() / 2 - chooseFont:getWidth(text) / 2, love.graphics.getHeight() * .05)
	
	love.graphics.setFont(mainFont)
	
	if not chatState then
		local description = charSelections[lobbyCursors[myLobbyID].selection].char.ability.description
		if not description then
			description = "No ability set."
		end
		love.graphics.print(description, util.getWidth() / 2 - mainFont:getWidth(description) / 2, love.graphics.getHeight() * 0.85)
	else
		love.graphics.setColor(255, 255, 255, 255)

		love.graphics.setScissor(util.getWidth() * 0.05, util.getHeight() * 0.24, util.getWidth() * 0.9, util.getHeight() * 0.64)

		for k = 1, #chatLog do
			local off = 0
			if #chatLog > 1 then
				off = (#chatLog - 1) * 20
			end

			love.graphics.print(chatLog[k], util.getWidth() * 0.05, (util.getHeight() * 0.78) - off * scale + (k - 1) * 20 * scale)
		end
			
		love.graphics.setScissor()

		love.graphics.rectangle("line", util.getWidth() * 0.05, util.getHeight() * 0.88, util.getWidth() * 0.9, 1 * scale)

		local textPositionX, textPositionY = util.getWidth() * 0.05, util.getHeight() * 0.9
		if mobileMode then
			if love.keyboard.hasTextInput() then
				local t = ": Type your message"
				if #chatText > 0 then
					t = ": " .. chatText
				end

				textPositionX, textPositionY = util.getWidth() / 2 - mainFont:getWidth(client:getUsername() .. t) / 2, util.getHeight() * 0.26

				love.graphics.setColor(0, 0, 0, 180 * lobbyInputFade)

				love.graphics.rectangle("fill", 0, 0, util.getWidth(), util.getHeight())

				love.graphics.setColor(255, 255, 255, 255 * lobbyInputFade)
			end
		end

		if #chatText == 0 then
			love.graphics.setColor(180, 180, 180)
			love.graphics.print(client:getUsername() .. ": Type your message", textPositionX, textPositionY)
		else
			love.graphics.setColor(200, 200, 200)
			love.graphics.print(client:getUsername() .. ": " .. chatText, textPositionX, textPositionY)
		end
	end
	
	if not chatState then
		if charSelections then
			for k, v in pairs(charSelections) do
				love.graphics.setColor(255, 255, 255)
				if v.selected then
					love.graphics.setColor(128, 128, 128) 
				else
					love.graphics.setColor(255, 255, 255)
				end
				v:draw()
			end
		end
		
	   if lobbyCursors then	
			for k, v in pairs(lobbyCursors) do
				v:draw()
			end
		end

		if lobbyCountDown then
			love.graphics.setColor(0, 0, 0, 255 * lobbyFade)
			love.graphics.rectangle("fill", 0, 0, util.getWidth(), util.getHeight())
			love.graphics.setColor(255, 255, 255, 255)

			love.graphics.setFont(countDownFont)
		
			love.graphics.setColor(255, 255, 255, 255)

			love.graphics.print("Game starting in " .. math.floor(lobbyTimer) .. "s", util.getWidth() / 2 - countDownFont:getWidth("Game starting in " .. math.floor(lobbyTimer) .. "s") / 2, util.getHeight() / 2 - countDownFont:getHeight() / 2)
		end
	end
	
	love.graphics.setColor(255, 255, 255, 255)
end

function lobbyTextInput(text)
	if #chatText < 30 then
		chatText = chatText .. text
	end
end

function lobbyInsertChat(text)
	table.insert(chatLog, text)

	if #chatLog > 8 then
		table.remove(chatLog, 1)
	end
end

function lobbyKeyPressed(key)
	if key == "tab" then
		chatState = not chatState
	end

	if chatState then
		if key == "backspace" then
			chatText = chatText:sub(1, -2)
		elseif key == "return" then
			if #chatText == 0 then
				return
			end
			
			lobbyInsertChat(client:getUsername() .. ": " .. chatText)
			table.insert(clientTriggers, "chat;" .. client:getUsername() .. ": " .. chatText .. ";")

			if mobileMode then
				love.keyboard.setTextInput(false)
			end

			chatText = ""
		elseif key == "escape" then
			love.keyboard.setTextInput(false)
		end
		return
	end

	if lobbyCharacters[myLobbyID] then
		if key == "escape" then
			if lobbyCharacters[myLobbyID] then
				lobbyCharacters[myLobbyID] = nil
				
				lobbyCursors[myLobbyID]:setReady(false)

				charSelections[lobbyCursors[myLobbyID].selection].selected = false
			end
		end
		return
	else
		if key == "escape" then
		
			client:disconnect()
			if netplayHost then
				server:destroyServer()
			end
			client:close()
			
			util.changeState("netplay")
		end
	end

	if key == "d" or key == "right" then
		lobbyCursors[myLobbyID]:move(1)
	elseif key == "a" or key == "left" then
		lobbyCursors[myLobbyID]:move(-1)
	elseif key == "space" or "return" then
		if not chatState then
			if not lobbyCharacters[myLobbyID] then
				
				local pass = true
				
				for k = #lobbyCharacters, 1, -1 do
					if k ~= myLobbyID then
						if charSelections[k].selected then
							if lobbyCursors[myLobbyID].selection == k then
								explodeSound:play()

								pass = false
								
								break
							end
						end
					end
				end

				if pass then
					lobbyCharacters[myLobbyID] = currentLobbySelection

					charSelections[lobbyCursors[myLobbyID].selection].selected = true

					lobbyCursors[myLobbyID]:setReady(true)
				end
			end
		end
	end
end

function lobbyTouchPressed(id, x, y, pressure)
	for k, v in pairs(charSelections) do
		if isTapped(v.x * scale, v.y * scale, v.width * scale, v.height * scale) then
			
			if lobbyCursors[myLobbyID].selection ~= k then
				lobbyCursors[myLobbyID]:setPosition(k)
			else
				lobbyCharacters[myLobbyID] = currentLobbySelection

				if not lobbyCursors[myLobbyID].ready then
					charSelections[lobbyCursors[myLobbyID].selection].selected = true

					lobbyCursors[myLobbyID]:setReady(true)
				else
					charSelections[lobbyCursors[myLobbyID].selection].selected = false

					lobbyCursors[myLobbyID]:setReady(false)
				end
			end
			
			break
		end
	end

	if chatState then
		if isTapped(util.getWidth() * 0.11, util.getHeight() * 0.011, 16 * scale, 16 * scale) then
			love.keyboard.setTextInput(not love.keyboard.hasTextInput())
		elseif isTapped(util.getWidth() * 0.05, util.getHeight() * 0.9, util.getWidth() * 0.9, mainFont:getHeight()) then
			love.keyboard.setTextInput(true)
		end

		if love.keyboard.hasTextInput() then
			return
		end
	end

	if isTapped(util.getWidth() * 0.01, util.getHeight() * 0.011, 14 * scale, 16 * scale) then
		client:disconnect()
		if netplayHost then
			server:destroyServer()
		end
		client:close()

		util.changeState("netplay")
	elseif isTapped(util.getWidth() * 0.06, util.getHeight() * 0.011, 16 * scale, 16 * scale) then
		chatState = not chatState
	end
end

function newCursor(playerID)
	local cursor = {}
	
	cursor.x = charSelections[playerID].x
	cursor.y = charSelections[playerID].y
	cursor.width = 40
	cursor.height = 40
	
	cursor.selection = playerID
	
	cursor.playerID = playerID

	cursor.ready = false
	
	function cursor:setPosition(selection)
		self.x = charSelections[selection].x
		self.y = charSelections[selection].y
		self.selection = selection
	end

	function cursor:setReady(isReady)
		self.ready = isReady

		if #lobbyCursors <= 1 then
			return
		end
		
		local countReady = 0
		for k = 1, #lobbyCursors do
			if lobbyCursors[k].ready then
				countReady = countReady + 1
			end
		end

		if countReady == #lobbyCursors then
			lobbyCountDown = true
		else
			lobbyCountDown = false

			lobbyFade = 0
			lobbyTimer = 3
		end
	end
	
	function cursor:draw()
		local v = self
		
		love.graphics.setColor(playerCursorColors[self.playerID])
		
		local offset = math.floor((math.sin(love.timer.getTime() * math.pi * 2) + 1) / 2 * 3)
		love.graphics.line((v.x - offset) * scale, (v.y - offset) * scale, ((v.x + 8) - offset) * scale, (v.y - offset) * scale)
		love.graphics.line((v.x - offset) * scale, (v.y - offset) * scale, (v.x - offset) * scale, ((v.y + 8) - offset) * scale)

		love.graphics.line(((v.x + v.width - 8) + offset) * scale, (v.y - offset) * scale, ((v.x + v.width) + offset) * scale, (v.y - offset) * scale)
		love.graphics.line(((v.x + v.width) + offset) * scale, (v.y - offset) * scale, ((v.x + v.width) + offset) * scale, ((v.y + 8) - offset) * scale)

		love.graphics.line(((v.x + v.width) + offset) * scale, ((v.y + v.height - 8) + offset) * scale, ((v.x + v.width) + offset) * scale, ((v.y + v.height) + offset) * scale)
		love.graphics.line(((v.x + v.width - 8) + offset) * scale, ((v.y + v.height) + offset) * scale, ((v.x + v.width) + offset) * scale, ((v.y + v.height) + offset) * scale)

		offset = math.floor((math.sin(love.timer.getTime() * math.pi * 2) + 1) / 2 * 3)
		love.graphics.line((v.x - offset) * scale, ((v.y + v.height) + offset) * scale, ((v.x + 8) - offset) * scale, ((v.y + v.height) + offset) * scale)
		love.graphics.line((v.x - offset) * scale, ((v.y + v.height - 8) + offset) * scale, (v.x - offset) * scale, (((v.y + v.height) + offset) * scale))
		
		love.graphics.setColor(255, 255, 255, 255)

		if self.ready then
			love.graphics.draw(readyImage, (self.x + self.width / 2 - readyImage:getWidth() / 2) * scale, (self.y + self.height / 2 - readyImage:getHeight() / 2) * scale)
		end
	end
	
	function cursor:move(i)
		self.selection = self.selection + i
		if self.selection > #gameCharacters then
			self.selection = 1
		elseif self.selection < 1 then
			self.selection = #gameCharacters
		end
		self:setPosition(self.selection)
	end
	
	return cursor
end