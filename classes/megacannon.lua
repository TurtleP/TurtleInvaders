megacannon = class("megacannon")

function megacannon:init(player)
	self.parent = player

	self.y = 0
	self.x = player.x
	self.width = 16
	self.height = player.y

	self.baseQuadi = 1

	self.boomQuadi = 1
	self.boomTimer = 0

	self.beami = 1

	self.initialize = false

	self.active = true
	--self.static = true

	self.speedx = 0
	self.speedy = 0

	self.gravity = 0
	
	self.mask =
	{
		["bat"] = true,
		["powerup"] = true,
		["bullet"] = true
	}

	self.passive = true
end

function megacannon:passiveCollide(name, data)
	print(name)
end

function megacannon:update(dt)
	self.x = self.parent.x + (self.parent.width / 2) - 11

	self.boomTimer = self.boomTimer + 18 * dt
	self.boomQuadi = math.floor(self.boomTimer % #megaCannonBoomQuads) + 1

	if not self.initialize then
		if self.boomQuadi == 15 then
			self.initialize = true
		end
	else
		self.baseQuadi = math.floor(self.boomTimer % 5) + 1
		self.beami = math.floor(self.boomTimer % #megaCannonBeamQuads) + 1
	end
end

function megacannon:draw()
	local x, y = self.parent.x + (self.parent.width / 2) - 40, self.parent.y - 60

	love.graphics.draw(megaCannonBoomImage, megaCannonBoomQuads[self.boomQuadi], x, y)
	if not self.initialize then
		return
	end

	for y = 2, math.floor(self.height / 22) - 1 do
		love.graphics.draw(megaCannonBeamImage, megaCannonBeamQuads[self.beami], self.parent.x + (self.parent.width / 2) - 11, self.parent.y - 16 - (y + 1) * 22)
	end

	love.graphics.draw(megaCannonBaseImage, megaCannonBaseQuads[self.baseQuadi], x, y)
end