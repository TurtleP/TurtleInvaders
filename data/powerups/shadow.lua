local shadow = class("shadow", powerup)

shadow.time = 8
function shadow:initialize()
    powerup.initialize(self, 0, 0, 0, 0)

    self.fade = 0
    self.timer = 0

    local layers = state:get("layers")
    table.insert(layers[3], self)
end

function shadow:update(dt)
    self.timer = self.timer + dt
    
    if self.fade < 0.9 and self.timer < 15 then 
        self.fade = math.min(self.fade + dt / 0.3, 0.9)
    else
        self.fade = math.max(self.fade - dt / 0.8, 0)
    end
end

function shadow:draw()
    love.graphics.setColor(0, 0, 0, self.fade)
    love.graphics.rectangle("fill", 0, 0, WINDOW_WIDTH, WINDOW_HEIGHT)
end

return shadow