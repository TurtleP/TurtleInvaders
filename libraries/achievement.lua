local achievement = class("achievement")
local popup = require 'data.achievements.popup'

function achievement:initialize()
    local items = love.filesystem.getDirectoryItems("data/achievements")

    self.achievements = {}
    self.queue = {}

    for i = 1, #items do
        local subItems = love.filesystem.getDirectoryItems("data/achievements/" .. items[i])
        local folderName = "data/achievements/" .. items[i]

        local info = love.filesystem.getInfo(folderName)

        if not info then
            return
        end

        if (info.type == "directory") then
            for j = 1, #subItems do
                local name = subItems[j]:gsub(".lua", "")
                if subItems[j]:sub(-4) == ".lua" then
                    self:register("data/achievements/" .. items[i] .. "/" .. name, items[i])
                end
            end
        end
    end

    self.font = love.graphics.newFont("graphics/upheval.ttf", 20)
end

function achievement:register(name, tier)
    local v = require(name)
    
    if v.hook and v.source then
        if _G[v.source.class] then
            local func =_G[v.source.class][v.source.func]
            _G[v.source.class][v.source.func] = hook.add(func, v.hook)
        end
    end

    table.insert(self.achievements, popup:new(v.name, tier, v))
end

function achievement:addQueue(index)
    local achievement = self.achievements[index]
    table.insert(self.queue, achievement)
end

function achievement:update(dt)
    for index, achievement in ipairs(self.achievements) do
        if not self.achievements[index].unlocked and achievement.data:isValid() then
            self:addQueue(index)
        end
    end

    if #self.queue == 0 then
        return
    end

    local achievement = self.queue[1]
    if not achievement:isUnlocked() then
        achievement:unlock()
    end

    achievement:update(dt)

    if achievement.remove then
        table.remove(self.queue, 1)
    end
end

function achievement:draw()
    if #self.queue == 0 then
        return
    end

    local achievement = self.queue[1]

    if achievement.unlocked then
        love.graphics.setFont(self.font)
        achievement:draw(self.font, nil, nil)
    end
end

return achievement:new()