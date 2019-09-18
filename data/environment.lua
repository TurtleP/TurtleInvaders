local scale = window:getScale()

return
{
    WINDOW_W  = 640,
    WINDOW_H  = 360,
    SCALE     = (scale.x == scale.y and scale.x) or scale,
    VOLUME    = 0.5,
    VERSION   = "0.1.0 (ALPHA)",

    COPYRIGHT = "(c) 2019 TurtleP",

    UPDATEGROUP = function(t, dt)
        for index, value in ipairs(t) do
            if value:update(dt) then
                table.remove(t, index)
            end
        end
    end,

    RENDERGROUP = function(t)
        for _, value in pairs(t) do
            value:draw()
        end
    end,

    GAMEPADPRESSGROUP = function(t, button)
        for _, value in pairs(t) do
            value:gamepadpressed(button)
        end
    end,

    GAMEPADAXISGROUP = function(t, axis, avalue)
        for _, value in pairs(t) do
            value:gamepadaxis(axis, avalue)
        end
    end,

    MESSAGE = function(name)
        table.insert(dialogs, dialog:new(name))
    end
}
