function netplaysearch_load()
	state = "netplaysearch"

	client:searchForServerInit()

	serarch_boxWidth = 580
	serarch_boxHeight = 210

	search_boxX = (gameW / 2 - serarch_boxWidth / 2)
	search_boxY = (gameH / 2 - serarch_boxHeight / 2)

	local names = {"Type", "Name", "Players", "Mode", "Ping"}

	searchtabs = {}
	local offset = 0
	local add = 0

	tabMul = 1/#names

	for k = 1, #names do
		if k > 1 then
			offset = offset + ( font4:getWidth(names[k - 1]) / scale)
			add = add + 6
		else
			offset = 0
			add = 0
		end
		searchtabs[k] = newTab(names[k], (search_boxX + 1) + (k - 1) * (serarch_boxWidth * tabMul), search_boxY + 1)
	end

	searchBoxData = {}

	for k = 1, #favorites do
		--static data
		table.insert(searchBoxData, newBar(favorites[k][1], favorites[k][2], favorites[k][3], k, favorites[k][4]))
	end

	typequads = {}
	for k = 1, 2 do
		typequads[k] = love.graphics.newQuad((k - 1) * 22, 0, 22, 22, graphics["types"]:getWidth(), graphics["types"]:getHeight())
	end

	searchScroll = gui:new("scrollbar", (serarch_boxWidth - 3) * scale, (search_boxY + 27) * scale, 12 * scale, (serarch_boxHeight - 29) * scale, 12 * scale, 20 * scale)
end

function netplaysearch_update(dt)
	client:searchForServers()

	searchScroll:update(dt)
end

function netplaysearch_draw()
	love.graphics.setColor(32, 32, 32)
	love.graphics.rectangle("fill", search_boxX * scale, search_boxY * scale, serarch_boxWidth * scale, serarch_boxHeight * scale)

	love.graphics.setColor(255, 255, 255)
	love.graphics.rectangle("line", search_boxX * scale, search_boxY * scale, serarch_boxWidth * scale, serarch_boxHeight * scale)

	for k, v in pairs(searchtabs) do
		v:draw()
	end

	for k, v in pairs(searchBoxData) do
		love.graphics.setScissor(search_boxX * scale, (search_boxY + 27) * scale, serarch_boxWidth * scale, serarch_boxHeight * scale)
		
		v:draw()
		
		love.graphics.setScissor()
	end

	love.graphics.setColor(255, 255, 255)
	searchScroll:draw()
end

function netplaysearch_keypressed(key)
	if key == "escape" or key == " " then
		netplay_load()
	end
end

function netplaysearch_mousepressed(x, y, button)
	for k, v in pairs(searchBoxData) do
		v:mousepressed(x, y, button)
	end

	searchScroll:mousepressed(x, y, button)
end

function netplaysearch_mousereleased(x, y, button)
	searchScroll:mousereleased(x, y, button)
end

function newTab(name, x, y, w, h)
	local tab = {}

	tab.name = name
	tab.x = x
	tab.y = y
	tab.width = (serarch_boxWidth * tabMul) - 2
	tab.height = 24

	function tab:draw()
		love.graphics.setColor(0, 74, 74)

		love.graphics.rectangle("fill", self.x * scale, self.y * scale, self.width * scale, self.height * scale)

		love.graphics.setColor(255, 255, 255)

		love.graphics.setFont(font4)
		love.graphics.print(self.name, (self.x + self.width / 2) * scale - font4:getWidth(self.name) / 2, ((self.y + 2) * scale + (self.height / 2) * scale) - font4:getHeight(self.name) / 2)
	end

	return tab
end

