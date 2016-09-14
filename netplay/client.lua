client = {}

clientTriggers = {}

local clientSyncLobbyTimer = 0
local clientSyncLobbyTime = 0.25

local clientSyncScoreTimer = 0
local clientSyncScoreTime = 0.50

local clientIsBlind = false
local blindnessFade = 0
local blindnessTimer = 0

local clientIsConfused = false
local confusionTimer = 0

local clientIsFrozen = false
local frozenTimer = 0

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

local debug = ""
function client:update(dt)
	local data = clientSocket:receive()
	
	if data then
		local cmd = data:split(";")

		if state == "lobby" then
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
			end
		else
			if cmd[1] == "shutdown" then
				clientSocket:close()

				util.changeState("netplay")

				netplayOnline = false
			elseif cmd[1] == "gameover" then
				table.insert(clientScores, {cmd[2], tonumber(cmd[3]), tonumber(cmd[4])})
			elseif cmd[1] == "blindness" then
				clientIsBlind = true
			elseif cmd[1] == "bomb" then
				if objects["player"][1] then
					objects["player"][1]:addLife(-1)
					
					local oldScore = score
					gameAddScore(-(oldScore * 0.10))

					gameCreateExplosion(objects["player"][1])
				end
			elseif cmd[1] == "confusion" then
				clientIsConfused = true
			elseif cmd[1] == "freeze" then
				clientIsFrozen = true
			end
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

	if not gameOver then
		if state == "game" then
			if clientSyncScoreTimer < clientSyncScoreTime then
				clientSyncScoreTimer = clientSyncScoreTimer + dt
			else
				clientSocket:send("score;" .. myLobbyID .. ";" .. score .. ";")
				clientSyncScoreTime = 0
			end
		end
	else
		if not clientGameOver then
			table.insert(clientScores, {nickName, score, lobbyCursors[myLobbyID].selection})

			clientSocket:send("gameover;" .. nickName .. ";" .. score .. ";" .. lobbyCursors[myLobbyID].selection .. ";")
			
			clientGameOver = true
		else
			if #clientScores == #lobbyCursors then
				gameFinished = true
			end
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

--[[
	Powerup Stuff Here
--]]

local oldPlayerShoot = player.shoot
local oldGameDraw = gameDraw
local oldGameUpdate = gameUpdate

player.shoot = function(self)
	if clientIsFrozen then
		return
	end

	if self.shootingTimer == 0 then
		if self.powerup == "blindness" then
			clientSocket:send("blindness;")

			self:setPowerup("none")
			return
		elseif self.powerup == "bomb" then
			clientSocket:send("bomb;")

			self:setPowerup("none")
			return
		elseif self.powerup == "freeze" then
			clientSocket:send("freeze;")

			self:setPowerup("none")
			return
		elseif self.powerup == "confusion" then
			clientSocket:send("confusion;")

			self:setPowerup("none")
			return
		end
	end

	oldPlayerShoot(self)
end

local oldPlayerMoveLeft = player.moveLeft
local oldPlayerMoveRight = player.moveRight
local oldPlayerDie = player.die

player.moveLeft = function(self, move)
	if clientIsConfused then
		self.rightkey = move
		return
	elseif clientIsFrozen then
		return
	end

	oldPlayerMoveLeft(self, move)
end

player.moveRight = function(self, move)
	if clientIsConfused then
		self.leftkey = move
		return
	elseif clientIsFrozen then
		return
	end

	oldPlayerMoveRight(self, move)
end

function gameUpdate(dt)
	oldGameUpdate(dt)

	if clientIsBlind then
		blindnessFade = math.min(blindnessFade + 0.6 * dt, 1)

		if blindnessTimer < 8 then
			blindnessTimer = blindnessTimer + dt
		else
			clientIsBlind = false
			blindnessTimer = 0
		end
	else
		blindnessFade = math.max(blindnessFade - 0.6 * dt, 0)
	end

	if clientIsConfused then
		if confusionTimer < 6 then
			confusionTimer = confusionTimer + dt
		else
			clientIsConfused = false
			confusionTimer = 0
		end
	elseif clientIsFrozen then
		if frozenTimer < 6 then
			frozenTimer = frozenTimer + dt
		else
			clientIsFrozen = false
			frozenTimer = 0
		end
	end
end

function gameDraw()
	oldGameDraw()

	if clientIsBlind then
		love.graphics.setColor(0, 0, 0, 235 * blindnessFade)
		love.graphics.rectangle("fill", 0, 0, util.getWidth(), util.getHeight())
	end
end