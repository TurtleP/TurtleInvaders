function CheckCollision(ax1, ay1, aw, ah, bx1, by1, bw, bh)
	local ax2, ay2, bx2, by2 = ax1*scale + aw*scale, ay1*scale + ah*scale, bx1*scale + bw*scale, by1*scale + bh*scale
	return ax1*scale < bx2 and ax2 > bx1*scale and ay1*scale < by2 and ay2 > by1*scale
end

physics = {}

function physics:update(dt)
	for objName, v in pairs(objects) do
		for _, objData in pairs(v) do

			for obj2Name, t in pairs(objects) do

				if v ~= t then
					for _, obj2Data in pairs(t) do
						if not obj2Data.width and not obj2Data.height then
							return
						end
						
						if self:aabb(objData.x, objData.y, objData.width, objData.height, obj2Data.x, obj2Data.y, obj2Data.width, obj2Data.height) then
							if objData.onCollide then
								objData:onCollide(obj2Name, obj2Data)
							end
						end	
					end
				end
			end
		end
	end
end

function physics:aabb(x, y, w, h, x2, y2, w2, h2)
	x = x * scale
	y = y * scale
	w = w * scale
	h = h * scale

	x2 = x2 * scale
	y2 = y2 * scale
	w2 = w2 * scale
	h2 = h2 * scale

	return (x + w > x2) and (x < x2 + w2) and (y + h > y2) and (y < y2 + h2)
end