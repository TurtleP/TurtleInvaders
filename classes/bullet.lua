bullet = class("bullet")

function bullet:init(x, y, t, velocity)
	self.x = x
	self.y = y

	self.width = 2
	self.height = 2

	local color = {247, 218, 100}
	local sound = bulletSound

	if t == "laser" then
		color = {255, 73, 56}
		sound = laserSound

		self.height = 10
	elseif t == "anti" then
		color = {147, 101, 184}
	elseif t == "freeze" then
		color = {44, 130, 201}
	end

	self.color = color
	sound:play()

	self.speedx = velocity[1]
	self.speedy = velocity[2]

	self.active = true

	self.gravity = 0

	self.mask =
	{
		["bat"] = true,
		["player"] = true
	}

	self.passive = true

	self.t = t
end

function bullet:update(dt)
	if self.y < -self.height or self.y > util.getHeight() then
		self.remove = true
	end
end

function bullet:draw()
	love.graphics.setColor(unpack(self.color))
	love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)

	love.graphics.setColor(255, 255, 255)
end

local batCount = 0
function bullet:passiveCollide(name, data)
	if name == "bat" then
		if self.speedy > 0 then
			return
		end
		
		displayInfo:setEnemyData(data)

		data:die()

		if self.t == "laser" then
			batCount = batCount + 1

			if batCount == 2 then
				achievements[10]:unlock(true)
			end

			return
		end

		if self.t == "anti" then
			gameAddScore(-10)
		end

		self.remove = true
	end

	if name == "boss" then
		if self.speedy > 0 then
			return
		end

		data:takeDamage(-2)

		self.remove = true
	end

	if name == "player" then
		if self.speedy < 0 then
			return
		end

		data:addLife(-1)
		self.remove = true
	end
end