local ability = {}

ability.description = "The lower his health is, the faster he gets"

function ability:init(parent)
	self.parent = parent

	self.speedX = parent.maxSpeedx
end

function ability:update(dt)
	local boost = 0
	if self.parent:getHealth() < self.parent:getMaxHealth() then
		boost = self.speedX * (self.parent:getMaxHealth() / self.parent:getHealth()) * 0.1
	end
	
	self.parent.maxSpeedx = self.speedX + boost 
end

return ability