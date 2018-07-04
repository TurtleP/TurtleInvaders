local boom = class("boom", powerup)

boom.time = 0
boom.isBullet = true --it isn't but who cares
function boom:initialize()
    powerup.initialize(self, 0, 0, 0, 0)

    local layers = state:get("layers")
    self.deaths = {}
    for k, v in ipairs(layers[2]) do
        if tostring(v) == "enemy" then
            print(k)
            table.insert(self.deaths, v)
        end
    end

    self.timer = 0
    self.index = 1
end

function boom:update(dt)
    for index = #self.deaths, 1, -1 do
        if self.timer < 0.5 then
            self.timer = self.timer + dt
        else
            self.deaths[index]:die(true)
            self.timer = 0
            table.remove(self.deaths, index)
        end
    end

    if #self.deaths == 0 then
        self:delete()
    end
end

return boom