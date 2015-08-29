class "shipui" {
	x = 0, y = 0, i = 1
}

function shipui:__init(i, n, name, char)
	self.x = 4
	self.y = 22
	self.num = i
	self.maxhp = n
	self.colors = colors
	self.name = name
	self.graphic = char.graphic
	self.colorable = colorable
	self.powid = 1

	self.checksForFade =
	{
		"enemies",
		"boss",
		"bullets",
		"phoenixfire",
		"shieldparticles",
		"core",
		"powerup",
		"food",
		"emances"
	}

	self.poweruptimer = 8
	self.poweruptimerMax = 8

	self.abilityuseBar = 0
	self.abilityuseBarMax = 12

	self.megacannonthing = false

	self.powerups = {"none", "none"}
	self:setData(self.powerups[1], self.powerups[2])
	self.char = char

	self.width = self.graphic:getHeight() + 62
	self.height = 40
	self.fade = 1

	self.abilityPassive = false
	if self.char.ability then
		if self.char.ability.passive then
			self.abilityPassive = true
		end
	else
		self.abilityPassive = true
	end

	--8 spaces, dawg
	self.width = 110
	
	if i == 2 then
		self.x = gameW - self.width - 4
	elseif i == 3 then
		self.y = gameH
	elseif i == 4 then
		self.x = gameW - self.width - 4
		self.y = gameH
	end
end

function shipui:updateHUD(dt)
	--bullettype cannot be none or shoop, powerup can't be none
	--well, I can't believe I fucked up my boolean logic. Also my controller would not stop vibrating. WOO.
	if (self.powerups[1] ~= "none" and self.powerups[1] ~= "shoop") or (self.powerups[2] ~= "none" or self.powerups[1] == "shoop" and self.megacannonthing) then
		self.poweruptimer = self.poweruptimer - dt
	end
end

function shipui:FadeIn()
	self.fade = 0.5
end

function shipui:FadeOut()
	self.fade = 1
end

function shipui:resetData()
	self.powerups = {"none", "none"}

	self:setData()

	self.poweruptimer = self.poweruptimerMax
	self.megacannonthing = false
end

function shipui:CheckForCollide(name)
	for j, v in pairs(objects[name]) do
		if CheckCollision(self.x, self.y, self.width, self.height, v.x, v.y, v.width, v.height) then
			self.fade = 0.5
		else 
			self.fade = 1
		end
	end
end

function shipui:draw()
	love.graphics.setColor(255, 255, 255, 255)
	
	love.graphics.setFont(font3)
	love.graphics.print(self.name, self.x * scale, (self.y - font3:getHeight(name) / scale) * scale)

	if self.maxhp == 0 then
		return
	end

	local y = (self.y - 18)
	local timery = (self.y - 6)
	if not self.abilityPassive then
		y = (self.y - 20)
		timery = (self.y - 9)

		love.graphics.setColor(0, 255, 0)
		love.graphics.rectangle("fill", self.x * scale + font3:getWidth(self.name) + 4 * scale, (self.y - 5) * scale, (self.abilityuseBar / self.abilityuseBarMax) * 33 * scale, 1 * scale)
		love.graphics.setColor(255, 255, 255)
	end

	if self.maxhp < 5 then
		for k = 1, self.maxhp do
			love.graphics.draw(graphics["hitpoint"], self.x * scale + font3:getWidth(self.name) + 4 * scale + (k - 1) * 12 * scale, y * scale, 0, scale, scale)
		end
	else
		love.graphics.print(self.maxhp, self.x * scale + font3:getWidth(self.name) + 8 * scale + font3:getWidth(self.num), y * scale)
		love.graphics.draw(graphics["hitpoint"], self.x * scale + font3:getWidth(self.name) + 4 * scale, y * scale, 0, scale, scale)
	end

	love.graphics.setColor(0, 148, 255)
	love.graphics.rectangle("fill", self.x * scale + font3:getWidth(self.name) + 4 * scale, timery * scale, (self.poweruptimer / self.poweruptimerMax) * 33 * scale, 1 * scale)
	love.graphics.setColor(255, 255, 255)
end

function shipui:setData(powerType)
	if powerType == self.powerups[1] or powerType == self.powerups[2] then
		self.poweruptimer = self.poweruptimerMax
	end
end

function shipui:setBullet(bulletType)
	self.powerups[1] = bulletType

	self:setData(bulletType)
end

function shipui:setPowerup(powerupType)
	self.powerups[2] = powerupType

	self:setData(powerupType)
end

function shipui:addAbilityBar()
	if self.abilityPassive or self.poweruptimer < self.poweruptimerMax then
		return
	end

	self.abilityuseBar = math.min(self.abilityuseBar + 1, self.abilityuseBarMax)
end

function shipui:useSpecial()
	self.abilityuseBar = 0
end

function shipui:isAbilityFull()
	return (self.abilityuseBar == self.abilityuseBarMax)
end