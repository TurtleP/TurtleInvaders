function netplay_load()
	state = "netplay"
	rectwidth = 524*scale
	rectheight = 264*scale
	rectx, recty = (600 * scale)/2-(rectwidth)/2, (300 * scale)/2-(rectheight)/2

	randombattimer = love.math.random(10)
	netplayenemies = {}
	selectioni = 1
	tabi = 1
	
	hostport = "25545"
	ip = ""
	port = "25545"
	
	favorites = {}
	nickstr = nicknames[love.math.random(#nicknames)]
	charconfigi = 1
	server_name = "My Server"

	loadData("netplay")

	favoritename = ""

	netgui =
	{
		["nick"] = gui:new("textfield", rectx+(142*scale), (recty+170*scale), 12, nickstr),
		["backchar"] = gui:new("imagebutton", rectx+(16*scale), recty+(176*scale), 16*scale, 16*scale, graphics["arrows"], arrowquads[1], netplay_changeChar, {false}),
		["nextchar"] = gui:new("imagebutton", rectx+(120*scale), recty+(176*scale), 16*scale, 16*scale, graphics["arrows"], arrowquads[2], netplay_changeChar, {true}),
		--["favorites"] = gui:new("button", rectx+(291*scale), recty+(198*scale), "Favorite Servers", netplaysearch_load),
		["ip"] = gui:new("textfield", rectx+(291*scale), recty+(82*scale), 15, ip),
		["port"] = gui:new("textfield", rectx+(349*scale), recty+(111*scale), 5, port),
		--["name"] = gui:new("textfield", rectx+(350*scale), recty+(142*scale), 7, favoritename),

		["hostport"] = gui:new("textfield", rectx+(73*scale), recty+(58*scale), 5, hostport),
		--["servname"] = gui:new("textfield", rectx+(73*scale), recty+(194*scale), 10, server_name),
		["hostnow"] = gui:new("button", rectx+(21*scale), recty+(232*scale), "Host Now", netplay_connect, {true}),
		["joinnow"] = gui:new("button", rectx+(414*scale), recty+(232*scale), "Join Now", netplay_connect, {false}),
		["configadd"] = gui:new("imagebutton", rectx+(306*scale), recty+(199*scale), 16*scale, 16*scale, graphics["arrows"], arrowquads[2], netplay_changeConfig, {true}),
		["configminus"] = gui:new("imagebutton", rectx+(268*scale), recty+(199*scale), 16*scale, 16*scale, graphics["arrows"], arrowquads[1], netplay_changeConfig, {false})
	}

	netgui["hostnow"].unHighlightColor = {0, 255, 0}
	netgui["joinnow"].unHighlightColor = {0, 255, 0}

	netgui["hostnow"].backgroundColor = {13, 26, 1}
	netgui["joinnow"].backgroundColor = {13, 26, 1}

	clientsuccess = ""
	successtimer = 0

	serverupi = 2
	checkdatipdoe = true
	savei = 1
	playerconfig = 1

	netplaystate = "main"
end

function netplay_draw()
		love.graphics.setColor(32, 32, 32, 192)

		--draw the UI thingy	
		local x, y = rectx, recty

		love.graphics.setColor(32, 32, 32, 192)
		love.graphics.rectangle("fill", x, y, rectwidth, rectheight)
		love.graphics.setColor(255, 255, 255, 255)
		love.graphics.rectangle("line", x+(2*scale), y+(2*scale), rectwidth-(4*scale), rectheight-(4*scale))

		love.graphics.setFont(menubuttonfont)
		love.graphics.print("Online Co-Op Setup", x+(rectwidth/2)-menubuttonfont:getWidth("Online Co-Op Setup")/2, y+(8*scale))

		love.graphics.setFont(font4)

		--UI BAR
		love.graphics.rectangle("line", x+(14*scale), y+(28*scale), 497*scale, 0.5*scale)

		--Join section
		love.graphics.rectangle("line", x+(291*scale), y+(54*scale), 131*scale, 0.5*scale)

		love.graphics.setColor(0, 127, 127)
		love.graphics.print("JOIN A GAME", x+(294*scale), y+(37*scale))

		love.graphics.setColor(255, 255, 255)
		love.graphics.print("IP ADDRESS:", x+(294*scale), y+(63*scale))

		love.graphics.print("PORT:", x+(294*scale), y+(116*scale))

		--love.graphics.rectangle("line", x+(291*scale), y+(170*scale), 223*scale, 0.5*scale)

		--PLAYAH SECTION, DAWG
		--love.graphics.rectangle("line", x+(36*scale), (y+141*scale), 80*scale, 80*scale)

		love.graphics.print("NICKNAME:", x+(144*scale), (y+150*scale))

		love.graphics.print("Control Set:  " .. playerconfig, x+(142*scale), y+(202*scale))
		--love.graphics.print(playerconfig, x+(238*scale), y+(202*scale))

		--UI BAR FOR SERVER CRAP
		love.graphics.rectangle("line", x+(14*scale), (y+136*scale), 496*scale, 0.5*scale)

		love.graphics.setColor(0, 127, 127)
		love.graphics.print("HOST A GAME", x+(20*scale), y+(37*scale))

		love.graphics.setColor(255, 255, 255)

		love.graphics.print("PORT:", x+(20*scale), y+(63*scale))

		love.graphics.setColor(240, 56, 56)

		love.graphics.print("MUST BE UDP FORWARDED!", x+(20*scale), y+(90*scale))

		--[[if serverupi == 2 then
			love.graphics.setFont(font9)
			love.graphics.print("SERVER IS \nUNAVAILABLE!", x+(290*scale), y+(232*scale))
			love.graphics.setFont(font4)

			netgui["joinnow"].highlightColor = {255, 0, 0}
			netgui["joinnow"].unHighlightColor = {200, 0, 0}
			netgui["joinnow"].backgroundColor = {64, 0, 0}
		else
			netgui["joinnow"].backgroundColor = {13, 26, 1}
			netgui["joinnow"].unHighlightColor = {0, 255, 0}
		end]]

		love.graphics.setColor(255, 255, 255)

		love.graphics.rectangle("line", x+(15*scale), (y+54*scale), 131*scale, 0.5*scale)

		--dividing bar thingy
		love.graphics.rectangle("line", x+(283*scale), y+(35*scale), 0.5*scale, 98*scale)

		--bar before host button
		love.graphics.rectangle("line", x+(15*scale), y+(226*scale), 262*scale, 0.5*scale)
		love.graphics.rectangle("line", x+(291*scale), y+(226*scale), 223*scale, 0.5*scale)

		--draw the check or x if a server is up or down. The 'or' is because it becomes nil
		--love.graphics.draw(graphics["serverexists"], serverupquads[(serverupi or 1)], x+(466*scale), y+(83*scale), 0, scale, scale)

		--love.graphics.draw(graphics["save"], savequads[savei], x+(490*scale), y+(83*scale), 0, scale, scale)

	--	love.graphics.print("Character:\n" .. gamechars[charconfigi], x+(144*scale), y+(160*scale))
		local v = characters[gamechars[charconfigi]]

		if v.isAnimated then
			love.graphics.draw(v.graphic, v.animationQuads[v.animationQuad], x+(36*scale)+((80*scale)/2)-((v.width/2)*(scale+1)), y+(41*scale)+(280*scale)/2-((v.height/2)*(scale+1)), 0, scale+1, scale+1)
		else
			love.graphics.draw(v.graphic, x+(36*scale)+((80*scale)/2)-((v.width/2)*(scale+1)), y+(41*scale)+(280*scale)/2-((v.height/2)*(scale+1)), 0, scale+1, scale+1)
		end

		love.graphics.setColor(255, 255, 255)

		for k, v in pairs(netgui) do
			v:draw()
		end
end

function netplay_textinput(t)
	netgui["nick"]:textinput(t)

	if tonumber(t) or t == "." then
		netgui["ip"]:textinput(t)
	end

	if tonumber(t) then
		netgui["hostport"]:textinput(t)
		netgui["port"]:textinput(t)
	end
end

function netplay_update(dt)
	randombattimer = randombattimer - dt 
	
		local v = characters[gamechars[chari]]

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
		
		for k, v in pairs(netgui) do
			v:update(dt)
		end
end

function netplay_keypressed(key)
	if key == "escape" then
		menu_load(false, false, true)
	elseif key == "return" then
		if netgui["nick"].input then
			nick = netgui["nick"].text
			netgui["nick"].input = false
		end
	end
	
	if key == "v" and (love.keyboard.isDown("lctrl") or love.keyboard.isDown("rctrl")) then
		local s = love.system.getClipboardText()
		if type(s) == "string" then
			for i = 1, string.len(s) do
				local v = string.sub(s, i, i)
				if v == "." or tonumber(v) then
					netgui["ip"]:textinput(v)
				end
			end
		end
	end
	
	for k, v in pairs(netgui) do
		v:keypressed(key)
	end
end

function netplay_mousepressed(x, y, button)

	for k, v in pairs(netgui) do
		v:mousepressed(x, y, button)
	end

end

function netplay_changeConfig(var)
	if var then
		playerconfig = playerconfig + 1
		if playerconfig > 4 then
			playerconfig = 1
		end
	else
		playerconfig = playerconfig - 1
		if playerconfig < 1 then
			playerconfig = 4
		end
	end
end

function netplay_changeChar(add)
	if add then
		if charconfigi < #gamechars then
			charconfigi = charconfigi + 1
		else
			charconfigi = 1
		end
	else
		if charconfigi > 1 then
			charconfigi = charconfigi - 1
		else
			charconfigi = #gamechars
		end
	end
end

function netplay_connect(hosting)
	if hosting then
		server:load(tonumber(netgui["hostport"].text))
		client:load("localhost", tonumber(netgui["hostport"].text), netgui["nick"].text)
	else
		client:load(netgui["ip"].text, tonumber(netgui["port"].text), netgui["nick"].text)
	end

	saveData("netplay")
end