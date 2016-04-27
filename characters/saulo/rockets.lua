local ability = {}

ability.description = "Bullets will home in on the closest enemy"

local oldBulletUpdate = bullet.update
local oldBulletInit = bullet.init
function ability:init(parent)
	self.setTarget = false
	self.start = true
	self.target = nil

	self.timer = 8
end

function ability:update(dt)
	if not self.start then
		return
	end

	if self.timer > 0 then
		self.timer = self.timer - dt
	else
		self:reset()
	end
end

function ability:trigger(parent)
	if not parent then
		return
	end

	self:init(parent)

	bullet.init = function(self, x, y, t, velocity)
		oldBulletInit(self, x, y, t, velocity)
		
		if velocity[2] < 0 then
			self.isRocket = true
			self.parent = objects["player"][1]
		end
	end

	bullet.update = function(self, dt)
		if self.isRocket then
			local nearest = 1
			for k, v in pairs(objects["bat"]) do
				if util.dist(self.x, self.y, v.x, v.y) <= 20 then
					nearest = k
				end
			end

			if objects["bat"][nearest] then
				self.parent.ability.target = objects["bat"][nearest]
			end

			if self.parent.ability.target then
				local spinfactor = math.pi/60
				
				local a = math.atan2(self.speedy, self.speedx)
				local a2 = math.atan2((self.parent.ability.target.y + (self.parent.ability.target.height / 2))-self.y, self.parent.ability.target.x-self.x)
				if a < a2 and a2 - a > math.pi then spinfactor = spinfactor * (-1)
				elseif a > a2 and a - a2 <= math.pi then spinfactor = spinfactor * (-1) end
					
				a = a + spinfactor
				if a < 0 then a = a + math.pi*2
				elseif a >= math.pi*2 then a = a - math.pi*2 end
					
				local speed = 200
				self.speedx = speed*math.cos(a)
				self.speedy = speed*math.sin(a)
			end
		else
			oldBulletUpdate(self, dt)
		end
	end
end

function ability:reset()
	bullet.update = oldBulletUpdate
	bullet.init = oldBulletInit
end

return ability