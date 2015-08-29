class "phoenixshield" {
	x = 0, y = 0
}

for k = 1, 5 do
	
	_G["phoenixshieldanim" .. k] = love.graphics.newImage("gfx/effects/shieldanim" .. k .. ".png")
end

phoenixshieldanimquads = {}
for i = 1, 3 do
	phoenixshieldanimquads[i] = love.graphics.newQuad((i-1)*140, 0, 140, 140, 420, 140)
end

local q = phoenixshieldanimquads
shieldanims = 
{
	{graphic = phoenixshieldanim1, quad = q[1]},
	{graphic = phoenixshieldanim1, quad = q[2]},
	{graphic = phoenixshieldanim1, quad = q[3]},
	{graphic = phoenixshieldanim2, quad = q[1]},
	{graphic = phoenixshieldanim2, quad = q[2]},
	{graphic = phoenixshieldanim2, quad = q[3]},
	{graphic = phoenixshieldanim3, quad = q[1]},
	{graphic = phoenixshieldanim3, quad = q[2]},
	{graphic = phoenixshieldanim3, quad = q[3]},
	{graphic = phoenixshieldanim4, quad = q[1]},
	{graphic = phoenixshieldanim4, quad = q[2]},
	{graphic = phoenixshieldanim4, quad = q[3]},
	{graphic = phoenixshieldanim5, quad = q[1]},
	{graphic = phoenixshieldanim5, quad = q[2]}
}

for k = 1, 6 do
	_G["c" .. k] = love.graphics.newImage("gfx/effects/cracked" .. k .. ".png")
	_G["c" .. k]:setFilter("linear", "linear", 1)
end

crackedanims = 
{
	{c1, q[1]},
	{c1, q[2]},
	{c1, q[3]},
	{c2, q[1]},
	{c2, q[2]},
	{c2, q[3]},
	{c3, q[1]},
	{c3, q[2]},
	{c3, q[3]},
	{c4, q[1]},
	{c4, q[2]},
	{c4, q[3]},
	{c5, q[1]},
	{c5, q[2]},
	{c5, q[3]},
	{c6, q[1]},
}

function phoenixshield:__init(x, y, parent)
	self.x = x
	self.y = y
	self.quadno = 1
	self.timer = 0


	self.width = 140
	self.height = 140

	self.maxwidth = 140
	self.maxheight = 140

	self.hits = shieldHealth
	self.maxhealth = shieldHealth

	self.color = {128, 192, 254, 191}
	self.color2 = {245, 235, 0, 191}
	self.color3 = {255, 55, 55, 191}
	playsound("shield")

	self.cracki = 0

	self.graphic = shieldanims[self.quadno].graphic
	self.quad = shieldanims[self.quadno].quad

	self.shieldAnim = table.copy(shieldAnim)
	self.var = scale

	self.oldx = self.x
	self.oldy = self.y

	self.parent = parent
end

function table.copy(t)
	local ret = {}
	for i, v in pairs(t) do
		ret[i] = v
	end
	return ret
end

function phoenixshield:update(dt)
	if self.quadno < 14 then
		self.timer = self.timer + 36*dt
		self.quadno = math.floor(self.timer%#shieldanims)+1

		self.graphic = shieldanims[self.quadno].graphic
		self.quad = shieldanims[self.quadno].quad
	end
	
	if self.shieldAnim.time > 0 then
		self.shieldAnim.time = math.max(0, self.shieldAnim.time - dt)
		
		local currenttime = self.shieldAnim.maxtime-self.shieldAnim.time
		local radius = currenttime/self.shieldAnim.maxtime*self.shieldAnim.maxsize
		roundParticleSpawn(self.x+(self.width/2)-(30*scale)/2, self.y+(self.height/2)-(30*scale)/2, {3, 6}, 300, {-120, 120}, {3, 3}, self)
	elseif self.shieldAnim.alive then
		self.shieldAnim.alive = false
	end

	if self.shieldAnim.time < 0 then
		self.shieldAnim.time = 0
	end
	
	if self.hits <= 0 and self.shieldAnim.time < 2.2 then
		self.kill = true
	end
end

function phoenixshield:shotted(relay)
	if clientonline then
		if not relay then
			table.insert(onlinetriggers, "phoenixshieldshot;")
		end
	end

	self.hits = self.hits - 1
	self.cracki = self.cracki + 1

	if self.cracki < 16 then
		self.graphic, self.quad = crackedanims[self.cracki][1], crackedanims[self.cracki][2]
	end

	self.var = (shieldMinSize+(self.hits/self.maxhealth)*(1-shieldMinSize))*scale

	self.width = self.maxwidth*self.var
	self.x = self.parent.x+(self.parent.width/2)-(self.width)/2
	self.height = self.maxheight*self.var
	self.y = self.parent.y+(self.parent.height/2)-(self.height)/2

	roundParticleSpawn(self.x+(self.width/2)-(30*scale)/2, self.y+(self.height/2)-(30*scale)/2, {3, 6}, 300, {-120, 120}, {3, 3}, self)
end

shieldAnimTable = {}

function phoenixshield:drawshield()
	if self.parent ~= nil then
		if self.hits > shieldMiddleDamage then
			local t = colorfade(self.hits-shieldMiddleDamage, shieldMiddleDamage, self.color2, self.color)
			self.shieldcolor = t
			love.graphics.setColor(t)
		else
			local t = colorfade(self.hits, shieldMiddleDamage-1, self.color3, self.color2)
			love.graphics.setColor(t)
			self.shieldcolor = t
		end
		
		if self.shieldAnim.time > 0 then
			shieldAnimTable = table.copy(self.shieldAnim)
			love.graphics.setInvertedStencil(shieldDissolve)
			shieldAnimTable = {}
		end

		love.graphics.draw(self.graphic, self.quad, self.x * scale, self.y * scale, 0, self.var, self.var)
		
		if self.shieldAnim.time > 0 then
			love.graphics.setInvertedStencil()
		end
		
		love.graphics.setColor(255, 255, 255)
	else 
		self.kill = true
	end
end

function shieldDissolve()
	local self = {}
	self.shieldAnim = shieldAnimTable
	local currenttime = self.shieldAnim.maxtime-self.shieldAnim.time
	local rad = currenttime/self.shieldAnim.maxtime*self.shieldAnim.maxsize

	love.graphics.circle("fill", self.shieldAnim.x, self.shieldAnim.y, rad, 64)
end

function phoenixshield:forcedissolve(x, y) --relative to shield
	local xpos = self.x+self.width/2+x
	local ypos = self.y+self.height/2+y

	self.shieldAnim.time = self.shieldAnim.maxtime
	self.shieldAnim.x = xpos
	self.shieldAnim.y = ypos
	self.shieldAnim.alive = true
	self.hits = 0
end