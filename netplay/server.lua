local socket = require "socket"

server = {}

local data, ip, port
local cmd
local timer = 0
netplay = false
local resynctimer = -5
local resyncconfig = false 

common_chars = {}
clients = {}

local syncnow = true
local synctimer = 0
local synctimemax = 0.03
local shake = "Turtle-Invaders"

function server:load(port)
	netplay = true

	self.udp = socket.udp()

	self.udp:settimeout(0)
	self.udp:setsockname('*', port)
end

function server:update(dt)
	data, ip, port = self.udp:receivefrom()
	if data then
	    timer = 0

	    cmd = data:split(";")

	    --[[if data == shake then
	    	print("We're not alone. Fuck..")
	    	self.udp:sendto(shake .. ";" .. server_name .. ";" .. #clients .. ";" .. gamemodes[gameModei] .. ";" .. difficultytypes[gameDifficulty] .. ";", ip, port)
	    end]]

	    if cmd[1] == "connect" then
	    	if #clients < 4 then
		        server:addClient(cmd[2], cmd[3], cmd[4], ip, port)
		        self.udp:sendto("connected", ip, port)
				self.udp:sendto("clientnumber;" .. #clients, ip, port)
				self.udp:sendto("playsound;coopconnect;", ip, port)
		        resynctimer = 0

		      --  return
		    else
	        	self.udp:sendto("lobbyfull;", ip, port)

	        	return
	        end
	    elseif cmd[1] == "chars" then
	    	server:compareChars(cmd)
	    elseif cmd[1] == "chat" then
	    	server:parseChat(cmd, ip)
	    elseif cmd[1] == "closing" then
			if cmd[4] == "true" then
				server:sendDataToClients("disconnect;server shutting down;")

				--remove the host, make sure they disconnect you dolt!
				self.udp:sendto("disconnect;", ip, port)

				for k = 1, #clients do
					table.remove(clients, k)
				end

				self.udp:close()

				netplay = false
			else
				server:sendDataToClients("playerleft;" .. cmd[2] .. ";" .. cmd[3] .. ";")
				
				server:removeClient(cmd)

				resyncconfig = true
			end
		elseif cmd[1] == "begingame" then
			
			local t = ""
			for k = 1, #clients do
				t = t .. clients[k].character .. ";"
			end

			server:sendNotify(cmd[1] .. ";" .. #clients .. ";" .. t, ip)
		elseif cmd[1] == "isup" then
			self.udp:sendto("yes;" .. #clients .. ";" .. gamemodes[gameModei] .. ";" .. difficultytypes[gameDifficulty] .. ";", ip, port)
			return
		elseif cmd[1] == "ping" then
			self.udp:sendto("pingback;" .. cmd[2] .. ";" .. #clients .. ";", ip, port)
		elseif cmd[1] == "batboss" then
			server:sendDataToClients(data, ip)
		elseif cmd[1] == "coonboss" then
			server:sendDataToClients(data, ip)
		elseif cmd[1] == "bossshot" then
			server:sendDataToClients(data, ip)
		elseif cmd[1] == "batshot" then
			server:sendDataToClients(data, ip)
		elseif cmd[1] == "bosshit" then
			server:sendDataToClients(data, ip)
		elseif cmd[1] == "phoenixboss" then
			server:sendDataToClients(data, ip)
		elseif cmd[1] == "phoenixshot" then
			server:sendDataToClients(data, ip)
		elseif cmd[1] == "phoenixply" then
			server:sendDataToClients(data, ip)
		elseif cmd[1] == "phoenixshieldshot" then
			server:sendDataToClients(data, ip)
		end

		server:syncPlayers(cmd, ip)

		server:syncBats(data, ip)

		if cmd[1] == "spawnenemy" then
			server:sendDataToClients(data, ip)

			return
		end	

		timer = 0
	elseif ip ~= 'timeout' then
    	newNotice("Unknown network error: " .. tostring(ip))

    	self.udp:close()
    elseif ip == "timeout" then
	   
	elseif not data then
		--[[timer = timer + dt

		if timer > 20 then
		   	netplay = false
		   	if not notices[2] then
		   		notices[2] = notice:new("Server shutting down..", true, true)
		   	end
		   	menu_load()
		elseif math.floor(timer)%6 == 0 and math.floor(timer) ~= 0 then
		   	if not notices[1] then
		   		notices[1] = notice:new("No response in " .. math.floor(timer) .. " seconds!", true, true)
		   	end
		end]]
	end

	if resynctimer >= 0 then
		resynctimer = resynctimer + dt
		if resynctimer > .4 then
			resynctimer = -5
			resyncconfig = true
		end
	end

	if resyncconfig then
		server:syncData()
		resyncconfig = false
	end
end

function server:removeClient(cmd)
	if lobby_playerlist[tonumber(cmd[2])] then
		table.remove(lobby_playerlist, tonumber(cmd[2]))
	end

	table.remove(clients, tonumber(cmd[2]))
				
	playsound("coopdisconnect")

	newNotice("Client " .. cmd[3] .. " has disconnected.")
end

function server:syncPlayers(cmd, ip)
	if cmd[1] == "speedx" then
		server:sendDataToClients("speedx;" .. cmd[2] .. ";" .. cmd[3], ip)
	elseif cmd[1] == "shoot" then
		server:sendDataToClients("shoot;" .. cmd[2] .. ";" .. cmd[3], ip)
	elseif cmd[1] == "powerup" then
		server:sendDataToClients("powerup;" .. cmd[2] .. ";" .. cmd[3], ip)
	elseif cmd[1] == "bullettype" then
		server:sendDataToClients("bullettype;" .. cmd[2] .. ";" .. cmd[3], ip)
	elseif cmd[1] == "health" then
		server:sendDataToClients("health;" .. cmd[2] .. ";" .. cmd[3], ip)
	elseif cmd[1] == "specialability" then
		server:sendDataToClients("specialability;" .. cmd[2] .. ";")
	elseif cmd[1] == "specialabilitykeypress" then
		server:sendDataToClients("specialabilitykeypress;" .. cmd[2] .. ";")
	end

	return
end

function server:syncBats(data, ip)
	local cmd = data:split(";")

	if cmd[1] == "batdata" then
		server:sendDataToClients(data, ip)
	elseif cmd[1] == "batdied" then
		server:sendDataToClients(data, ip)
	elseif cmd[1] == "powerspawn" then
		server:sendDataToClients(data, ip)
	end
end

function server:compareChars(charList)
	for k = 1, #charList do
		local v = charList[k]

		if v ~= nil then
			if v == gamechars[k]  then
				table.insert(common_chars, v)
			elseif gamechars[k] ~= nil and v ~= gamechars[k] then
				--print("Both do not have: " .. charList[k])
			end
		end
	end
end

function server:syncData()
	for k, v in pairs(clients) do
		self.udp:sendto("playerdata;" .. k .. ";" .. v.nickname .. ";" .. v.character .. ";" .. v.hosting .. ";", v.ip, v.port)
		server:sendDataToClients("playerdata;" .. k .. ";" .. v.nickname .. ";" .. v.character .. ";" .. v.hosting .. ";", v.ip)
	end
end

function server:addClient(nick, char, host, ip, port)
	table.insert(clients, {nickname = nick, character = char, hosting = host, ip = ip, port = port})

	newNotice("Client " .. nick .. " has joined.")

	if not host then
		playsound("coopconnect")
	end

	--server:sendDataToClients("connectionsuccessful;", ip)
end

function server:parseChat(cmd, ip)
	local chattext = cmd[2]

	server:sendDataToClients("chat;" .. cmd[2], ip)
end

function server:getHostName()
	return nickstr
end

function server:getCharName()
	return gamechars[chari]
end

function server:parseClientMic(cmd, ip)
	local samples, frequency, rate, thing = cmd[2], cmd[3], cmd[4], cmd[5]

	server:sendDataToClients("microphone;" .. samples .. ";" .. frequency .. ";" .. rate .. ";" .. thing .. ";" .. cmd[6], ip)
end

function server:parseBatAbilities(cmd, ip)
	local a = cmd[2]
	local b = cmd[3]

	server:sendDataToClients("batabilities;" .. cmd[1] .. ";" .. a .. ";" .. b, ip)
end

function server:sendNotify(cmd, ip)
	players = #clients
	difficulty = difficultytypes[gameDifficulty]
	gamemode = gamemodes[gameModei]

	nameData = {}
	local addon = ""
	for k = 1, #clients do
		addon = addon .. clients[k].nickname .. ";"
	end

	server:sendDataToClients(cmd, ip)
	server:sendDataToClients("names;" .. addon .. gameDifficulty, ip)
	server:sendDataToClients("gameSetup;" .. gameDifficulty .. ";" .. gameModei .. ";", ip)

	for k = 1, #clients do
		table.insert(gameData, clients[k].character)
		table.insert(nameData, clients[k].nickname)
	end

	shared:timeEvent(1, game_load)
end

function server:sendDataToClients(string, ip)
	for k, v in ipairs(clients) do
		if ip ~= v.ip then
			self.udp:sendto(string, v.ip, v.port)
		end
	end
end