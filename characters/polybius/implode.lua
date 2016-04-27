local ability = {}

ability.description = "Causes some bats on the screen to implode"

function ability:trigger()
	for k, v in pairs(objects["bat"]) do
		if v.y > 0 then
			local r = love.math.random()

			if r < .75 then
				v:die()
				
				shakeValue = 20
			end
		end
	end
end

return ability