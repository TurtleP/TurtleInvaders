client = {}

clientTriggers = {}

local clientSyncLobbyTimer = 0
local clientSyncLobbyTime = 0.25

function client:init()
	clientSocket = socket.udp()
	clientSocket:settimeout(0)
end

function client:connect(ip, port)
	if not ip then
		ip = self.ip
	end

	if not port then
		port = self.port
	end

	clientSocket:setpeername(ip, port)
	clientSocket:send("connect;" .. nickName .. ";")
	sendData = true
end

function client:shutdown()
	clientSocket:close()
	clientSocket = nil
	netplayOnline = false
end

function client:close()
	self:shutdown()
	self.ip = nil
	self.port = nil
end

function client:setInformation(ip, port)
	self.ip = ip
	self.port = port
end

function client:hasInformation()
	return self.ip and self.port
end

function client:update(dt)
	local data = clientSocket:receive()

	if data then
		local cmd = data:split(";")

		if cmd[1] == "playerdata" then
			playerID = tonumber(cmd[3])
			
			lobbyCursors[playerID] = newCursor(playerID)

			tabRightSound:play()
		elseif cmd[1] == "lobbydata" then
			local clientID, selection, ready, charNumber = tonumber(cmd[2]), tonumber(cmd[3]), util.toBoolean(cmd[4]), tonumber(cmd[5])

			if not lobbyCursors[clientID] then
				return
			end

			lobbyCursors[clientID]:setPosition(selection)

			lobbyCharacters[clientID] = charNumber

			lobbyCursors[clientID]:setReady(ready)

			if charNumber ~= nil then
				charSelections[selection].selected = true
			else
				charSelections[selection].selected = false
			end
		elseif cmd[1] == "chat" then
			if cmd[2]:find(client:getUsername()) ~= nil then
				blipSound:play()
			end
			lobbyInsertChat(cmd[2])
		elseif cmd[1] == "shutdown" then
			clientSocket:close()

			util.changeState("netplay")

			netplayOnline = false
		end
	end

	if state == "lobby" then
		if clientSyncLobbyTimer < clientSyncLobbyTime then
			clientSyncLobbyTimer = clientSyncLobbyTimer + dt
		else
			clientSocket:send("lobbydata;" .. myLobbyID .. ";" .. lobbyCursors[myLobbyID].selection .. ";" .. tostring(lobbyCursors[myLobbyID].ready) .. ";" .. tostring(lobbyCharacters[myLobbyID]) .. ";")
			clientSyncLobbyTimer = 0
		end
	end

	for x = #clientTriggers, 1, -1 do
		clientSocket:send(clientTriggers[x])
		table.remove(clientTriggers, x)
	end
end

function client:getUsername()
	return nickName
end

function client:disconnect()
	clientSocket:send("disconnect;" .. myLobbyID .. ";")
end