local intro = class("intro")

function intro:load()
    self.introText =
    {
        "Warning",
        "",
        "This game auto saves.",
        "Do not turn off the power",
        "when you see this icon",
        "",
        "between screens."
    }

    self.introFont = love.graphics.newFont("graphics/upheval.ttf", 60)

    self.batImage = love.graphics.newImage("graphics/game/enemies/bat.png")
    self.batQuads = {}
    for y = 1, 2 do
        self.batQuads[y] = {}
        for x = 1, 3 do
            self.batQuads[y][x] = love.graphics.newQuad((x - 1) * 90, (y - 1) * 42, 90, 42, self.batImage:getWidth(), self.batImage:getHeight())
        end
    end
    self.batTimer = 0
    self.batQuad = 1

    self.batPostion = vector((WINDOW_WIDTH - 90) / 2, 456)

    self.loveLogo = love.graphics.newImage("graphics/intro/logo.png")

    self.loveJingle = love.audio.newSource("audio/jingle.ogg", "static")
    self.loveJingle:play()

    self.logoFade = 0
    self.textFade = 0

    self.timer = 0

    self.intro = false
end

function intro:update(dt)
    self.batTimer = self.batTimer + 8 * dt
    self.batQuad = math.floor(self.batTimer % 3) + 1

    if self.logoFade < 1 and not self.intro then
        self.logoFade = math.min(self.logoFade + 0.5 * dt, 1)
    else
        self.intro = true
        self.logoFade = math.max(self.logoFade - 0.5 * dt, 0)

        if self.logoFade < 0.3 then
            self.textFade = math.min(self.textFade + dt / 0.8, 1)

            if self.textFade == 1 then
                self.timer = self.timer + dt
                if self.timer > 3 then
                    state:change("title")
                end
            end
        end
    end
end

function intro:draw()
    love.graphics.setFont(self.introFont)

    love.graphics.setColor(1, 1, 1, 1 * self.logoFade)
    love.graphics.draw(self.loveLogo, (WINDOW_WIDTH - self.loveLogo:getWidth()) / 2, (WINDOW_HEIGHT - self.loveLogo:getHeight()) / 2)

    love.graphics.setColor(1, 1, 1, 1 * self.textFade)
    for i = 1, #self.introText do
        love.graphics.print(self.introText[i], (WINDOW_WIDTH - self.introFont:getWidth(self.introText[i])) / 2, 150 + (i - 1) * 60)
    end

    love.graphics.draw(self.batImage, self.batQuads[1][self.batQuad], self.batPostion.x, self.batPostion.y)
    love.graphics.draw(self.batImage, self.batQuads[2][self.batQuad], self.batPostion.x, self.batPostion.y)
end

function intro:gamepadpressed(joy)
    if joy:getID() ~= 1 then
        return
    end
    
    state:change("title")
end

function intro:destroy()
    love.audio.stop()
    
    self.introText = nil
    self.loveLogo = nil
    self.loveJingle = nil

    self.font = nil

    self.batImage = nil
    self.batQuads = nil
end

return intro