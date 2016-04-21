display = class("display")

function display:init()
	self.x = 2
	self.y = 0

	self.width = 316
	self.height = util.getHeight() - self.y

	self.powerupTime = 8

	self.drainPowerup = true

	self.player = nil

	self.powerupFade = 1
end

function display:update(dt)
	if self.drainPowerup then
		self.powerupTime = math.max(0, self.powerupTime - dt)
		self.powerupFade = (self.powerupTime / 8)

		if self.powerupTime <= 0 then
			self.drainPowerup = false

			if self.player then
				self.player:setPowerup("none")
			end
			self.powerupTime = 8
			self.powerupFade = 1
		end
	end
end

function display:setEnemyData(enemy)
	self.enemyData = enemy
end

function display:getEnemyData()
	return self.enemyData
end

function display:draw()
	love.graphics.setColor(32, 32, 32, 140)
	love.graphics.rectangle("fill", 0, 0, 320, 240)

	love.graphics.setColor(255, 255, 255, 255)
	
	if objects["player"][1] then
		self.player = objects["player"][1]
	end
	local player = self.player

	love.graphics.setFont(hudFont)

	--Player info
	love.graphics.print(player.name:gsub("^%l", string.upper), self.x, self.y)

	for x = 1, player:getMaxHealth() do
		local quadi, color = 1
		if x > player:getHealth() then
			quadi, color = 2
		end
		love.graphics.draw(healthImage, healthQuads[quadi][1], hudFont:getWidth(player.name) / 2 - (player:getMaxHealth() * 9) / 2 + (x - 1) * 9, self.y + 36)
	end

	--Score
	love.graphics.print("Score", self.x + (self.width / 2) - hudFont:getWidth("Score") / 2, self.y)

	love.graphics.print(score, self.x + (self.width / 2) - hudFont:getWidth(score) / 2, self.y + 22)

	--Enemy info
	love.graphics.print("Enemy", (self.x + self.width) - hudFont:getWidth("Enemy"), self.y)

	if self.enemyData then
		local enemy = self.enemyData
		for x = 1, enemy:getMaxHealth() do
			local quadi, color = 1
			if x > enemy:getHealth() then
				quadi, color = 2
			end
			love.graphics.draw(healthImage, healthQuads[quadi][1], (self.x + self.width) - hudFont:getWidth("Enemy") / 2 - (enemy:getMaxHealth() * 9) / 2 + (x - 1) * 9, self.y + 36)
		end
	end

	--Powerup info
	if player:getPowerup() == "none" then
		love.graphics.print("No", self.x + (self.width / 2) - hudFont:getWidth("No") / 2, self.y + (self.height / 2) - hudFont:getHeight() / 2)
		
		love.graphics.print("Powerup", self.x + (self.width / 2) - hudFont:getWidth("Powerup") / 2, self.y + (self.height / 2) + hudFont:getHeight() / 2)
	else
		local powerupValue = player:getPowerup()
		local powerup, niceName, powerupTimeValue = self:getDisplayInfo(powerupValue)

		love.graphics.setColor(255, 255, 255, 255 * self.powerupFade)

		love.graphics.draw(powerupDisplayImage, powerupDisplayQuads[powerup], self.x + (self.width / 2) - 32, self.y + (self.height / 2) - 22)
		
		love.graphics.print(niceName, self.x + (self.width / 2) - hudFont:getWidth(niceName) / 2, self.y + (self.height / 2) + hudFont:getHeight() + 10)

		love.graphics.setColor(255, 255, 255, 255)
		
		if not self.drainPowerup then
			self.powerupTime = powerupTimeValue
			self.drainPowerup = true
		end
	end
end

function display:getDisplayInfo(powerupValue)
	local i, name, time = 1, "Shotgun", 8

	if powerupValue == "time" then
		i, name = 2, "Time Slow"
	elseif powerupValue == "mega" then
		i, name, time = 3, "Mega Laser", 5
	elseif powerupValue == "shield" then
		i, name = 4, "Shield"
	elseif powerupValue == "laser" then
		i, name = 5, "Laser"
	elseif powerupValue == "freeze" then
		i, name = 6, "Frozen"
	elseif powerupValue == "anti" then
		i, name = 7, "Anti-Score"
	elseif powerupValue == "nobullets" then
		i, name = 8, "No Bullets"
	elseif powerupValue == "nopower" then
		i, name = 9, "No Powerups"
	end

	return i, name, time
end