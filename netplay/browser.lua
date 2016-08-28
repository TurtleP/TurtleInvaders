function browserInit()
	if not clientSocket then
		client:init()
		clientSocket:setsockname("255.255.255.255", 25545)
	end

	browserX = love.graphics.getWidth() / 2 - 180 * scale
	browserY = love.graphics.getHeight() * 0.11
	browserWidth = 360
	browserHeight = 200
	
	mainFont = love.graphics.newFont("graphics/monofonto.ttf", 24 * scale)
	logoFont = love.graphics.newFont("graphics/monofonto.ttf", 22 * scale)
	
	browserTabs = {}
	
	serverList = {}

	browserSelectioni = 1
	netplayTimeout = 0

	browserSmoothScroll = 0
	browserIsScrolling = false

	browserPingTimer = 0
	browserConnect = false
end

function browserUpdate(dt)
	if not browserConnect then
		local data, ip, port = clientSocket:receivefrom()

		if data then
			local serverData = data:split(";")
			if serverData[1] ~= "Turtle: Invaders" then
				if serverData[1] == "pong" then
					for k, v in pairs(serverList) do
						if v.ip == ip then
							v:ping()
							v:setData(serverData[2])
						end
					end
				end
				return
			else
				for k, v in pairs(serverList) do
					if v.ip == ip then
						return
					end
				end
			end

			table.insert(serverList, newRow(serverData[2] .. ";" .. serverData[3] .. ";", browserX, browserY + (28 * scale) + (#serverList * 26) * scale, ip, port))
		end
	

		browserPingTimer = browserPingTimer + dt
		if browserPingTimer > 1 then
			for k, v in pairs(serverList) do
				if v.remove then
					table.remove(serverList, k)
				end
				clientSocket:sendto("ping;", v.ip, v.port)
			end
		end
	else
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
	end

	for k, v in pairs(serverList) do
		v:update(dt)
	end

	if mobileMode then
		return
	end

	if #serverList > 6 then
		if browserSelectioni < #serverList - 5 then
			browserSmoothScroll = browserSmoothScroll + (((browserSelectioni - 1) * 26) - browserSmoothScroll) * 6 * dt
		else
			browserSmoothScroll = browserSmoothScroll + (((#serverList - 6) * 26) - browserSmoothScroll) * 6 * dt
		end
	end
end

function browserDraw()
	if mobileMode then
		love.graphics.draw(backImage, util.getHeight() * 0.01, util.getHeight() * 0.011)
	end

	love.graphics.setFont(mainFont)
	
	love.graphics.print("Party Name", browserX, browserY)

	love.graphics.print("Players", browserX + (browserWidth * scale) - mainFont:getWidth("Players"), browserY) 
	
	love.graphics.setFont(logoFont)

	for k, v in pairs(serverList) do
		love.graphics.push()

		love.graphics.translate(0, -math.floor(browserSmoothScroll * scale))

		love.graphics.setScissor(browserX, browserY + (28 * scale), browserWidth * scale, 156 * scale)
		if browserSelectioni == k then
			love.graphics.setColor(255, 255, 255)
		else
			love.graphics.setColor(128, 128, 128)
		end
		v:draw()
		love.graphics.setScissor()

		love.graphics.pop()
	end

	love.graphics.setColor(255, 255, 255)

	if #serverList > 6 and browserSelectioni < #serverList - 5 then
		for k = 1, 3 do
			love.graphics.circle("fill", browserX + 100 * scale + (k - 1) * 80 * scale, browserY + browserHeight * scale, 3 * scale)
			love.graphics.circle("line", browserX + 100 * scale + (k - 1) * 80 * scale, browserY + browserHeight * scale, 3 * scale)
		end
	end
end

function browserKeyPressed(key)
	if key == "w" or key == "up" then
		browserSelectioni = math.max(browserSelectioni - 1, 1)
	elseif key == "s" or key == "down" then
		browserSelectioni = math.min(browserSelectioni + 1, #serverList)
	elseif key == "space" or key == "return" then
		client:shutdown()

		browserConnect = true
		if not clientSocket then
			client:init()
			client:connect(serverList[browserSelectioni].ip, serverList[browserSelectioni].port)
		end
	elseif key == "escape" then
		util.changeState("netplay")
	end
end

function browserTouchMoved(id, x, y, dx, dy)
	if dy ~= 0 then
		if isTapped(browserX, browserY + (28 * scale), browserWidth * scale, browserHeight * scale) then
			browserSmoothScroll = util.clamp(browserSmoothScroll - dy / 6, 0, (#serverList - 6) * 26)
		end
		browserIsScrolling = true
	else
		browserIsScrolling = false

		if not browserIsScrolling then
			for k, v in pairs(serverList) do
				if isTapped(v.x, math.floor(v.y - browserSmoothScroll * scale), browserWidth * scale, v.height * scale) then
					if browserSelectioni ~= k then
						browserSelectioni = k
					else
						client:shutdown()

						browserConnect = true
						if not clientSocket then
							client:init()
							client:connect(v.ip, v.port)
						end
					end
				end
			end
		end
	end

	if isTapped(util.getWidth() * 0.01, util.getHeight() * 0.011, 16 * scale, 16 * scale) then
		client:shutdown()
		util.changeState("netplay")
	end
end

function newRow(data, x, y, ip, port)
	local row = {}
	
	row.x = x
	row.y = y

	row.height = 20

	row.text = data:split(";")

	row.ip = ip
	row.port = tonumber(port)
	
	row.isPinged = false

	row.timer = 0
	
	function row:update(dt)
		if self.isPinged then
			self.timer = self.timer + dt
			if self.timer > 3 then
				self.remove = true
			else
				self.isPinged = false
				self.timer = 0
			end
		end
	end

	function row:ping()
		self.isPinged = true
	end

	function row:setData(playerCount)
		self.text[2] = playerCount
	end

	function row:draw()
		love.graphics.print(self.text[1], self.x, self.y)

		love.graphics.print(self.text[2] .. "/4", self.x + (browserWidth * scale) - (mainFont:getWidth("Players") / 2 + logoFont:getWidth(self.text[2] .. "/4") / 2), self.y)
	end

	return row
end