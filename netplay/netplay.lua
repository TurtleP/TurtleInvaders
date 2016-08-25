function netplayInit()
	netplayX = love.graphics.getWidth() / 2 - 180 * scale
	netplayY = love.graphics.getHeight() / 2 - 105 * scale
	netplayWidth = 360
	netplayHeight = 210
	
	mainFont = love.graphics.newFont("graphics/monofonto.ttf", 24 * scale)
	logoFont = love.graphics.newFont("graphics/monofonto.ttf", 16 * scale)
	
	netplayTabi = 1
	netplaySelectioni = 1
	
	defaultNicknames =
	{
		"Ninjahat",
		"RCode",
		"Yeesus",
		"Grommet",
		"Smart.Oh",
		"BotTank",
		"ZeroTriple"
	}
	
	netplayTimeout = 0

	netplaySelectionFunctions =
	{
		{
			"Nickname:",
			function()
				if mobileMode then
					love.keyboard.setTextInput(true)
				end
				netplayTextEntry = true
			end
		},
		{
			"Party name:",
			function()
				if mobileMode then
					love.keyboard.setTextInput(true)
				end
				netplayTextEntry = true
			end
		},
		{
			"",
			function()
			end
		},
		{
			"Browse Servers",
			function()
				util.changeState("browser")
			end,
		},
		{
			"Join Rivals",
			function()
				if not clientSocket then
					client:init()
					clientSocket:setsockname("255.255.255.255", 25545)
				end

				if not netplayOnline then
					if not getData then
						getData = true
					end
				end
			end
		},
		{
			"Create Rivals",
			function()
				server:init(partyName)

				if not clientSocket then
					client:init()
				end

				if not netplayOnline then
					if not getData then
						client:connect("localhost", 25545)
					end
				end
			end
		}
		
	}

	nickName = defaultNicknames[love.math.random(#defaultNicknames)]

	toolTips = 
	{
		"Enter an online nickname to use.",
		"Enter the party name to use.",
		"",
		"Browse online servers.",
		"Join a Rivals party",
		"Start a Rivals party",
	}
	
	toolTipScrollTime = 0
	toolTipPosition = netplayX + 8 * scale

	partyName = "My Party"

	bufferData =
	{
		{
			0,
			{32, 140, 176}
		},
		{
			0,
			{25, 112, 140}
		},
		{
			0,
			{19, 84, 105}
		}
	}

	searchText = 
	{
		"Searching.",
		"Searching .",
	}

	searchTimer = 0
end

function netplayUpdate(dt)
	if toolTipScrollTime < 1 then
		toolTipScrollTime = toolTipScrollTime + dt
	else
		toolTipPosition = toolTipPosition - (60 * scale) * dt
		if toolTipPosition + logoFont:getWidth(toolTips[netplaySelectioni]) < 0 then
			toolTipPosition = netplayX + netplayWidth * scale
		end
	end

	if not getData then
		if client:hasInformation() then
			if not sendData then
				client:init()

				client:connect()
			end
		end
	end
	
	if sendData then
		local data, msg = clientSocket:receive()
		
		if data then
			local cmd = data:split(";")
			if cmd[1] == "connected" then
				onlineName = nickName

				saveSettings()
										
				util.changeState("lobby", tonumber(cmd[2]), cmd[3])

				netplayOnline = true

				sendData = false				
			end
		end
	elseif getData then
		local data, ip, port = clientSocket:receivefrom()

		searchTimer = searchTimer + dt
		if searchTimer > 3 then
			getData = false
			client:shutdown()
			searchTimer = 0
		end

		if data then
			if data == partyName then
				client:setInformation(ip, port)
				client:shutdown()
				getData = false
			end
		end
	end

	if sendData or getData then
		for i = 1, #bufferData - 1 do
			local bufferDirection = 1
			if i == 2 then
				bufferDirection = -1
			end
			bufferData[i][1] = bufferData[i][1] + (bufferDirection * 2 * dt)
		end
	end
end

function netplayDraw()
	if mobileMode then
		love.graphics.draw(backImage, util.getHeight() * 0.01, util.getHeight() * 0.011)

		if netplayTextEntry then
			love.graphics.draw(keyboardImage, util.getHeight() * 0.1, util.getHeight() * 0.011)
		end
	end

	love.graphics.setFont(mainFont)
	
	love.graphics.setColor(255, 255, 255)
	love.graphics.print("Online Play", netplayX, netplayY)
	
	love.graphics.setFont(logoFont)
	
	love.graphics.setColor(127, 127, 127)
	if netplaySelectioni == 1 then
		love.graphics.setColor(255, 255, 255)
	end
	love.graphics.print("Nickname: " .. nickName, netplayX + 16 * scale, netplayY + 32 * scale)

	love.graphics.setColor(127, 127, 127)
	if netplaySelectioni == 2 then
		love.graphics.setColor(255, 255, 255)
	end
	love.graphics.print("Party name: " .. partyName, netplayX + 16 * scale, netplayY + 54 * scale)

	love.graphics.setColor(127, 127, 127)
	if netplaySelectioni == 4 then
		love.graphics.setColor(255, 255, 255)
	end
	love.graphics.print("Browse servers", netplayX + 16 * scale, netplayY + 98 * scale)
	
	love.graphics.setColor(127, 127, 127)
	if netplaySelectioni == 5 then
		love.graphics.setColor(255, 255, 255)
	end
	love.graphics.print("Join Rivals party", netplayX + 16 * scale, netplayY + 120 * scale)
	
	love.graphics.setColor(127, 127, 127)
	if netplaySelectioni == 6 then
		love.graphics.setColor(255, 255, 255)
	end
	love.graphics.print("Create Rivals party", netplayX + 16 * scale, netplayY + 142 * scale)

	if sendData or getData then
		for k = 1, #bufferData do
			love.graphics.setColor(bufferData[k][2])
			love.graphics.draw(bufferImage, bufferQuads[k], ((netplayX + 16 * scale) + logoFont:getWidth("Join Rivals party") + 8 * scale) + 4.5 * scale, (netplayY + 126 * scale) + 4.5 * scale, bufferData[k][1], 4.5, 4.5)
		end

		love.graphics.setColor(255, 255, 255)
		love.graphics.print(searchText[math.floor(bufferData[1][1] % 2) + 1], ((netplayX + 16 * scale) + logoFont:getWidth("Join Rivals party") + 24 * scale), netplayY + 120 * scale)
	end

	if toolTips[netplaySelectioni] then
		love.graphics.setColor(255, 255, 255)
		love.graphics.setScissor(netplayX, (netplayY + netplayHeight * scale) - logoFont:getHeight(), netplayWidth * scale, logoFont:getHeight())
		
		love.graphics.print(toolTips[netplaySelectioni], toolTipPosition, (netplayY + netplayHeight * scale) - logoFont:getHeight())
		
		love.graphics.setScissor()
	end
end

function netplayTextInput(text)
	if netplayTextEntry then
		if netplaySelectioni == 1 then
			if #nickName < 8 then
				nickName = nickName .. text
			end
		elseif netplaySelectioni == 2 then
			if #partyName < 8 then
				partyName = partyName .. text
			end
		end
	end
end

function netplayTouchPressed(id, x, y, pressure)
	if isTapped(util.getWidth() * 0.01, util.getHeight() * 0.011, 16 * scale, 16 * scale) then
		util.changeState("title", 2)
	elseif isTapped(util.getWidth() * 0.1, util.getHeight() * 0.011, 16 * scale, 16 * scale) then
		if not love.keyboard.hasTextInput() then
			if not netplayTextEntry then
				return
			end

			love.keyboard.setTextInput(true)
		end
	end

	for k = 1, #netplaySelectionFunctions do
		local v = netplaySelectionFunctions[k][1]

		if v ~= "" then
			if isTapped(netplayX + 16 * scale, netplayY + (32 + (k - 1) * 22) * scale, logoFont:getWidth(v), 16 * scale) then
				
				if netplaySelectioni ~= k then
					netplaySelectioni = k
				else
					netplaySelectionFunctions[netplaySelectioni][2]()
				end

				break
			end
		end
	end
end

function netplayKeyPressed(key)
	if netplayTextEntry then
		if key == "backspace" then
			if netplaySelectioni == 1 then
				nickName = nickName:sub(1, -2)
			elseif netplaySelectioni == 2 then
				partyName = partyName:sub(1, -2)
			end
		elseif key == "return" then
			if mobileMode then
				love.keyboard.setTextInput(false)
			end
			
			netplayTextEntry = false
		end
		return
	end

	if key == "s" or key == "down" then
	   netplayChangeSelection(1)
	elseif key == "w" or key == "up" then
		netplayChangeSelection(-1)
	elseif key == "space" then
		netplaySelectionFunctions[netplaySelectioni][2]()	
	elseif key == "escape" then
		util.changeState("title", 2)
	end
end

function netplayChangeSelection(i)
	if netplaySelectioni + i == 3 then
		netplaySelectioni = netplaySelectioni + i
	end

	netplaySelectioni = util.clamp(netplaySelectioni + i, 1, 6)
	
	toolTipScrollTime = 0
	toolTipPosition = netplayX + 8 * scale
end