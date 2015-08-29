local ability = {}

ability.passive = true
ability.name = "tank"
ability.description = "More health, but slower speed"
function ability:init(parent)
	parent:addLife(1)
	parent.xspeed = parent.xspeed - 35
end

return ability