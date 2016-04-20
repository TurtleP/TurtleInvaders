display = class("display")

function display:init()
	self.x = 2
	self.y = 0

	self.width = 316
	self.height = util.getHeight() - self.y

	self.powerupRadius = 74

	self.drainPowerup = true

	self.player = nil
end

function display:update(dt)
	if self.drainPowerup then
		self.powerupRadius = math.max(0, self.powerupRadius - 8 * dt)

		if self.powerupRadius == 0 then
			self.drainPowerup = false

			if self.player then
				self.player:setPowerup("none")
			end
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
		local powerup, color = self:getDisplayInfo(player:getPowerup())

		--love.graphics.setColor(unpack(color))
		
		--love.graphics.circle("line", self.x + (self.width / 2), self.y + (self.height / 2) + 18, self.powerupRadius)

		love.graphics.setColor(255, 255, 255)
		love.graphics.draw(powerupDisplayImage, powerupDisplayQuads[powerup], self.x + (self.width / 2) - 32, self.y + (self.height / 2) - 20)

		if not self.drainPowerup then
			self.drainPowerup = true
		end
	end
end

function display:getDisplayInfo(powerupValue)
	local i, color = 1, {255, 73, 56}

	if powerupValue == "time" then
		i, color = 2, {209, 213, 216}
	elseif powerupValue == "mega" then
		i, color = 3, {61, 142, 185}
	elseif powerupValue == "shield" then
		i, color = 4, {44, 130, 201}
	elseif powerupValue == "laser" then
		i, color = 5, {209, 72, 65}
	elseif powerupValue == "freeze" then
		i, color = 6, {44, 130, 201}
	elseif powerupValue == "anti" then
		i, color = 7, {147, 101, 184}
	elseif powerupValue == "nobullets" then
		i, color = 8, {243, 121, 52}
	elseif powerupValue == "nopower" then
		i, color = 9, {243, 121, 52}
	end

	return i, color
end