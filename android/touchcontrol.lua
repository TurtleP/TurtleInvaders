--ANDROID/iOS API--

function love.touchpressed(id, x, y, pressure)
	touchcontrols:touchPress(id, x, y, pressure)
end

function love.touchreleased(id, x, y, pressure)
	touchcontrols:touchRelease(id, x, y, pressure)
end

function love.touchmoved(id, x, y, pressure)
	touchcontrols:swipe(id, x, y, pressure)
end

--HOOK EVENTS--

local olddraw = love.draw
function love.draw()
	love.graphics.push()

	olddraw()

	love.graphics.pop()

	touchcontrols:draw()
end

local oldupdate = love.update
function love.update(dt)
	oldupdate(dt)

	touchcontrols:update(dt)
end

local oldhsload = highscoredisplay_load
function highscoredisplay_load(from_menu, score)
	oldhsload(from_menu, score)

	if high then
		if high == 1 then
			love.keyboard.setTextInput(true, 0, 160 * scale, love.window.getWidth(), love.window.getHeight())
		elseif high > 1 then
			love.keyboard.setTextInput(true, 0, 242 * scale, love.window.getWidth(), love.window.getHeight())
		end
	end
end

local oldmenuload = menu_load
function menu_load(fromsettings, fromhighscore, fromcoop)
	if fromhighscore then
		love.keyboard.setTextInput(false)
	end

	touchcontrols:setControls("dpad")

	oldmenuload(fromsettings, fromhighscore, fromcoop)
end

local oldnetmouse = netplay_mousepressed
function netplay_mousepressed(x, y, button)
	oldnetmouse(x, y, button)

	for k, v in pairs(netgui) do
		if (k == "nick" or k == "ip") and v.input then
			love.keyboard.setTextInput(true)
		elseif (k == "port" or k == "name" or k == "hostport") and v.input then
			love.keyboard.setTextInput(true, 0, 180 * scale, love.window.getWidth(), love.window.getHeight())
		elseif (k == "nick" and k == "ip" and k == "port" and k == "hostport" and k == "name") and not v.input then
			love.keyboard.setTextInput(false)
		end
	end
end

local oldnetkey = netplay_keypressed
function netplay_keypressed(key)
	oldnetkey(key)
	
	for k, v in pairs(netgui) do
		if v.input then
			if key == "return" or key == "escape" then
				love.keyboard.setTextInput(false)
			end
		end
	end
end

local oldlobbymouse = lobby_mousepressed
function lobby_mousepressed(x, y, button)
	oldlobbymouse(x, y, button)

	if lobbychatbar.input then
		love.keyboard.setTextInput(true)
	else
		love.keyboard.setTextInput(false)
	end
end

local oldlobbykey = lobby_keypressed
function lobby_keypressed(key)
	oldlobbykey(key)

	if key == "return" then
		if lobbychatbar.input then
			love.keyboard.setTextInput(false)
		end
	end
end

function love.joystickaxis(joystick, axis, value)
	if touchcontrols then
		touchcontrols:joystick()
	end
end

local oldgameload = game_load
function game_load()
	oldgameload()	

	touchcontrols:setControls(controltypes[controli])
end

--TOUCH SHIT HERE--

class "touchcontrol" {}

function touchcontrol:__init()
	local path = "android"
	local dirItems = love.filesystem.getDirectoryItems(path)
	for k = 1, #dirItems do
		--yeah let's NOT require ourself because that'd be smart
		if dirItems[k] ~= "touchcontrol.lua" then
			require(path .. "." .. dirItems[k]:gsub(".lua", ""))
		end
	end

	--actually also iOS but fuck it, who cares anymore
	android = love.joystick.getJoysticks()[1]

	--easy setup stuff..
	controltypes = {"dpad", "gyro", "analog"}
	controli = 1
		
	self.buttons = {}

	self:setControls(controltypes[controli])

	controlnotice = false

	self.setUpdate = false
end

function touchcontrol:touchPress(id, x, y, pressure)
	if love.keyboard.hasTextInput() or state == "netplay" then
		return
	end

	x, y = x*love.graphics.getWidth(), y*love.graphics.getHeight()

	self.controls:touchPressed(id, x, y, pressure)

	if self.buttons then
		for k, v in pairs(self.buttons) do
			v:touchPressed(id, x, y, pressure)
		end
	end
end

function touchcontrol:touchRelease(id, x, y, pressure)

	if not love.keyboard.hasTextInput() and state == "highscoredisplay" then
		if high then
			if high == 1 then
				love.keyboard.setTextInput(true, 0, 160 * scale, love.window.getWidth(), love.window.getHeight())
			elseif high > 1 then
				love.keyboard.setTextInput(true, 0, 242 * scale, love.window.getWidth(), love.window.getHeight())
			end
		end
	end

	if love.keyboard.hasTextInput() or state == "netplay" then
		return
	end

	x, y = x*love.graphics.getWidth(), y*love.graphics.getHeight()

	if self.controls then
		if self.controls.touchReleased then
			self.controls:touchReleased(id, x, y, pressure)
		end
	end
	
	if self.buttons then
		for k, v in pairs(self.buttons) do
			v:touchReleased(id, x, y, pressure)
		end
	end
