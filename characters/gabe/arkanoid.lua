--GABE'S ABILITY
local ability = {}
ability.description = "Rapid fire dual bullet barrage! Pew pew!"

function ability:init(parent)
	self.parent = parent

	self.realShootFunction = parent.shoot

	self.realShootTimer = parent.maxShootTimer

	parent.maxShootTimer = 1.25/3

	parent.shoot = function(self)
		if self.shootingTimer == 0 then
			table.insert(objects["bullet"], bullet:new(self.x + (self.width * 1/5) - 1, self.y - 1, "none", {0, -180}))
			
			table.insert(objects["bullet"], bullet:new((self.x + self.width) - 8 - 1, self.y - 1, "none", {0, -180}))

			self.shootingTimer = self.maxShootTimer
		end
	end

	self.timer = 8

	self.initialize = true
end

function ability:update(dt)
	if not self.initialize then
		return
	end

	if self.timer > 0 then
		self.timer = self.timer - dt
	else
		self:reset()
	end
end

function ability:trigger(parent)
	self.initialize = false

	if parent then
		self:init(parent)
	end
end

function ability:reset()
	self.parent.shoot = self.realShootFunction

	self.parent.maxShootTimer = self.realShootTimer

	self.initialize = false
end

return ability