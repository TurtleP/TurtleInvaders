function lobbyInit(playerID, playerNick)
	if not charSelections then
		charSelections = {}
		for x = 1, #gameCharacters do
			charSelections[x] = newCharSelection((love.graphics.getWidth() / scale) / 2 - 170 + (math.mod( (x - 1), 6 ) * 60), ((love.graphics.getHeight() / scale) * 0.57) - 60 + math.floor( (x - 1) / 6 ) * 60, x)
		end
	end

	lobbyCursors = {}
	lobbyCharacters = {}
	
	chooseFont = love.graphics.newFont("graphics/monofonto.ttf", 40 * scale)
	mainFont = love.graphics.newFont("graphics/monofonto.ttf", 18 * scale)
	
	myLobbyID = playerID
	currentLobbySelection = playerID
	lobbyCursors[playerID] = newCursor(playerID)
	
	playerCursorColors =
	{
		{255, 55, 0, 95},
		{0, 55, 255, 95},
		{255, 205, 0, 95},
		{55, 255, 9, 95}
	}

	lobbyCountDown = false
	lobbyTimer = 3
	lobbyFade = 0

	chatLog = {}

	chatKeyboard = keyboard:new("Enter chat text.", 24)

	chatKeyboard.onReturn = function()
		if #chatKeyboard:getText() == 0 then
			return
		end

		local chatString = client:getUsername() .. ": " .. chatKeyboard:getText()

		lobbyInsertChat(chatString)

		table.insert(clientTriggers, "chat;" .. chatString .. ";")
	end

	chatText = ""
	chatState = false
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
end

function lobbyDraw()
	local position = util.getWidth() * 0.01
	if mobileMode then
		love.graphics.draw(backImage, util.getHeight() * 0.01, util.getHeight() * 0.011)
		position = util.getWidth() * 0.06
	end

	love.graphics.print("@", position, util.getHeight() * 0 - 2 * scale)

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

	    if lobbyCountDown then
	    	love.graphics.setColor(0, 0, 0, 255 * lobbyFade)
		    love.graphics.rectangle("fill", 0, 0, 400, 240)
	    
		    love.graphics.setColor(255, 255, 255, 255)

	    	love.graphics.print("Game starting in " .. math.floor(lobbyTimer) .. "s", util.getWidth() / 2 - mainFont:getWidth("Game starting in " .. math.floor(lobbyTimer) .. "s") / 2, util.getHeight() / 2 - mainFont:getHeight() / 2)
	    end
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

		if #chatText == 0 then
			love.graphics.setColor(180, 180, 180)
			love.graphics.print(client:getUsername() .. ": Type your message", util.getWidth() * 0.05, util.getHeight() * 0.9)
		else
			love.graphics.setColor(200, 200, 200)
			love.graphics.print(client:getUsername() .. ": " .. chatText, util.getWidth() * 0.05, util.getHeight() * 0.9)
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
			love.graphics.rectangle("fill", 0, 0, 320, 240)
			love.graphics.setColor(255, 255, 255, 255)
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
			lobbyInsertChat(client:getUsername() .. ": " .. chatText)
			chatText = ""
		end
		return
	end

	if lobbyCharacters[myLobbyID] then
		if key == "escape" then
			if lobbyCharacters[myLobbyID] then
				lobbyCharacters[myLobbyID] = nil
				
				lobbyCards[myLobbyID]:setReady(false)

				charSelections[lobbyCursors[myLobbyID].selection].selected = false
			end
		elseif key == "space" or key == "return" then
			if lobbyCharacters[myLobbyID] then
				lobbyCards[myLobbyID]:setReady(true)
			end
		end
		return
	else
		if key == "escape" then
		
			if netplayHost then
				server:shutdown()
				client:shutdown()
			else
				client:shutdown()
			end

			util.changeState("netplay")
		end
	end

	if key == "d" or key == "right" then
		lobbyCursors[myLobbyID]:move(1)
	elseif key == "a" or key == "left" then
		lobbyCursors[myLobbyID]:move(-1)
	elseif key == "space" or "return" then
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

				charSelections[lobbyCursors[myLobbyID].selection].selected = true
			end
			
			break
		end
	end

	if isTapped(util.getWidth() * 0.01, util.getHeight() * 0.011, 16 * scale, 16 * scale) then
		clientSocket:setpeername("*")

		util.changeState("netplay")
	end
end

function lobbyMousePressed(x, y, button)
	local position = util.getWidth() * 0.01
	if mobileMode then
		position = util.getWidth() * 0.1
	end

	if isTapped(position, util.getHeight() * 0.011, 16 * scale, 16 * scale) then
		chatState = not chatState
	end
end

function newLobbyCard(x, name, id)
	local card = {}
	
	card.x = x
	card.y = 68
	card.width = mainFont:getWidth("        ") --lazy but whatever. It's monospaced.
	card.height = 136
	
	card.name = name
	
	card.id = id
	
	card.character = gameCharacters[myLobbyID]
	
	card.ready = false
	card.playToggleSound = false
	
	function card:draw()
		self.character = charSelections[lobbyCursors[self.id].selection].char
		if not self.character.animated then
			love.graphics.draw(self.character.graphic, self.x + self.width / 2 - self.character.graphic:getWidth() / 2, self.y + self.height / 2 - self.character.graphic:getHeight() / 2)
		else
			love.graphics.draw(self.character.graphic, self.character.quads[1], self.x + self.width / 2 - self.character.width / 2, self.y + self.height / 2 - self.character.height / 2)
		end
		love.graphics.print(self.name, self.x + self.width / 2 - mainFont:getWidth(self.name) / 2, self.y + 9)
		
		local quadi = 2
		if self.ready then
			quadi = 1
		end
		love.graphics.draw(serverExistsImage, serverQuads[quadi], self.x + (self.width / 2) - 9, self.y + self.height - 36)
	end

	function card:setReady(ready)
		self.ready = ready

		if self.ready then
			if not self.playToggleSound then
				toggleSound:play()
				self.playToggleSound = true
			end
		else
			self.playToggleSound = false
		end
		
		local countReady = 0
		for k = 1, #lobbyCards do
			if lobbyCards[k].ready then
				countReady = countReady + 1
			end
		end

		if countReady == #lobbyCards then
			lobbyCountDown = true
		else
			lobbyCountDown = false

			lobbyFade = 0
			lobbyTimer = 3
		end
	end
	  
	return card
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