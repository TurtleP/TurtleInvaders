function lobby_load(hostname, char, hosting)
	netplayenemies = {}
	
	state = "lobby"
	host = hostname
	hostchar = char

	lobby_playerlist = {}
	lobby_chat = {}
	offset = 0

	gamestarting = false

	lobby_playerlist[1] = {connected = true, nick = hostname, char = char, hosting = (hosting or false)}

	chattext = ""
	maxlobbyplayers = 4

	buffertimer = 0
	bufferquad = 1
	bufferrot = -math.pi/2
	rotated = false
	lobby_readyPlayers = 0

	local x, y = love.window.getWidth()/2-(524*scale)/2, love.window.getHeight()/2-(244*scale)/2

	lobbyscrollbar = gui:new("scrollbar", 546 * scale, 106 * scale, 12*scale, 130*scale, 12*scale, 20*scale)
	lobbyscrollbar.barheight = lobbyscrollbar.height
	lobbyscrollbar.value = 1

	local inviteStr = "Click to chat.."

	if mobileMode then
		inviteStr = "Tap to chat.."
	end

	lobbychatbar = gui:new("textfield", 140 * scale, 241 * scale, 38, chattext, inviteStr)
	lobbystart = gui:new("button", 144 * scale, 240 * scale, "Start Game",
	function()
		if #lobby_playerlist > 1 then
			client:sendNotify("begingame")
			gamestarting = true
		end
	end)

	lobbysettings = gui:new("button", 80 * scale - font4:getWidth("Settings") / 2 - 2 * scale, 115 * scale, "Settings", 
	function()
		chatmode = not chatmode
	end)

	lobbystart.highlightColor = {255, 0, 0}
	lobbystart.unHighlightColor = {200, 0, 0}
	lobbystart.backgroundColor = {64, 0, 0}

	startbuttonsync = 0.03
	startbuttonsynctimer = 0

	rectfade = 0

	chatmode = true

	gameDifficulty = 2
	difficultyMode = gui:new("button", 144 * scale, 130 * scale, difficultytypes[gameDifficulty], 
	function()
		if love.mouse.isDown("l") then
			gameDifficulty = gameDifficulty + 1
			if gameDifficulty > #difficultytypes then
				gameDifficulty = 1
			end
			difficultyMode.text = difficultytypes[gameDifficulty]
		elseif love.mouse.isDown("r") then
			gameDifficulty = gameDifficulty - 1
			if gameDifficulty < 1 then
				gameDifficulty = #difficultytypes
			end
			difficultyMode.text = difficultytypes[gameDifficulty]
		end

		lobby_chatSend("(SERVER): Difficulty changed to " .. difficultyMode.text)
	end)

	gameModei = 1
	gameMode = gui:new("button", 144 * scale, 186 * scale, gamemodes[gameModei], 
	function()
		if love.mouse.isDown("l") then
			gameModei = gameModei + 1
			if gameModei > #gamemodes then
				gameModei = 1
			end
			gameMode.text = gamemodes[gameModei]
			gameMode.width = font4:getWidth(gameMode.text) + 4 * scale
		elseif love.mouse.isDown("r") then
			gameModei = gameModei - 1
			if gameModei < 1 then
				gameModei = #gamemodes
			end
			gameMode.text = gamemodes[gameModei]
			gameMode.width = font4:getWidth(gameMode.text) + 4 * scale
		end

		lobby_chatSend("(SERVER): Mode changed to " .. difficultyMode.text)
	end)

	disconnect = gui:new("button", 30 * scale, 78 * scale, "Leave", function()
		client:disconnect()
	end)

	lobby_stars = {}
	for k = 1, 100 do
		lobby_stars[k] = {love.math.random(4, love.window.getWidth() - 4), love.math.random(4, love.window.getHeight() - 4)}
	end
end

