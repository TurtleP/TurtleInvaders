local settings = class("settings")

function settings:load()
	self.tabs = {"General", "Controls", "Achievements"}

	self.tabsFont = love.graphics.newFont("graphics/upheval.ttf", 60)
	self.tabSelection = 1

	self.subOptions =
	{
		{
			{"Difficulty:", DIFFICULTIES, GAME_DIFFICULTY}, --Difficulty: <value>
			{"Game Mode:", GAME_MODES, GAME_MODE},
			{""},
			{"Enable Sounds:", SOUND_ENABLED},
			{"Enable Music:", MUSIC_ENABLED},
			{""},
			{"View Credits"},
			{""},
			{"Delete Data"},
		},

		{
			{""}
		}
	}
	self.subSelection = 0

	self.versionFont = love.graphics.newFont("graphics/upheval.ttf", 40)
end

function settings:update(dt)

end

function settings:drawSection(i)
	if not self.subOptions[i] then
		return
	end

	for item = 1, #self.subOptions[i] do
		love.graphics.setColor(0.5, 0.5, 0.5)
		if self.subSelection == item then
			love.graphics.setColor(1, 1, 1)
		end
		
		local add = " "
		local subOption = self.subOptions[i][item]

		if subOption[2] then
			if type(subOption[2]) == "table" then --index our table option
				add = add .. subOption[2][subOption[3]]
			else --just use the second value
				add = add .. tostring(subOption[2])
			end
		end
		love.graphics.print(subOption[1] .. add, 100, 140 + (item - 1) * 60) 
	end
end

function settings:draw()
	love.graphics.setFont(self.tabsFont)

	local width = 0
	for i = 1, #self.tabs do
		if i > 1 then
			width = width + self.tabsFont:getWidth(self.tabs[i - 1]) + self.tabsFont:getWidth("    ")
		end

		love.graphics.setColor(0.5, 0.5, 0.5)
		local x = 70 + (i - 1) + width

		if self.tabSelection == i then
			self:drawSection(i)

			love.graphics.setColor(1, 1, 1)

			if self.subSelection ~= 0 then
				love.graphics.line(x, 50 + self.tabsFont:getHeight(), x + self.tabsFont:getWidth(self.tabs[i]), 50 + self.tabsFont:getHeight())
			end
		end
		love.graphics.print(self.tabs[i], x, 50)
	end

	love.graphics.setFont(self.versionFont)
	love.graphics.print("v" .. GAME_VERSION, love.graphics.getWidth() - (170 + self.versionFont:getWidth("v" .. GAME_VERSION)), love.graphics.getHeight() * 0.88)
end

function settings:gamepadpressed(joy, button)
	if self.subSelection ~= 0 then
		local subOption = self.subOptions[self.tabSelection][self.subSelection]

		if button == "dpright" then
			if type(subOption[2]) == "table" and type(subOption[3]) == "number" then
				subOption[3] = math.min(subOption[3] + 1, #subOption[2])
			end
		elseif button == "dpleft" then
			if type(subOption[2]) == "table" and type(subOption[3]) == "number" then
				subOption[3] = math.max(subOption[3] - 1, 1)
			end
		end
	
		if button == "dpdown" then
			self.subSelection = math.min(self.subSelection + 1, #self.subOptions[self.tabSelection])
			if self.subOptions[self.tabSelection][self.subSelection][1] == "" then
				self.subSelection = self.subSelection + 1
			end
		elseif button == "dpup" then
			self.subSelection = math.max(self.subSelection - 1, 1)
			if self.subOptions[self.tabSelection][self.subSelection][1] == "" then
				self.subSelection = self.subSelection - 1
			end
		end

		if button == "a" then
			if type(subOption[2]) == "boolean" then
				subOption[2] = not subOption[2]
			end
		elseif button == "b" then
			self.subSelection = 0
		end
	else
		if button == "a" then --TODO: don't allow this if already in the submenu
			self.subSelection = 1
		elseif button == "b" then
			state:change("title", 2)
		elseif button == "dpright" then
			self.tabSelection = math.min(self.tabSelection + 1, #self.tabs)
		elseif button == "dpleft" then
			self.tabSelection = math.max(self.tabSelection - 1, 1)
		end
	end
end

function settings:destroy()
	self.tabs = nil
	self.tabsFont = nil
	self.versionFont = nil
end

return settings