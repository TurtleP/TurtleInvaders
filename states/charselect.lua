local charselect = class("charselect")

function charselect:load()
	self.font = love.graphics.newFont("graphics/upheval.ttf", 80)

	self.selection = 1
end

function charselect:update(dt)

end

function charselect:draw()
	love.graphics.setFont(self.font)
	love.graphics.print("CHOOSE A CHARACTER", (WINDOW_WIDTH - self.font:getWidth("CHOOSE A CHARACTER")) / 2, WINDOW_HEIGHT * 0.05)

	for i = 1, #characters do
		love.graphics.rectangle("line", 385 + math.fmod((i - 1), 4) * 140, 218 + math.floor((i - 1) / 4) * 140, 96, 96)
	end
end

function charselect:gamepadpressed(joy, button)

end

return charselect