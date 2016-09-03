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
end

function server:shutdown()
	self.socket:close()
	self.socket = nil
	netplayHost = false
end

function server:update(dt)
	if broadCastTimer < 1 then
		broadCastTimer = broadCastTimer + dt
	else
		self.socket:sendto("Turtle: Invaders;" .. serverName .. ";" .. #self.clients .. ";", "255.255.255.255", 25545)
		broadCastTimer = 0
	end

	data, ip, port = self.socket:receivefrom()

	if data then
		cmd = data:split(";")
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
		elseif cmd[1] == "lobbydata" then
			self:sendDataToClients(data, ip)
		elseif cmd[1] == "chat" then
			self:sendDataToClients(data, ip)

			table.insert(logs, cmd[2])
		elseif cmd[1] == "gameover" then
			self:sendDataToClients(data, ip)
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
	love.filesystem.write("log.txt", table.concat(logs, "\n"))

	os.execute("subl3 ~/.local/share/love/Server/log.txt")

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

function string:split(delimiter) --Not by me
	local result = {}
	local from   = 1
	local delim_from, delim_to = string.find( self, delimiter, from   )
	while delim_from do
		table.insert( result, string.sub( self, from , delim_from-1 ) )
		from = delim_to + 1
		delim_from, delim_to = string.find( self, delimiter, from   )
	end
	table.insert( result, string.sub( self, from   ) )
	return result
end