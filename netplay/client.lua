local socket = require "socket"

-- the address and port of the server
local address, port = "localhost", 12345

local cmd -- entity is what we'll be controlling
local updaterate = 0.03 -- how long to wait, in seconds, before requesting an update

client = {}

local t = 0


servers = {}

local pingtime = 0
local maxping = 1

local enemysync = 0
local enemymaxsync = 0.20

clpingtimer = 0
clping = 0

local playersync = 0
local playersyncmax = 0.03

function client:newUDP()
	udp = socket.udp()
	udp:settimeout(0) --don't buffer wait for data
end

function client:load(address, port, nick)
	clientonline = true
	nickstr = nick
	
	saveData("netplay")

	isnetworkhost = false
	if address == "localhost" then
		isnetworkhost = true
	end

	client:newUDP()

	client:connect(address, port)

	clientcontrols = {}
end

function client:searchForServerInit()
	local host = "*"
	local port = 25546

	if not udp then
		client:newUDP()
	end

	udp:setsockname(host, port)
	udp:setoption("broadcast", true)
	udp:settimeout(.1)
end

function client:searchForServers()
	local shake = "Turtle-Invaders"

	local err = false

	local serv_address = ""
	local serv_port = ""

	if not err then
		message, address, port, err = udp:receivefrom()

		if message then
			local data = message:split(";")

			if data[1] == shake then
				serv_address = address
				serv_port = port

				local found = false
				if #searchBoxData > 0 then
					for k = 1, #searchBoxData do
						if searchBoxData[k].address == address and searchBoxData[k].port == port then
							found = true
						end
					end
				end

				if not found then
					table.insert(searchBoxData, newBar(data[2], address, port, #searchBoxData+1, true))
				end

				for k, v in pairs(searchBoxData) do
					if v.address == address and v.port == port then
						v:setPlayers(data[3])
						v:setDifficulty(data[5])
						v:setPing(math.floor( love.timer.getTime() / 1000 ))
					end
				end

				return
			end
		end

		if err then
			error(err)
		end

		udp:sendto(shake, "255.255.255.255", 25545)
	end
end

function client:connect(address, port)
	udp:setpeername(address, port)

	local udpString = tostring(udp)

	local split = udpString:split(":")

	if split[1] == "udp{connected}" then
   		udp:send("connect;" .. client:getName() .. ";" .. client:getChar() .. ";" .. tostring(isnetworkhost))
    else
    	newNotice("Failed to connect to " .. address .. ":" .. port, true)
    	udp:close()

    --	return
   	end
end

function client:update(dt)
    data, msg = udp:receive()

    if data then

        cmd = data:split(";")
        if not objects then
			client_generallobbysyncs(cmd)

			if cmd[1] == "chat" then
				client:parseChat(cmd)
			elseif cmd[1] == "begingame" or cmd[1] == "names" or cmd[1] == "gameSetup" then
				client:parseNotify(cmd)
			elseif cmd[1] == "playerleft" then
				client:removeClient(cmd)
			elseif cmd[1] == "lobbyfull" then
				newNotice("Lobby is full, refused!", true)
			end

			return
		elseif state == "game" then
			client:playerSync(cmd)

			if cmd[1] == "batdata" then
				client:setBatData(cmd)
			elseif cmd[1] == "spawnenemy" then
				client:spawnEnemy(cmd)
			elseif cmd[1] == "powerspawn" then
				dropPowerup(round(tonumber(cmd[3]), 2), round(tonumber(cmd[4]), 2), cmd[2], true)
			elseif cmd[1] == "batboss" then
				client:syncBatBoss(cmd)
			elseif cmd[1] == "coonboss" then
				client:syncCoonBoss(cmd)
			elseif cmd[1] == "bossshot" then
				objects["boss"][1].maneuver = tonumber(cmd[2])
				objects["boss"][1]:shoot()
			elseif cmd[1] == "batshot" then
				for k, v in ipairs(objects["enemies"]) do
					if v.id == tonumber(cmd[2]) then
						v:shoot(cmd[3])
					end
				end
			elseif cmd[1] == "bosshit" then --boss shit lel
				if objects["boss"][1] then
					objects["boss"][1].hpbar:damage(tonumber(cmd[2]), true)
				end
			elseif cmd[1] == "phoenixshot" then
				if objects["boss"][1] then
					objects["boss"][1]:flameYo()
				end
			elseif cmd[1] == "phoenixply" then
				if objects["boss"][1] then
					objects["boss"][1].nearestply = tonumber(cmd[2])
					objects["boss"][1]:charge()
				end
			elseif cmd[1] == "phoenixshieldshot" then
				if objects.phoenixshield then
					objects.phoenixshield[1]:shotted(true)
				end
			end
		end

		if cmd[1] == "notice" then
			newNotice(cmd[2])

			return
		end
	end

	if not data and msg ~= 'timeout' and msg ~= "closed" then
		print(msg)
		newNotice("Server is down or does not exist!", true)
		udp:close()
		clientonline = false
		return
	end

   --[[	if msg ~= 'timeout' then
        client:disconnect()
        newNotice("Server says: " .. msg)
        menu_load()
    end]]
end

function client:removeClient(cmd)

	local i = convertclienttoplayer(tonumber(cmd[2]))

	if lobby_playerlist[i] then
		table.remove(lobby_playerlist, i)
	end

	if objects then
		objects["turtle"][i]:die()
	end

	playsound("coopdisconnect")
					
	newNotice("Client " .. cmd[3] .. " has disconnected.")
end


function client:netUpdate(dt)
	if objects then
		if isnetworkhost then
			enemysync = enemysync + dt
			if enemysync >= enemymaxsync then

				for k, v in pairs(objects["enemies"]) do
					udp:send("batdata;" .. v.id .. ";" .. round(v.x, 2) .. ";" .. round(v.y, 2) .. ";" .. v.speedx .. ";" .. v.speedy .. ";" .. v.direction ..
					";" .. v.abilityA .. ";" .. v.abilityB .. ";" .. v.delay .. ";" .. v.powerup .. ";" .. v.armor .. ";" .. v.pattern .. ";"
					.. v.phantomtime .. ";" .. tostring(v.circle) .. ";" .. v.ver .. ";" .. v.hor .. ";" .. v.tl .. ";" .. v.md .. ";" .. v.tr .. ";")
				end

				if objects["boss"][1] then

					for k, v in pairs(objects["boss"]) do

						if v.type == "boss" then
							udp:send("batboss;" .. round(v.x, 2) .. ";" .. round(v.y, 2) .. ";" .. v.speedx .. ";")
						elseif v.type == "coon" then
							udp:send("coonboss;" .. round(v.x, 2) .. ";" .. round(v.y, 2) .. ";" .. v.flashtimer .. ";" .. v.dist .. ";" .. v.teleporttimer .. ";")
						else
							udp:send("phoenixboss;" .. round(v.x, 2) .. ";" .. round(v.y, 2) .. ";")
						end

					end

				end

				enemysync = 0
			end
		end

		if playersync < playersyncmax then
			playersync = playersync + dt
		else
			udp:send("move;" .. networkclientid .. ";" .. tostring(objects["turtle"][networkclientid].rightkey) .. ";" .. tostring(objects["turtle"][networkclientid].leftkey))
			playersync = 0
		end
	end

	for k = #onlinetriggers, 1, -1 do
		udp:send(onlinetriggers[k])
		table.remove(onlinetriggers, k)
	end
end

function client:syncBatBoss(cmd)
	if not isnetworkhost then
		for k, v in pairs(objects["boss"]) do
			v.x = tonumber(cmd[2])
			v.y = tonumber(cmd[3])

			v.speedx = tonumber(cmd[4])
		end
	end
end

function client:syncCoonBoss(cmd)
	for k, v in pairs(objects["boss"]) do
		v.x = tonumber(cmd[2])
		v.y = tonumber(cmd[3])

		v.flashtimer = tonumber(cmd[4])
		v.dist = tonumber(cmd[5])
		v.teleporttimer = tonumber(cmd[6])
	end
end

function client:disconnect(reason, warn)
	if networkclientid then
		udp:send("closing;" .. networkclientid .. ";" .. nickstr .. ";" .. tostring(isnetworkhost) .. ";")

		playsound("coopdisconnect")
	end

	local r = ""
	if reason then
		r = " Reason: " .. reason
	end

	newNotice("Disconnected." .. r, warn)
	
	controls = {unpack(clientcontrols)}

	clientonline = false
	udp:close()
	menu_load()
end

function client:playerSync(cmd)
	local id = tonumber(cmd[2])

	print("client: " .. networkclientid, id)

	if objects["turtle"][id] then
		if cmd[1] == "move" then
			objects["turtle"][id].rightkey = toboolean(cmd[3])
			objects["turtle"][id].leftkey = toboolean(cmd[4])
		elseif cmd[1] == "shoot" then
			client:shootBullet(id, cmd[3])
		elseif cmd[1] == "bullettype" then
			client:setBulletType(cmd)
		elseif cmd[1] == "powerup" then
			client:powerup(cmd)
		elseif cmd[1] == "health" then
			client:giveLife(cmd)
		elseif cmd[1] == "specialabilitykeypress" then
			objects["turtle"][id]:specialUp(true)
		elseif cmd[1] == "specialability" then
			objects["turtle"][id]:specialUp(true)
		end
	end
end

function client_connectToLobby()
	local nick = nickstr
	lobby_load(nick, gamechars[charconfigi], isnetworkhost, 1)
end

function client_generallobbysyncs(cmd)
	if state == "netplay" and cmd[1] ~= "connected" then
		newNotice("Server is down. Try again later.", true)
	end

	if cmd[1] == "connected" then
		client_connectToLobby()
	elseif cmd[1] == "startgame" then
		players = tonumber(cmd[2])
		game_load()
	elseif cmd[1] == "clientnumber" then
		networkclientid = tonumber(cmd[2])

		print("ayy lmao network id: ", networkclientid)

		clientcontrols[networkclientid] = controls[playerconfig]
		controls = {}

		controls[networkclientid] = {}

		if not controls[networkclientid][1] then
			controls[networkclientid][1] = ""
		end

		if not controls[networkclientid][2] then
			controls[networkclientid][2] = ""
		end

		if not controls[networkclientid][3] then
			controls[networkclientid][3] = ""
		end

		if not controls[networkclientid][4] then
			controls[networkclientid][4] = ""
		end

		controls[networkclientid] = clientcontrols[networkclientid]
	elseif cmd[1] == "playerdata" then
		playerid = convertclienttoplayer(tonumber(cmd[2]))

		--print(tostring(isnetworkhost), "[PLAYERDATA] My ID is :: " .. playerid)
		if not lobby_playerlist then
			newNotice("Failed to connect to lobby!", true)
			client:disconnect()
		end

		if not lobby_playerlist[playerid] then
			lobby_playerlist[playerid] = {}
		end
		
		lobby_playerlist[playerid].nick = cmd[3]
		lobby_playerlist[playerid].char = cmd[4]
		lobby_playerlist[playerid].hosting = toboolean(cmd[5])
		lobby_playerlist[playerid].id = playerid
	elseif cmd[1] == "disconnect" then
		client:disconnect(cmd[2], toboolean(cmd[3]))
	elseif cmd[1] == "playsound" then
		playsound(cmd[2])
	end
end

function client:sendUDP(string)
	udp:send(string)
end

function client:spawnPowerup(cmd)
	if objects["enemies"][tonumber(cmd[2])] then
		objects["enemies"][tonumber(cmd[2])]:droppowerup(false, true, cmd[3])
	end
end

function convertclienttoplayer(clientnumber)
	if clientnumber < networkclientid then 
		return clientnumber+1
	elseif clientnumber == networkclientid then
		return 1
	elseif clientnumber > networkclientid then
		return clientnumber
	end
end

function toboolean(var)
	if type(var) == "string" then
		if var == "true" then
			return true
		else
			return false
		end
	end
end

function client:getName()
	return nickstr
end

function client:getChar()
	return gamechars[charconfigi]
end

function client:isHosting()
	return isnetworkhost
end

function client:parseChat(cmd)
	table.insert(lobby_chat, cmd[2])
end

function client:spawnEnemy(cmd)
	if not isnetworkhost then
		newenemy(tonumber(cmd[2]), tonumber(cmd[3]), tonumber(cmd[4]), true)
	end
end

function client:parseNotify(cmd)
	if cmd[1] == "begingame" then
		newNotice("Game starting..")
		players = tonumber(cmd[2])
		gamestarting = true
		difficulty = difficultytypes[tonumber(cmd[#cmd])]

		nameData = {}

		for k = 3, #cmd-1 do
			table.insert(gameData, cmd[k])
		end
	end

	if cmd[1] == "names" then
		for k = 2, #cmd-1 do
			table.insert(nameData, cmd[k])
		end
	end

	if cmd[1] == "gameSetup" then
		difficulty = difficultytypes[tonumber(cmd[2])]
		gamemode = gamemodes[tonumber(cmd[3])]

		shared:timeEvent(1, game_load)
	end
end

function client:shootBullet(plyId, powerup)
	if objects["turtle"][plyId] then
		objects["turtle"][plyId]:shootbullet(powerup:lower(), true)
	end
end

function client:setBulletType(cmd)
	local i = tonumber(cmd[3])

	if objects["turtle"][i] then
		objects["turtle"][i]:setPowerup(cmd[2], true, true)
	end
end

function client:powerup(cmd)
	local i = tonumber(cmd[3])

	if objects["turtle"][i] then
		objects["turtle"][i]:setPowerup(cmd[2], false, true)
	end
end

function client:giveLife(cmd)
	local i = tonumber(cmd[3])

	if objects["turtle"][i] then
		objects["turtle"][i]:addLife(tonumber(cmd[2]), true)
	end
end

function client:setBatData(cmd)
	if not isnetworkhost then
		for k, v in ipairs(objects["enemies"]) do
			if tonumber(cmd[2]) == v.id then

				v.x = tonumber(cmd[3])
				v.y = tonumber(cmd[4])

				v.speedx = tonumber(cmd[5])
				v.speedy = tonumber(cmd[6])
				v.direction = tonumber(cmd[7])
				v.abilityA = cmd[8]
				v.abilityB = cmd[9]
				v.delay = tonumber(cmd[10])
				v.powerup = cmd[11]
				v.armor = tonumber(cmd[12])
				v.pattern = cmd[13]
				v.phantomtime = tonumber(cmd[14])

				v.circle = toboolean(cmd[15])
				v.ver = tonumber(cmd[16])
				v.hor = tonumber(cmd[17])
				v.tl = tonumber(cmd[18])
				v.md = tonumber(cmd[19])
				v.tr = tonumber(cmd[20])
			end
		end
	end
end

function client:removeBullet(cmd)
	if objects["bullets"][tonumber(cmd[2])] then
		objects["bullets"][tonumber(cmd[2])].kill = true
	end
end

function client:getScore(score)
	score = tonumber(score)
end

function client:sendShoot(string)
	udp:send("shoot;" .. string)
end

function client:sendMove(string)
	udp:send("move;" .. string)
end

function client:sendStopMove(string)
	udp:send("stop;" .. string)
end

function client:sendChat(string)
	udp:send("chat;" .. string)
end

function client:sendNotify(dirtystring) --dirty: internal name, clean: nice name
	if client:isHosting() and dirtystring == "begingame" then
		if #lobby_playerlist > 1 then
			newNotice("Game starting..")
		end
	end

	udp:send(dirtystring .. ";")
end

function client:sendBatRemove(string)
	if state == "game" then
		udp:send("batremove;" .. string)
	end
end