local ability = {}
ability.name = "Shatter Bullets"
ability.description = "Bullets will shatter on impact, and kill bats they hit"
ability.passive = true
ability.setData = false
ability.count = 0

enemy.onRemove = function(self)
	local dirs =
	{
		math.pi / 4,
		( math.pi * 3 ) / 4,
		( math.pi * 5 ) / 4,
		( math.pi * 7 ) / 4 
	}

	ability.count = ability.count + 1

	local mod = ability.count%2

	if mod == 0 and ability.count > 0 then

		if self.shottedBy then
			local ply, bullet = self.shottedBy[1], self.shottedBy[2]
			if ply.ability then
				if ply.ability.name == "Shatter Bullets" then
					if ply.bullettype == "none" or ply.bullettype == "" then --no powerup cause otherwise logic
						if not bullet.dontShatter then
							for k = 1, #dirs do
								local tmp = bullet:new(self.x + (self.width / 2) - 2, self.y + (self.height / 2) - 2, math.cos(dirs[k]) * 120, math.sin(dirs[k]) * 120, "none", ply, true)
								tmp.dontShatter = true 
								table.insert(objects.bullets, tmp)
							end
						end
					end
				end
			end
		end

	end
end

return ability	