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
            state:call("sortHighscores", score, self.text)

            save:write()
            state:change("title")
            return true
        end)
        self.keyboard:setOpen(true)

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

        x = self.scorePosition.x + (self.headerFont:getWidth("Score") / 2) - self.headerFont:getWidth(padText(HIGHSCORES[i][1], "0", 6)) / 2
        love.graphics.print(padText(HIGHSCORES[i][1], "0", 6), x, self.headerY + self.headerFont:getHeight() + (i - 1) * 80)
        
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

function highscores:sortHighscores(highscore, name)
    --push unknowns to bottom
    local set = false
    table.sort(HIGHSCORES, function(a, b)
        if not tonumber(a[1]) then
            a[1] = -1
        end
        
        if not tonumber(b[1]) then
            b[1] = -1
        end

        if highscore and not set then
            if highscore > a[1] then
                a[1] = highscore
                a[2] = name
                set = true
            end
        end
        return a[1] > b[1]
    end)

        --those -1's are just for sorting
        --reset them to six ?'s
    for i = 1, #HIGHSCORES do
        if HIGHSCORES[i][1] == -1 then
            HIGHSCORES[i][1] = padText("", "?", 6)
        end
    end
end

return highscores