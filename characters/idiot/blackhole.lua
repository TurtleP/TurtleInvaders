--[[
	Idiot's ability creates a small bomb
	This only goes above him and is detonated
	after it is 120px from his y value.
	It sucks in any projectiles/enemies except
	for bosses. These end up fizzling whatever is 
	coming into contact with it.
--]]

local ability = {}
ability.description = "Create a black hole to suck in bats"

function ability:init(parent)
	self.parent = parent

	self.blackhole = newBlackholeBomb(self.parent.x + (self.parent.width / 2) - 5, self.parent.y)

	self.active = true
end

function ability:trigger(parent)
	self:init(parent)
end

function ability:update(dt)
	if not self.active then
		return
	end

	self.blackhole:update(dt)
end

function ability:draw()
	if not self.active then
		return
	end

	self.blackhole:draw()
end

function newBlackholeBomb(x, y, parent)
	local hole = {}

	hole.x = x
	hole.y = y

	hole.bombRadius = 0

	hole.timer = 0

	hole.currentColor = Color.darkPurple
	hole.toColor = Color.purple

	hole.color = hole.currentColor

	hole.ringRadius = 0

	function hole:update(dt)
		if not self.init then
			if self.y + 16 > util.getHeight() / 2 then
				self.y = self.y - 100 * dt
			else
				self.init = true
			end
		end
		
		self.bombRadius = util.clamp(self.bombRadius + 16 * dt, 0, 32)

		self.ringRadius = util.clamp(self.ringRadius +  8 * dt, 0, 32)

		if self.timer < 1 then
			self.timer = self.timer + dt
		else
			local temp = self.currentColor
			self.currentColor = self.toColor
			self.toColor = temp
			self.timer = 0
			self.ringRadius = 0
		end
		self.color = util.colorFade(self.timer, 1, self.currentColor, self.toColor)

	end

	function hole:draw()
		love.graphics.setColor(unpack(self.color))
		love.graphics.circle("fill", self.x, self.y, self.bombRadius, 64)

		love.graphics.setColor(unpack(self.toColor))
		love.graphics.circle("fill", self.x, self.y, self.ringRadius, 64)
	end

	return hole
end

return ability