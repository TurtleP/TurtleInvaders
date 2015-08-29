function partymode_load()
	state = "partymode"

	party_stars = {}
	for k = 1, 100 do
		party_stars[k] = {love.math.random(0, 600), love.math.random(0, 300)}
	end

	selectionIDs = {}

	local padding = 6

	selectionWidth = 230 + (padding * 2)
	selectionHeight = 52

	for k = 1, #gamechars+1 do
		if math.mod(k - 1, 5) == 0 and k - 1 ~= 0 then
			selectionHeight = selectionHeight + 46
		end
	end

	for k = 1, #gamechars do
		selectionIDs[k] = newPortrait(characters[gamechars[k]], ( (gameW / 2 - (selectionWidth / 2) ) + (math.mod(k - 1, 5)) * 46) + padding, ( (gameH / 2 - (selectionHeight / 2)) + math.floor( (k - 1) / 5 ) * 46 ) + padding )
	end

	table.insert(selectionIDs, newPortrait("?", ( (gameW / 2 - (selectionWidth / 2) ) + (math.mod(#gamechars+1 - 1, 5)) * 46) + padding, ( (gameH / 2 - (selectionHeight / 2)) + math.floor( (#gamechars+1 - 1) / 5 ) * 46 ) + padding ) )

	joinTextTimers = {0, 0, 0, 0}
	playerSelections = {1, 2, 3, 4}
	selectionActive = {true, false, false, false}
	playerSelected = {false, false, false, false}

	playerCursorColors =
	{
		{255, 55, 0, 95},
		{0, 55, 255, 95},
		{255, 205, 0, 95},
		{55, 255, 9, 95}
	}

	playerCursorColorsFade = {1, 1, 1, 1}
	playerCursorTime = {0, 0, 0, 0}

	charData = {"Player 1", "Press " .. controls[2][3], "Press " .. controls[3][3], "Press " .. controls[4][3]}
	defaultData = {unpack(charData)}

	playerSlots = {}
	
	if not mobileMode then
		playerSlots[1] = newPlayerSlot( ((178 / 2) - (100 / 2)) - 1, 14, charData[1], "1") 

		playerSlots[2] = newPlayerSlot( ((178 / 2) - (100 / 2)) - 1, 158, charData[2], "2") 

		playerSlots[3] = newPlayerSlot( (gameW - 178 / 2) - (100 / 2) - 1, 14, charData[3], "3") 

		playerSlots[4] = newPlayerSlot( (gameW - 178 / 2) - (100 / 2) - 1, 158, charData[4], "4")
	else
		playerSlots[1] = newPlayerSlot( ((178 / 2) - (100 / 2)) - 1, gameH / 2 - 120 / 2, charData[1], "1")
	end 

	playData = {}
end

function partymode_update(dt)
	for k = 1, 4 do
		if not playerSelected[k] then
			playerCursorTime[k] = playerCursorTime[k] + dt
			playerCursorColorsFade[k] = math.clamp(math.sin(playerCursorTime[k] + 1), 0, 1)
		end
	end

	for k, v in pairs(playData) do
		v:update(dt)
	end
end

function partymode_draw()
	for k, v in pairs(party_stars) do
		love.graphics.setColor(255, 255, 255)
		love.graphics.point(v[1] * scale, v[2] * scale)
	end

	love.graphics.setColor(32, 32, 32)
	love.graphics.rectangle("fill", (gameW / 2 - (selectionWidth / 2)) * scale, (gameH / 2 - (selectionHeight / 2)) * scale, selectionWidth * scale, selectionHeight * scale)

	love.graphics.setColor(255, 255, 255)
	love.graphics.rectangle("line", (gameW / 2 - (selectionWidth / 2)) * scale, (gameH / 2 - (selectionHeight / 2)) * scale, selectionWidth * scale, selectionHeight * scale)

	for k, v in pairs(selectionIDs) do
		for ply = 1, 4 do
			if playerSelections[ply] == k and selectionActive[ply] then
				love.graphics.setColor(playerCursorColors[ply])
				love.graphics.roundrectangle("fill", v.x * scale, v.y * scale, v.width * scale, v.height * scale)
			end
		end
		v:draw()
	end

	for k, v in pairs(playerSlots) do
		v:draw()

		if selectionActive[k] then
			if gamechars[playerSelections[k]] then
				v:setShip(characters[gamechars[playerSelections[k]]])
				v:setText(gamechars[playerSelections[k]])
			else
				v:setText("Random")
				v:setShip("?")
			end
		end
	end

	for k, v in pairs(playData) do
		v:draw()
	end

	love.graphics.setFont(menubuttonfont)
	love.graphics.print("Choose a character", (gameW * scale) / 2 - menubuttonfont:getWidth("Choose a character") / 2, 15 * scale)
end

function partymode_keypressed(key)
	for k = 1, 4 do
		if selectionActive[k] and not playerSelected[k] then
			if key == controls[k][1] then
				partymode_movecursor(k, false)
			elseif key == controls[k][2] then
				partymode_movecursor(k, true)
			elseif key == controls[k][3] then
				partymode_movecursor(k, nil, true)
			elseif key == controls[k][4] then
				partymode_movecursor(k, nil, false)
			end
		elseif not selectionActive[k] then
			if key == controls[k][3] then
				partymode_movecursor(k, nil, true, true)
			end
		elseif selectionActive[k] and playerSelected[k] then
			if key == controls[k][4] then
				partymode_movecursor(k, nil, false, nil, true)
			end
		end
	end

	if key == controls[1][3] then
		if playerSelected[1] and ( (playerSelected[2] and selectionActive[2]) or (playerSelected[3] and selectionActive[3]) or (playerSelected[4] and selectionActive[4]) ) then
			game_load()
		elseif playerSelected[1] and not ( (selectionActive[2]) or (selectionActive[3]) or (selectionActive[4]) ) then
			game_load()
		end 
	end

	if key == "escape" then
		if not playerSelected[1] and not ( (selectionActive[2]) or (selectionActive[3]) or (selectionActive[4]) ) then
			menu_load()
		end 
	end
end

function partymode_joystickpressed(joystick, button)
	local id = joystick:getID()

	for k = 1, 4 do
		if id == k then
			local left, right, shoot, esc = "dpleft", "dpright", controls[k][3]:split(":")[2], controls[k][4]:split(":")[2]

			if selectionActive[k] and not playerSelected[k] then
				if button == right then
					partymode_movecursor(k, true)
				elseif button == left then
					partymode_movecursor(k, false)
				elseif button == shoot then
					partymode_movecursor(k, nil, true)
				elseif button == esc then
					partymode_movecursor(k, nil, false)
				end
			elseif not selectionActive[k] then
				if button == shoot then
					partymode_movecursor(k, nil, true, true)
				end
			elseif selectionActive[k] and playerSelected[k] then
				if button == esc then
					if not playerSelected[1] and not ( (selectionActive[2]) or (selectionActive[3]) or (selectionActive[4]) ) then
						menu_load()
					end 
				end
			end
		end
	end
end

function partymode_movecursor(k, right, enter, activateSlot, removeChar)
	if right ~= nil then
		if right then
			playerSelections[k] = playerSelections[k] + 1
			if playerSelections[k] > #selectionIDs then
				playerSelections[k] = 1
			end
		else
			playerSelections[k] = playerSelections[k] - 1
			if playerSelections[k] < 1 then
				playerSelections[k] = #selectionIDs
			end
		end
	end

	if enter ~= nil then
		if enter then
			if not activateSlot then
				playerSelected[k] = true

				local data = gamechars[playerSelections[k]]
				if playerSelections[k] == #gamechars+1 then
					data = gamechars[love.math.random(#gamechars)]
				end

				local width = playerSlots[k].width
				if k%2 == 0 then
					width = -playerSlots[k].width
				end

				gameData[k] = data
			else
				selectionActive[k] = true

				playerSlots[k]:setShip(nil)
				playerSlots[k]:setText(charData[k])
			end
		else
			if removeChar then
				playerSelected[k] = false

				table.remove(gameData, k)
			elseif removeChar ~= nil then
				selectionActive[k] = false
			end
		end
	end
end

function newPortrait(g, x, y)
	local portrait = {}

	portrait.ship = g
	portrait.x = x 
	portrait.y = y
	portrait.width = 40
	portrait.height = 40

	function portrait:draw()
		love.graphics.setColor(255, 255, 255)

		if type(self.ship) == "table" then
			if not g.isAnimated then
				love.graphics.draw(self.ship.graphic, ( (self.x + (self.width / 2) ) - self.ship.graphic:getWidth() / 2 ) * scale, ( (self.y + (self.height / 2) ) - self.ship.graphic:getHeight() / 2 ) * scale, 0, scale, scale)
			else
				love.graphics.draw(self.ship.graphic, self.ship.animationQuads[1], ( (self.x + (self.width / 2) ) - self.ship.width / 2 ) * scale, ( (self.y + (self.height / 2) ) - self.ship.graphic:getHeight() / 2 ) * scale, 0, scale, scale)
			end
		else
			love.graphics.setFont(menubuttonfont)
			love.graphics.print(self.ship, (self.x + (self.width / 2)) * scale - menubuttonfont:getWidth(self.ship) / 2, (self.y + (self.height / 2)) * scale - menubuttonfont:getHeight(self.ship) / 2 + 3 * scale )
		end

		--love.graphics.rectangle("line", self.x * scale, self.y * scale, self.width * scale, self.height * scale)
	end

	function portrait:update(dt)
		-- body
	end

	return portrait
end

function newPlayerSlot(x, y, text, playerID)
	local slot = {}

	slot.x = x
	slot.y = y
	slot.text = text
	slot.width = 100
	slot.height = 124
	slot.playerID = tonumber(playerID)

	slot.buttonquads = {}
	slot.buttonimg = love.graphics.newImage("gfx/menu/a_button.png")
	slot.controls = slot.text:split(" ")[2]

	if slot.text:split(" ")[2] == slot.controls then
		local spl = slot.text:split(" ")

		local gpad = spl[2]:split(":")

		if gpad then
			if gpad[1] == "gamepad" then
				slot.text = ""

				slot.text = slot.text .. spl[1] .. "\t"

				if gpad[2] == "a" then
					slot.buttoni = 1
				elseif gpad[2] == "b" then
					slot.buttoni = 2
				elseif gpad[3] == "x" then
					slot.buttoni = 4
				elseif gpad[4] == "y" then
					slot.buttoni = 3
				end
			end
		end
	end

	for k = 1, 4 do
		slot.buttonquads[k] = love.graphics.newQuad((k-1)*17, 0, 16, 16, slot.buttonimg:getWidth(), slot.buttonimg:getHeight())
	end

	function slot:draw()
		love.graphics.setColor(32, 32, 32)
		love.graphics.rectangle("fill", self.x * scale, self.y * scale, self.width * scale, self.height * scale)

		love.graphics.setColor(255, 255, 255)
		love.graphics.rectangle("line", self.x * scale, self.y * scale, self.width * scale, self.height * scale)

		love.graphics.setFont(font7)

		love.graphics.print("player " .. self.playerID, (self.x + (self.width / 2) ) * scale - font7:getWidth("player " .. self.playerID) / 2, (self.y + 4) * scale) 
		if self.ship then
			if type(self.ship) == "table" then
				local s = scale + 1
				if not self.ship.isAnimated then
					love.graphics.draw(self.ship.graphic, (self.x + (self.width / 2) ) * scale - ( self.ship.width / 2) * s, (self.y + (self.height / 2)) * scale - (self.ship.height / 2) * s, 0, s, s)
				else
					love.graphics.draw(self.ship.graphic, self.ship.animationQuads[1], (self.x + (self.width / 2) ) * scale - ( self.ship.width / 2) * s, (self.y + (self.height / 2)) * scale - (self.ship.height / 2) * s, 0, s, s)
				end
			else
				love.graphics.setFont(menubuttonfont)
				love.graphics.print(self.ship, (self.x + (self.width / 2) ) * scale - menubuttonfont:getWidth(self.ship) / 2, (self.y + self.height / 2 ) * scale - menubuttonfont:getHeight(self.ship) / 2)
			end
		end

		love.graphics.setFont(font7)

		love.graphics.print(self.text, (self.x + (self.width / 2) ) * scale - font7:getWidth(self.text) / 2, (self.y + self.height ) * scale - font7:getHeight(self.text))

		if self.buttoni then
			love.graphics.draw(self.buttonimg, self.buttonquads[self.buttoni], (self.x + (self.width / 2) ) * scale - font7:getWidth(self.text) / 2 + font7:getWidth("\t") + 18 * scale, (self.y + self.height ) * scale - font7:getHeight(self.text) - 9 * scale, 0, scale, scale)
		end

		love.graphics.setFont(menubuttonfont)
	end

	function slot:update(dt)

	end

	function slot:setShip(ship)
		self.ship = ship
	end

	function slot:setText(text)
		self.text = text
	end

	return slot
end