end

function touchcontrol:getControl()
	return controltypes[controli]
end

function touchcontrol:update(dt)
	if self.controls then
		if self.controls.update then
			self.controls:update(dt)
		end
	end

	if paused then
		if not self.setUpdate then
			self:setControls("dpad")
			self.setUpdate = true
		end
	else
		if self.setUpdate then
			self:setControls(self:getControl())

			if objects["turtle"][1] then
				local ply = objects["turtle"][1]

				if ply.speed > 0 then
					ply:stopright()
				else
					ply:stopleft()
				end
			end

			self.setUpdate = false
		end
	end

	if self:getActiveControl() == "analog" then
		if self.controls:isHeld() then

			if state == "game" and not paused then
				if self.controls:getX() > 0.5 then
					love.keypressed("d")
					love.keyreleased("a")
				end

				if self.controls:getX() >= 0 and self.controls:getX() <= 0.5 then
					love.keyreleased("d")
				end

				if self.controls:getX() < -0.5 then
					love.keypressed("a")
					love.keyreleased("d")
				end

				if self.controls:getX() >= -0.5 and self.controls:getX() <= 0 then
					love.keyreleased("a")
				end
			end

		else

			love.keyreleased("d")
			love.keyreleased("a")

		end
	end

	if self.buttons then
		for k, v in pairs(self.buttons) do
			if v.update then
				v:update(dt)
			end
		end
	end
end
	
function touchcontrol:getActiveControl()
	return self.activeControl
end

function touchcontrol:draw()
	if love.keyboard.hasTextInput() or state == "netplay" then
		return
	end

	if self.controls then
		if self.controls.draw then
			self.controls:draw()
		end
	end

	if self.buttons then
		for k, v in pairs(self.buttons) do
			v:draw()
		end
	end
end

function touchcontrol:setControls(t)
	local scale = getFullScale() --should work
	local wWidth = love.window.getWidth() / scale
	local wHeight = love.window.getHeight() / scale

	if t == "analog" then
		self.controls = newAnalog(160, love.window.getHeight() - 180, 45 * scale, 25 * scale)

		self.buttons[1] = virtualbutton:new(wWidth - 120, wHeight - 60, 30, "A", " ")
		self.buttons[2] = virtualbutton:new(wWidth - 40, wHeight - 120, 30, "B", "lshift", "escape")
		self.buttons[3] = virtualbutton:new(wWidth - 40, 40, 30, "||", "escape", nil, true)
	elseif t == "dpad" then
		self.controls = dinput:new({"w", "d", "s", "a"})

		self.buttons[1] = virtualbutton:new(wWidth - 120, wHeight - 60, 30, "A", " ")
		self.buttons[2] = virtualbutton:new(wWidth - 40, wHeight - 120, 30, "B", "lshift", "escape")
		self.buttons[3] = virtualbutton:new(wWidth - 40, 40, 30, "||", "escape", nil, true)
	elseif t == "gyro" then
		self.controls = gyro:new()
		self.buttons = {}
		self.buttons[1] = virtualbutton:new(wWidth - 40, 40, 30, "||", "escape", nil, true)
	end

	self.activeControl = t

	if state == "game" then
		if objects and not paused then
			if t ~= "gyro" then
				local ply = objects["turtle"][1]

				if not characters[ply.name].ability or characters[ply.name].ability.passive then
					table.remove(self.buttons, 2)
					self.buttons[1]:setPos(wWidth - 55, wHeight - 90)
				end
			end
		elseif objects and paused then
			self.buttons[1] = virtualbutton:new(wWidth - 120, wHeight - 60, 30, "A", " ")
			self.buttons[2] = virtualbutton:new(wWidth - 40, wHeight - 120, 30, "B", "lshift", "escape")
		end
	end
end

function touchcontrol:gyroCheck()
	if love.window.showMessageBox then
		if android and android:getName() == "Android Accelerometer" then
			button = love.window.showMessageBox("First time setup", "Would you like to enable the Accelerometer? This could be turned on/off in options later. Movement would be tilting the device left and right, and shooting occurs when you tap anywhere onscreen.", {"Yes", "No"}, "info")
			
			if button == 1 then
				controli = 2

				savesettings("settings", true)
			end
		end
	end
end

--simpler name for touchmoved. Also, what the fuck do we need an ID for?
function touchcontrol:swipe(id, x, y, pressure)
	if self.controls.touchMoved then

		x = x * love.window.getWidth()
		y = y * love.window.getHeight()

		self.controls:touchMoved(id, x, y, pressure)
	end
end

function touchcontrol:joystick()
	if self.controls then
		if self.controls.axis then
			self.controls:axis(1, android:getAxis(1))

			self.controls:axis(3, android:getAxis(3))
		end
	end
end