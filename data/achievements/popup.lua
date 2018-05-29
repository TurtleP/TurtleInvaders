local popup = class("popup")

local trophyImage = love.graphics.newImage("data/achievements/trophy.png")
local bigTrophyImage = love.graphics.newImage("data/achievements/bigTrophy.png")

local unlockSound = love.audio.newSource("audio/unlock.ogg", "static")
local TROPHY_COLORS =
{
    ["bronze"] = {0.804, 0.498, 0.196},
    ["silver"] = {0.753, 0.753, 0.753},
    ["gold"] = {1, 0.843, 0}
}

function popup:initialize(name, tier, data)
    self.x = WINDOW_WIDTH - 240
    self.y = WINDOW_HEIGHT - 60

    self.width = 240
    self.height = 60

    self.color = TROPHY_COLORS[tier]

    local numTier = 1
    if tier == "silver" then
        numTier = 2
    elseif tier == "gold" then
        numTier = 3
    end
    self.tier = numTier
    print(name, tier)

    self.name = name
    self.description = data.description or ""
    self.secret = data.hidden
    
    self.whiteFade = 1
    self.fade = 1
    self.timer = 1

    self.date = ""
    self.unlocked = false
    self.remove = false

    self.data = data

    self.nameFont = love.graphics.newFont("graphics/upheval.ttf", 40)
    self.descriptionFont = love.graphics.newFont("graphics/upheval.ttf", 20)
end

function popup:update(dt)
    if not self.unlocked then
        return
    end

    self.whiteFade = math.max(self.whiteFade - dt / 0.7, 0)

    if self.whiteFade == 0 then
        self.timer = self.timer - dt

        if self.timer <= 0 then
            self.fade = math.max(self.fade - dt / 0.8, 0)

            if self.fade == 0 then
                self.remove = true
            end
        end
    end
end

function popup:draw(font)
    love.graphics.setColor(self.color[1], self.color[2], self.color[3], 1 * self.fade)
    love.graphics.draw(trophyImage, self.x + 8, self.y + (self.height - trophyImage:getHeight()) / 2)

    love.graphics.setColor(1, 1, 1, 1 * self.fade)
    love.graphics.print(self.name, self.x + (8 + trophyImage:getWidth()) + (184 - font:getWidth(self.name)) / 2, self.y + (self.height - font:getHeight()) / 2)

    love.graphics.setColor(1, 1, 1, 1 * self.whiteFade)
    love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
end

function popup:drawBig(x, y, color)

    love.graphics.setFont(self.nameFont)
    if self.unlocked then
        love.graphics.setColor(self.color[1], self.color[2], self.color[3], 1)
    else
        love.graphics.setColor(0.5, 0.5, 0.5)
    end
    love.graphics.draw(bigTrophyImage, x + 8, y + (self.height - bigTrophyImage:getHeight()) / 2)

    if not self.unlocked then
        love.graphics.setColor(1, 1, 1)
        love.graphics.print("?", x + 8 + (bigTrophyImage:getWidth() - self.nameFont:getWidth("?")) / 2, y + ((self.height - bigTrophyImage:getHeight() / 2) - self.nameFont:getHeight()) / 2 + 4)
    end

    love.graphics.setColor(color)
    love.graphics.print(self.name, x + (8 + bigTrophyImage:getWidth()) + 16, y)

    if self.date ~= "" then
        love.graphics.print(self.date, x + (WINDOW_WIDTH - self.nameFont:getWidth(self.date)) - 200, y + (self.height - self.nameFont:getHeight()) / 2)
    else
        love.graphics.print("locked", x + (WINDOW_WIDTH - self.nameFont:getWidth("locked")) - 200, y + (self.height - self.nameFont:getHeight()) / 2)
    end

    love.graphics.setFont(self.descriptionFont)

    local description = self.description
    if not self.unlocked and self.secret then
        description = "Hidden until unlocked"
    end
    love.graphics.print(description, x + (8 + bigTrophyImage:getWidth()) + 16, y + self.nameFont:getHeight())
end

function popup:unlock(forced, unlocked, date)
    self.date = date or os.date("%m.%d.%Y")
    self.unlocked = unlocked or (true and not forced)

    if not forced and not unlocked then
        unlockSound:play()
        save:write(true)
    end
end

function popup:isUnlocked()
    return self.unlocked
end

return popup