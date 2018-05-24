local highscores = class("highscores")

local keyboard = require 'libraries.keyboard.keyboard'

function highscores:load(from_game, score)
    self.headerFont = love.graphics.newFont("graphics/upheval.ttf", 60)
    
    self.headerY = WINDOW_HEIGHT * 0.28
    self.rankPosition = vector(WINDOW_WIDTH * 0.15, self.headerY)
    self.scorePosition = vector((WINDOW_WIDTH - self.headerFont:getWidth("Score")) / 2, self.headerY)
    self.namePosition = vector(WINDOW_WIDTH * 0.75, self.headerY)

    if from_game then
        --init keyboard
        self.keyboard = keyboard:new("Enter your initials", 3, function(self)
            if #self.text == 0 then
                return false
            end
            state:call("setHighscoreName", self.text)
            save:write()
            state:change("title")
            return true
        end)
        self.keyboard:setOpen(true)

        local highi = nil 
        for i = 1, #HIGHSCORES do
            if type(HIGHSCORES[i][1]) ~= "string" then
                if tonumber(score) > HIGHSCORES[i][1] then
                    highi = i
                    break
                end
            else
                highi = 1
                break
            end
        end

        for i = highi, #HIGHSCORES do
            if i < #HIGHSCORES then
                HIGHSCORES[i + 2] = {HIGHSCORES[i + 1][1], HIGHSCORES[i + 1][2]}
            else
                break
            end
        end

        HIGHSCORES[highi] = {score, ""}
        self.highi = highi
    end
end

function highscores:update(dt)
    if self.keyboard then
        self.keyboard:update(dt)
    end
end

function highscores:draw()
    love.graphics.setFont(self.headerFont)
    love.graphics.print("High Scores", (WINDOW_WIDTH - self.headerFont:getWidth("High Scores")) / 2, WINDOW_HEIGHT * 0.1)

    love.graphics.print("Rank", self.rankPosition.x, self.rankPosition.y)
    love.graphics.print("Score", self.scorePosition.x, self.scorePosition.y)
    love.graphics.print("Name", self.namePosition.x, self.namePosition.y)

    for i = 1, #HIGHSCORES do
        local x = self.rankPosition.x + (self.headerFont:getWidth("Rank") / 2) - self.headerFont:getWidth(i .. ".") / 2
        love.graphics.print(i .. ".", x, self.headerY + self.headerFont:getHeight() + (i - 1) * 80)

        x = self.scorePosition.x + (self.headerFont:getWidth("Score") / 2) - self.headerFont:getWidth(HIGHSCORES[i][1]) / 2
        love.graphics.print(HIGHSCORES[i][1], x, self.headerY + self.headerFont:getHeight() + (i - 1) * 80)
        
        x = self.namePosition.x + (self.headerFont:getWidth("Name") / 2) - self.headerFont:getWidth(HIGHSCORES[i][2]) / 2
        love.graphics.print(HIGHSCORES[i][2], x, self.headerY + self.headerFont:getHeight() + (i - 1) * 80)
    end

    if self.keyboard then
        self.keyboard:draw()
    end
end

function highscores:gamepadpressed(joy, button)
    if joy:getID() ~= 1 then
        return
    end

    if self.keyboard then
        if self.keyboard:isOpen() then
            self.keyboard:gamepadpressed(joy, button)
            return
        end
    end

    if button == "b" then
        state:change("title", 3)
    end
    
end

function highscores:setHighscoreName(name)
    HIGHSCORES[self.highi][2] = name
end

return highscores