--[[
	Idiot's ability creates a small bomb
	This only goes above him and is detonated
	after it is 120px from his y value.
	It sucks in any projectiles/enemies except
	for bosses. These end up fizzling whatever is 
	coming into contact with it.
--]]

local ability = {}

function ability:init(parent)
	self.parent = parent

	self.start = false

	objects.blackholes = {}
end

function ability:update(dt)
	if not self.start then
		self.start = true

		table.insert(objects.blackholes, newBlackholeBomb(self.parent.x + (self.parent.width / 2) - 5, self.parent.y, self.parent))
	end
end

function newBlackholeBomb(x, y, parent)
	local hole = {}

	hole.x = x
	hole.y = y

	hole.bombimg = love.graphics.newImage("characters/idiot9.0/bhole.png")

	hole.quadno = 1
	hole.timer = 0

	hole.width = 9
	hole.height = 9
	hole.parent = parent

	function hole:update(dt)
		if self.y + (self.height / 2) > gameH / 2 then
			self.timer = self.timer + 20 * dt
			self.quadno = math.floor(self.timer%5)+1
		
			self.y = self.y - 100 * dt
		else
			table.insert(objects.blackholes, newBlackhole(self.x + (self.width / 2) - 20, self.y + (self.height / 2) - 20, self.parent))
			self.kill = true
		end
	end

	function hole:draw()
		love.graphics.draw(self.bombimg, self.x * scale, self.y * scale, 0, scale, scale)
	end

	return hole
end

function newBlackhole(x, y, parent)
	local blackhole = {}

	blackhole.x = x
	blackhole.y = y

	blackhole.width = 40
	blackhole.height = 40

	earthquake = 20

	blackhole.r = 20
	blackhole.maxspeed = 80
	blackhole.parent = parent
	blackhole.timer = 6.8
	blackhole.graphic = love.graphics.newImage("characters/idiot9.0/blackhole.png")
	blackhole.quads = {}
	for k = 1, 2 do
		blackhole.quads[k] = love.graphics.newQuad((k - 1) * 40, 0, 40, 40, 80, 40)
	end
	blackhole.animtimer = 0
	blackhole.quadi = 1

	function blackhole:update(dt)
		--pull objects into it!

		self.animtimer = self.animtimer + 8 * dt
		self.quadi = math.floor(self.animtimer%2)+1

		if self.timer > 0 then
			self.timer = self.timer - dt
		else
			self.kill = true
		end

		for i, w in pairs(objects) do
			for j, v in pairs(w) do
				if v.emancipateCheck or name == "explosions" then
					if physics:aabb(self.x - 20, self.y - 20, self.width * 2, self.height * 2, v.x, v.y, v.width, v.height) then
						local dirx, diry, dir = self:normalize( ( (v.y + v.height /2) - (self.y + self.height / 2)  ), ( (v.x + v.width / 2) - (self.x + self.width / 2)) )

						--soooooooo fucking hacky
						local maths = math.cos(dirx)
						if v.x > self.x then
							maths = -math.cos(dirx)
						end

						v.x = v.x + maths * self.maxspeed * dt
						v.y = v.y + math.sin(diry) * self.maxspeed * dt
					end
				end
			end
		end
	end

	function blackhole:normalize(x, y)
		local l = (x * x + y * y) ^ .5 
		if l == 0 then 
			return 0, 0, 0 
		else 
			return x / l, y / l, l 
		end 
	end

	function blackhole:draw()
		--temporary
		love.graphics.setColor(102, 0, 155)
		love.graphics.draw(self.graphic, self.quads[self.quadi], self.x * scale, self.y * scale, 0, scale, scale)
		love.graphics.setColor(255, 255, 255)
	end

	function blackhole:onCollide(name, data)
		if data.emancipateCheck or name == "explosions" then
			table.insert(fizzles, fizzle:new(data))

			data.kill = true
		end
	end

	return blackhole
end

return ability