function newBar(name, address, port, y, isLAN)
	bar = {}

	bar.udp = require 'socket'.udp()
	bar.x = (search_boxX + 1)
	bar.y = ( ( search_boxY + 27 ) + (y - 1) * 26 )
	bar.width = serarch_boxWidth - 14
	bar.height = 24

	bar.name = name
	bar.address = address
	bar.port = port

	bar.ply = "?"
	bar.diff = "????"
	bar.ping = "???"

	local quadi = 2
	if isLAN then
		quadi = 1
	end
	bar.quadi = quadi

	local k = y

	bar.udp:settimeout(.1)
	bar.canConnect = false
	bar.hover = false
	
	bar.delete = gui:new("button", (bar.x + 1) * scale, (bar.y + (bar.height / 2)) * scale - 11 * scale, "X", function() 
		table.remove(searchBoxData, k) 
		table.remove(favorites, k) 
		saveData("netplay") 
	end)

	bar.delete.height = 22 * scale
	bar.delete:setTextColor({255, 0, 0})

	function bar:draw()
		love.graphics.setColor(0, 127, 127)
		love.graphics.rectangle("fill", self.x * scale, self.y * scale, self.width * scale, 24 * scale)

		love.graphics.setColor(255, 255, 255)
		love.graphics.draw(graphics["types"], typequads[self.quadi], (searchtabs[1].x + (searchtabs[1].width /2) - 11) * scale, ( (search_boxY + 27 + (24 / 2) - 11) + (k - 1) * 26 ) * scale, 0, scale, scale)

		love.graphics.setFont(font5)
		local name = self.name
		if self.name == "" then
			name = self.address
		end
		love.graphics.print(name, (searchtabs[2].x + (searchtabs[2].width /2)) * scale - font5:getWidth(name) / 2, ( (search_boxY + 30 + (24 / 2)) * scale - font5:getHeight(name) / 2 ) + (k - 1) * 26 * scale)

		love.graphics.print(self.ply .. "/4", (searchtabs[3].x + (searchtabs[3].width /2)) * scale - font5:getWidth(self.ply .. "/4") / 2, ( (search_boxY + 30 + (24 / 2)) * scale - font5:getHeight(self.ply .. "/4") / 2 ) + (k - 1) * 26 * scale)

		love.graphics.print(self.diff, (searchtabs[4].x + (searchtabs[4].width /2)) * scale - font5:getWidth(self.diff) / 2, ( (search_boxY + 30 + (24 / 2)) * scale - font5:getHeight(self.diff) / 2 ) + (k - 1) * 26 * scale)

		love.graphics.print(self.ping, (searchtabs[5].x + (searchtabs[5].width /2)) * scale - font5:getWidth(self.ping) / 2, ( (search_boxY + 30 + (24 / 2)) * scale - font5:getHeight(self.ping) / 2 ) + (k - 1) * 26 * scale)

		if not searchScroll.dragging then
			self.hover = CheckCollision(self.x + self.delete.width, self.y, self.width - self.delete.width, self.height, mouse.X(), mouse.Y(), 4, 4)
		else
			self.hover = false
		end

		if self.hover then
			love.graphics.rectangle("line", self.x * scale, self.y * scale, self.width * scale, 24 * scale)
		end

		self.delete:draw()
	end

	function bar:update(dt)
		local err = false

		if not err then
			local msg, ip, port, err = self.udp:receivefrom()

			if msg then
				local cmd = msg:split(";")

				if cmd[1] == "yes" then
					self:setPlayers(cmd[2])
					self:setDifficulty(cmd[4])
					self:setPing(math.floor( love.timer.getTime() / 1000 ))

					self.canConnect = true
				end
			else
				self.canConnect = false
			end

			self.udp:sendto("isup;", self.ip, self.port)
			if err then
				
			end
		end
	end

	function bar:mousepressed(x, y, button)
		if button == "l" then
			if self.hover and self.canConnect then
				client:load(self.ip, self.port, nickstr)
			end

			self.delete:mousepressed(x, y, button)
		end
	end

	function bar:setPlayers(ply)
		self.ply = ply
	end

	function bar:setDifficulty(diff)
		self.diff = diff
	end

	function bar:setPing(ping)
		self.ping = ping
	end

	return bar
end