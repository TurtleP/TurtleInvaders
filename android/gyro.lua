--[[
	Handle the gyro controls!
--]]

class "gyro" {}

function gyro:__init()
	self.enabled = true
end

function gyro:touchPressed(id, x, y, pressure)
	if not CheckCollision(touchcontrols.buttons[1].boundsX, touchcontrols.buttons[1].boundsY, touchcontrols.buttons[1].width, touchcontrols.buttons[1].height, x / scale, y / scale, 8, 8) then
		if not paused then
			love.keypressed(" ")
		end
	end
end

function gyro:setEnabled(bEnabled)
	self.enabled = bEnabled
end

function gyro:axis(axis, value)
	if not objects then
		return
	end

	local player = objects["turtle"][1]
	local deadZone = 0.12

	if axis == 1 then
		if value > deadZone then
			player:moveright()
		elseif value >= 0 and value < deadZone then
			player:stopright()
		elseif value < -deadZone then
			player:moveleft()
		elseif value > -deadZone and value <= 0 then
			player:stopleft()
		end
	end

	if axis == 3 then
		if value == -1 then
			player:specialUp()
		end
	end
end