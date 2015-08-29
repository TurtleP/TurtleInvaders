class "shieldparticle" {
	
}

shieldparticles = {}
particles = love.filesystem.getDirectoryItems("gfx/particles/shield/")

for k = 1, #particles do
	if string.sub(particles[k], -4, -1) == ".png" then
		table.insert(shieldparticles, love.graphics.newImage("gfx/particles/shield/" .. particles[k]))
	end
end

function shieldparticle:__init(x, y, velocity, lifetime, parent)
	self.x = x
	self.y = y
	self.speedx, self.speedy = unpack(velocity)
	self.graphic = shieldparticles[love.math.random(#shieldparticles)]
	self.width = self.graphic:getWidth()
	self.height = self.graphic:getHeight()
	self.lifetime = lifetime
	self.rotation = 0
	self.color = parent.shieldcolor
	self.opacity = 255

	self.emancipateCheck = true
end

function shieldparticle:draw()
	love.graphics.setColor(self.color, self.opacity)
	love.graphics.draw(self.graphic, self.x * scale, self.y * scale, self.rotation, scale/2, scale/2)
	love.graphics.setColor(255, 255, 255)
end

function shieldparticle:update(dt)
	self.x = self.x + self.speedx
	self.y = self.y + self.speedy

	self.rotation = self.rotation + dt

	self.opacity = math.max(0, self.opacity-120*dt)
	table.insert(self.color, 4, self.opacity)

	if self.lifetime > 0 then 
		self.lifetime = self.lifetime - dt 
	else 
		self.kill = true
	end

	if self.x < 0 or self.y < 0 or self.y > gameH or self.x > gameW then
		self.kill = true
	end

	for k, v in pairs(objects["turtle"]) do
		if CheckCollision(self.x, self.y, self.width, self.height, v.ui.x, v.ui.y, v.ui.width, v.ui.height) then
			v.ui:FadeIn()
		else 
			v.ui:FadeOut()
		end
	end
end

--(centerX of the shield, centerY of the shield, {minimum amount of particles, maximum amount of particles},
-- radius of the shield, {minimum speed, maximum speed}, {minimum lifetime, maximum lifetime})
function roundParticleSpawn(x, y, amount, radius, speed, lifetime, p)
	local minspeed, maxspeed = unpack(speed)
	local minamount, maxamount = unpack(amount)
	local minlifetime, maxlifetime = unpack(lifetime)
	local total = rand(minamount, maxamount)
	for i = 1, total do
		local angle = love.math.random()*(math.pi*2)
		local spd = rand(minspeed, maxspeed)
		local speedx = speedX(spd, angle)
		local speedy = speedY(spd, angle)
		local px = x+speedX(radius, angle)
		local py = y+speedY(radius, angle)
		table.insert(objects.shieldparticles, shieldparticle:new(px, py, {speedx, speedy}, rand(minlifetime, maxlifetime), p))
	end
end

function directedParticleSpawn(x, y, amount, dissolveX, dissolveY, angle, radius, speed, lifetime, p)
	local minspeed, maxspeed = unpack(speed)
	local minamount, maxamount = unpack(amount)
	local minlifetime, maxlifetime = unpack(lifetime)
	local ang = math.offset(getAngle(math.atan2(dissolveY-y, dissolveX-x))+math.pi*2, 0, math.pi*2, math.pi*2)
	local total = rand(minamount, maxamount)
	for i = 1, total do
		local newangle = math.offset(ang + (love.math.random()*2-1)*(angle/2), 0, math.pi*2, math.pi*2)
		local spd = rand(minspeed, maxspeed)
		local speedx = speedX(spd, newangle)
		local speedy = speedY(spd, newangle)
		local px = dissolveX+speedX(love.math.random()*radius, love.math.random()*(math.pi*2))
		local py = dissolveY+speedY(love.math.random()*radius, love.math.random()*(math.pi*2))
		table.insert(objects.shieldparticles, shieldparticle:new(px, py, {speedx, speedy}, rand(minlifetime, maxlifetime), p))
	end
end

function getAngle(angle)
	local a = angle
	a = math.pi-a
	return math.offset(math.abs(a)+math.pi/2, 0, math.pi*2, math.pi*2)
end

function rand(minsp, maxsp)
	return love.math.random()*(maxsp-minsp)+minsp
end

function speedX(angle, speed)
	return -math.sin(angle)*speed
end

function speedY(angle, speed)
	return math.cos(angle)*speed
end

function math.limit(n, mn, mx)
	return math.max(mn, math.min(mx, n))
end

function math.offset(n, mn, mx, f)
	local n = n
	local f = f or mx
	if math.abs(mn-mx) > f then f = mx end
	while n >= mx do
		n = n - f
	end
	while n < mn do
		n = n + f
	end
	return n
end

function roundd(n, d)
	local d = d or 2
	return math.floor(10^d*n)/(10^d)
end
