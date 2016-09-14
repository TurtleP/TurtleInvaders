server = {}

function server:init(name)	
	self.clients = {}
	
	logs = {}
	
	self.socket = socket.udp()
	self.socket:settimeout(0)
	
	self.resynctimer = -5
	self.resyncconfig = false

	self.socket:setoption('broadcast', true)
	--self.socket:setoption('dontroute', true)

	self.socket:setsockname("*", 25545)

	serverVersion = "0.26"
	table.insert(logs, "Server initialzed!")
	table.insert(logs, ":: Server version is " .. serverVersion)

	serverName = name or "My Party"
	netplayHost = true

	broadCastTimer = 0
	self.broadCast = false
end

function server:shutdown()
	self.socket:close()
	self.socket = nil
	netplayHost = false
end

function server:update(dt)
	if state == "lobby" then
		self.broadCast = false
		if broadCastTimer < 1 then
			broadCastTimer = broadCastTimer + dt
		else
			self.socket:sendto("Turtle: Invaders;" .. serverName .. ";" .. #self.clients .. ";", "255.255.255.255", 25545)
			broadCastTimer = 0
		end
	elseif state == "game" then
		if not self.broadCast then
			self.socket:setoption('broadcast', false)
			self.broadCast = true
		end
	end

	local data, ip, port = self.socket:receivefrom()

	if data then
		local cmd = data:split(";")

		if cmd[1] == "connect" then
			if #self.clients < 4 then
				self.socket:sendto("connected;" .. #self.clients + 1 .. ";" .. cmd[2] .. ";" .. serverName .. ";", ip, port)
					
				table.insert(logs, cmd[2] .. " has joined the game.")
					
				table.insert(self.clients, {nick = cmd[2], ip = ip, port = port, id = #self.clients + 1})
					
				self.resynctimer = 0
			else
				self.socket:sendto("full;", ip, port)
					
				table.insert(logs, cmd[2] .. " could not join. Lobby is full.")
			end
		end

		if state == "lobby" then
			if cmd[1] == "lobbydata" then
				self:sendDataToClients(data, ip)
			elseif cmd[1] == "chat" then
				self:sendDataToClients(data, ip)

				table.insert(logs, cmd[2])
			elseif cmd[1] == "refresh" then
				self.resynctimer = 0
			end
		elseif state == "game" then
			if cmd[1] == "gameover" then
				self:sendDataToClients(data, ip)
			elseif cmd[1] == "score" then
				serverScores[tonumber(cmd[2])] = {ip, tonumber(cmd[3])}

				if #serverScores > 1 then
					table.sort(serverScores, function(a, b) return a[2] > b[2] end)
				end
			elseif cmd[1] == "blindness" then
				self:sendDataToClients(data, ip)
			elseif cmd[1] == "bomb" then
				self:sendDataToClients(data, serverScores[1][1], port)
			elseif cmd[1] == "confusion" then
				self:sendDataToClients(data, ip, port)
			elseif cmd[1] == "freeze" then
				self:sendDataToClients(data, ip, port)
			end
		end
	end
	
	if self.resynctimer >= 0 then
		self.resynctimer = self.resynctimer + dt
		if self.resynctimer > .4 then
			self.resynctimer = -5
			self.resyncconfig = true
		end
	end

	if self.resyncconfig then
		self:syncData()
		self.resyncconfig = false
	end
end

function server:quit()
	self:destroyServer()
end

function server:destroyServer()
	for k, v in ipairs(self.clients) do
		self.socket:sendto("shutdown;", v.ip, v.port)
	end
	self:shutdown()
end

function server:syncData()
	for i, v in pairs(self.clients) do
		for j, w in pairs(self.clients) do
			if j ~= i then
				self.socket:sendto("playerdata;" .. v.nick .. ";" .. i .. ";", w.ip, w.port)
			end		
		end
	end
end

function server:sendDataToClients(string, ip)
	for k, v in ipairs(self.clients) do
		if ip ~= v.ip then
			self.socket:sendto(string, v.ip, v.port)
		end
	end
end