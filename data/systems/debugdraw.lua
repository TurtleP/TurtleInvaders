local DebugDraw = System({Components.Position, Components.Size})

local FONT = love.graphics.newFont(16)

local function wireframe(zoom, x, y, width, height, scale)
    love.graphics.rectangle("line", x * (scale / zoom), y * (scale / zoom), width * (scale / zoom), height * (scale / zoom))
end

function DebugDraw:init()
    self.zoom = 1
end

function DebugDraw:draw()
    for _, entity in ipairs(self.pool) do
        local position = entity:get(Components.Position)
        local size     = entity:get(Components.Size)

        wireframe(8, position.x, position.y, size.width, size.height, _env.SCALE)
    end

    love.graphics.setFont(FONT)
    love.graphics.print("FPS: " .. love.timer.getFPS(), 0, 0)
end

function DebugDraw:Zoom(amount)
    if amount > 0 then
        self.zoom = math.min(self.zoom + amount, _env.SCALE * 4)
    else
        self.zoom = math.max(self.zoom + amount, 1)
    end
end

return DebugDraw