function lobby_update(dt, charname)
	for k = 1, 4 do
		local v = lobby_playerlist[k]

		if not v then
			buffertimer = math.min(buffertimer + 3*dt)
			bufferquad = math.floor(buffertimer%4)+1
			if bufferquad == 1 then
				if not rotated then
					bufferrot = bufferrot + math.pi/2
					if bufferrot >= math.pi*2 then
						bufferrot = 0
					end
					rotated = true
				end
			else
				rotated = false
			end
		else
			local v = characters[lobby_playerlist[k].char]

			if v then
				if v.isAnimated then
					v.animationTimer = v.animationTimer + dt
					if v.animationTimer >= v.animationSpeed then
						v.animationTimer = 0
						v.animationQuad = v.animationQuad + 1
						if v.animationQuad > #v.animationQuads then
							v.animationQuad = 1
						end
					end
				end
			end
		end
	end

	startbuttonsynctimer = startbuttonsynctimer + dt
	if startbuttonsynctimer >= startbuttonsync then
		if #lobby_playerlist >= 2 then
			lobbystart.highlightColor = {0, 255, 0}
			lobbystart.unHighlightColor = {0, 200, 0}
			lobbystart.backgroundColor = {13, 26, 1}
		end
		startbuttonsynctimer = 0
	end

	lobbyscrollbar:update(dt)
	lobbychatbar:update(dt)

	if gamestarting then
		rectfade = math.min(rectfade + dt/0.5, 1)
	end
end

function lobby_draw()

	for k, v in pairs(lobby_stars) do
		love.graphics.setPointSize(1 * scale)
		love.graphics.point(v[1] * scale, v[2] * scale)
	end

	love.graphics.setColor(32, 32, 32)
	love.graphics.rectangle("fill", 140 * scale, 105 * scale, 420 * scale, 160 * scale)

	love.graphics.setColor(255, 255, 255)
	if chatmode then
		--draw the chat!
		local font = font4
		love.graphics.setFont(font)

		local spacer = 5*scale
		local yy = 0
		love.graphics.setScissor( 142 * scale, 107 * scale, 418 * scale, 130 * scale)
		for k = 1, #lobby_chat do

			love.graphics.push()
			
			local offset = #lobby_chat*(font:getHeight()/scale) + #lobby_chat*spacer
			offset = math.min(offset, 130*scale) + math.max(0, (offset-130*scale)*lobbyscrollbar.value)
			love.graphics.translate( 0, 130*scale - offset)

			local t = lobby_chat[k]:split("\n")
			for i, v in ipairs(t) do
				love.graphics.print(v, 142*scale, 111*scale + yy*scale)
				yy = yy + (font:getHeight()/scale) + spacer
			end
			love.graphics.pop()

		end
		love.graphics.setScissor()

		lobbychatbar:draw()
		lobbyscrollbar:draw()

		love.graphics.setColor(255, 255, 255)
		love.graphics.rectangle("line", 140 * scale, 105 * scale, 420 * scale, 132 * scale)
	else
		love.graphics.setFont(font4)
		--draw options n stuff
		love.graphics.setColor(0, 127, 127)
		love.graphics.print("Difficulty", 144 * scale, 110 * scale)

		love.graphics.setColor(255, 255, 255)
		love.graphics.rectangle("fill", 144 * scale, 124 * scale, font4:getWidth("Difficulty"), 1 * scale)

		difficultyMode:draw() 

		love.graphics.setColor(0, 127, 127)
		love.graphics.print("Game Mode", 144 * scale, 166 * scale)

		love.graphics.setColor(255, 255, 255)
		love.graphics.rectangle("fill", 144 * scale, 180 * scale, font4:getWidth("Game Mode"), 1 * scale)

		gameMode:draw()

		lobbystart:draw()

		love.graphics.rectangle("line", 350 * scale, 114 * scale, 1 * scale, 142 * scale)

		love.graphics.setColor(0, 127, 127)
		love.graphics.print("Modifiers", 456 * scale - font4:getWidth("Modifiers") / 2, 110 * scale)

		love.graphics.setColor(255, 255, 255)
		love.graphics.rectangle("fill", 456 * scale - font4:getWidth("Modifiers") / 2, 126 * scale, font4:getWidth("Modifiers"), 1 * scale)

		love.graphics.setColor(255, 255, 255)
		love.graphics.rectangle("line", 140 * scale, 105 * scale, 420 * scale, 158 * scale)
	end

	love.graphics.setFont(font2)
	love.graphics.print("Online", 30 * scale, 38 * scale)
	love.graphics.print("Co-Op", 30 * scale, 58 * scale)
	
	disconnect:draw()

	--draw the current player we want or something
	lobby_drawCard( 30 * scale, 105 * scale, 100 * scale, 160 * scale, lobby_playerlist[1].nick, lobby_playerlist[1].char, lobby_playerlist[1].hosting )

	--draw clients, or other people idk
	for k = 2, 4 do
		if lobby_playerlist[k] then
			lobby_drawCard( 130 * scale + (k - 2) * 150 * scale, 35 * scale, nil, nil, lobby_playerlist[k].nick, lobby_playerlist[k].char, lobby_playerlist[k].hosting)
		else
			lobby_drawCard( 130 * scale + (k - 2) * 150 * scale, 35 * scale, nil, nil, "Waiting..", nil, false)
		end
	end	

	--only hosts!
	if netplay then
		lobbysettings:draw()
	end

	if gamestarting then
		love.graphics.setColor(0, 0, 0, 255*rectfade)
		love.graphics.rectangle("fill", 0, 0, love.window.getWidth(), love.window.getHeight())
		love.graphics.setColor(255, 255, 255)
	end
