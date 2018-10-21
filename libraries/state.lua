local state = class("state")

function state:initialize()
    self.states = {}
    self.currentState = nil

    local items = love.filesystem.getDirectoryItems("states")

    for i = 1, #items do
        self:registerState(items[i]:gsub(".lua", ""))
    end
end

function state:registerState(name)
    assert(type(name) == "string",
    "invalid name: expected string.")

    local reg = require("states." .. name)
    self.states[name] = reg:new()
end

function state:hasState(name)
    if name then
        return self.states[name] ~= nil
    end

    return self.currentState ~= nil
end

function state:is(identity)
    if self:hasState() then
        if tostring(self.currentState):sub(-#identity) == identity then
            return true
        end
        return false
    end
end

function state:call(name, ...)
    local args = {...}
    if self:hasState() then
        local t = type(name)

        if t == "string" then
            if self:hasMethod(name) then
                return self.currentState[name](self.currentState, unpack(args))
            end
        elseif t == "table" then
            for i = 1, #name do
                local command, args = name[i][1], name[i][2]

                self:call(command, args)
            end
        end
    end
end

function state:hasMethod(method)
    if self:hasState() then
        return self.currentState[method] ~= nil
    end
end

function state:get(var, set)
    if self:hasState() then
        if set then
            if self.currentState[var] then
                self.currentState[var] = set
            end
        else
            return self.currentState[var]
        end
    end
end

function state:load(...)
    if not self:hasState() then
        return
    end

    local args = {...}

    if type(args[1]) == "function" then
        args[1]()
        table.remove(args, 1)
    end

    if self.currentState.load then
        self.currentState:load(unpack(args))
    end
end

function state:destroy()
    if not self:hasState() then
        return
    end

    if self.currentState.destroy then
        self.currentState:destroy()
    end
end

function state:change(name, ...)
    if not self.states[name] then
        return
    end

    self:destroy()

    self.currentState = self.states[name]

    self:load(...)
end

function state:update(dt)
    if not self:hasMethod("update") then
        return
    end

    self.currentState:update(dt)
end

function state:draw()
    if not self:hasMethod("draw") then
        return
    end

    self.currentState:draw()
end

function state:keypressed(key)
    if not self:hasMethod("keypressed") then
        return
    end

    self.currentState:keypressed(key)
end

function state:keyreleased(key)
    if not self:hasMethod("keyreleased") then
        return
    end
    
    self.currentState:keyreleased(key)
end

function state:gamepadpressed(joy, button)
    if not self:hasMethod("gamepadpressed") then
        return
    end
    
    self.currentState:gamepadpressed(joy, button)
end

function state:gamepadreleased(joy, button)
    if not self:hasMethod("gamepadreleased") then
        return
    end
    
    self.currentState:gamepadreleased(joy, button)
end

function state:gamepadaxis(joy, axis, value)
    if not self:hasMethod("gamepadaxis") then
        return
    end
    
    self.currentState:gamepadaxis(joy, axis, value)
end

function state:mousepressed(x, y, button)
    if not self:hasMethod("mousepressed") then
        return
    end

    self.currentState:mousepressed(x, y, button)
end

function state:mousereleased(x, y, button)
    if not self:hasMethod("mousereleased") then
        return
    end

    self.currentState:mousereleased(x, y, button)
end

function state:wheelmoved(x, y)
    if not self:hasMethod("wheelmoved") then
        return
    end

    self.currentState:wheelmoved(x, y)
end

return state:new()