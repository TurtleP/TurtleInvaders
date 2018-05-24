local card = class("card")

function card:initialize(i, x, y)
    self.x = x
    self.y = y

    self.dimensions = vector(120, 120)

    self.draw = function(self) 
        self:defaultDraw() 
    end

    self.update = function(self, dt)
        self:defaultUpdate(dt)
    end
end

function card:setInfo(character)
    for component, value in pairs(character) do
        self[component] = value
    end

    if not character.draw then
        self.draw = function(self) 
            self:defaultDraw()
        end
    end

    if not character.update then
        self.update = function(self, dt)
            self:defaultUpdate(dt)
        end
    end
end

function card:defaultDraw()
    if not self.graphic then
        return
    end
    --print(self.x, self.y)
    love.graphics.draw(self.graphic, self.x, self.y)
end

function card:defaultUpdate(dt)
end

return card