end

function lobby_textinput(t)
	lobbychatbar:textinput(t)
end

function lobby_drawCard(x, y, w, h, name, charname, host)
	love.graphics.setFont(font4)

	love.graphics.setColor(32, 32, 32)

	if not w and not h then
		love.graphics.roundrectangle("fill", x, y, 140 * scale, 60 * scale, 4 * scale, 32 * scale)
	else
		love.graphics.roundrectangle("fill", x, y, w, h, 4 * scale, 32 * scale)
	end

	love.graphics.setColor(255, 255, 255)

	if name ~= "Waiting.." then
		local v = characters[charname]
		
		local otherw = 140 * scale
		local otherh = 60 * scale

		if w and h then

			otherw = w
			otherh = h
			local others = scale + 1

			if v.isAnimated then
				love.graphics.draw(v.graphic, v.animationQuads[v.animationQuad], x + otherw / 2 - v.width * others / 2, y + otherh / 2 - (v.height * others) / 2, 0, others, others)
			else
				love.graphics.draw(v.graphic, x + otherw / 2 - v.width * others / 2, y + otherh / 2 - (v.height * others) / 2, 0, others, others)
			end

		else

			if v.isAnimated then
				love.graphics.draw(v.graphic, v.animationQuads[v.animationQuad], x + (4 * scale), y + otherh / 2 - (v.height * scale) / 2, 0, scale, scale)
			else
				love.graphics.draw(v.graphic, x + (4 * scale), y + otherh / 2 - (v.height * scale) / 2, 0, scale, scale)
			end

		end

		if host then
			love.graphics.setColor(255, 0, 0)
		end
	else
		love.graphics.draw(bufferimg, bufferquads[bufferquad], x + (4*scale) + 20*scale, y + (60 * scale) / 2 - ( 40 * scale ) / 2 + 20 * scale, bufferrot, scale, scale, 20, 20)
	end

	if not w and not h then
		love.graphics.print(name, x + (48* scale), y + (60 * scale) / 2 - font4:getHeight(name) / 2)
	else
		love.graphics.print(name, x + (w / 2) - font4:getWidth(name) / 2, y + h - font4:getHeight(name) / 2 - 15 * scale)
	end

	love.graphics.setColor(255, 255, 255)
end

function lobby_keypressed(key)
	if key == "return" then
		if #lobbychatbar.text > 0 then
			
			lobby_chatSend(client:getName() .. ": " .. lobbychatbar.text)

			lobbychatbar.text = ""
		end
	end

	lobbychatbar:keypressed(key)
end

function lobby_chatSend(text)
	tosend = shared:fixChat(text)
	
	for i, v in ipairs(tosend) do
		client:sendChat(v)
		table.insert(lobby_chat, v)
	end
	
	if #lobby_chat >= 7 then
		lobbyscrollbar.barheight = math.max(20*scale, lobbyscrollbar.height - (#lobby_chat - 6)*20*scale)
	end
end

function lobby_mousepressed(x, y, button)
	lobbyscrollbar:mousepressed(x, y, button)
	lobbychatbar:mousepressed(x, y, button)
	lobbystart:mousepressed(x, y, button)
	disconnect:mousepressed(x, y, button)

	--only hosts!
	if netplay then
		lobbysettings:mousepressed(x, y, button)
		difficultyMode:mousepressed(x, y, button)
		gameMode:mousepressed(x, y, button)
	end
end

function lobby_mousereleased(x, y, button)
	lobbyscrollbar:mousereleased(x, y, button)
end