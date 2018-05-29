local game = class("game")

require 'classes.common.entity'

require 'classes.game.effects.explosion'

require 'classes.game.enemies.enemy'

require 'classes.game.entities.barrier'
require 'classes.game.entities.bullet'
require 'classes.game.entities.player'

require 'classes.game.utility.roulette'
require 'classes.game.utility.timer'

require 'classes.game.ui.info'

require 'libraries.physics'

local waveSound = love.audio.newSource("audio/wave.ogg", "static")
local gameoverSound = love.audio.newSource("audio/gameover.ogg", "static")

function game:load(players)
    self.objects = {}

    self.objects["barrier"] = {}
    self.objects["boss"] = {}
    self.objects["bullet"] = {}
    self.objects["effect"] = {}
    self.objects["enemy"] = {}
    self.objects["player"] = {}

    --PLAYER SETUP
    table.insert(self.objects["player"], player:new(640, WINDOW_HEIGHT, players[1]))

    --BARRIERS
    table.insert(self.objects["barrier"], barrier:new(0))
    table.insert(self.objects["barrier"], barrier:new(WINDOW_WIDTH))

    physics_load(self.objects)

    self.enemyTimer = timer:new(1, function()
        enemy:new(math.random(0, WINDOW_WIDTH), -42)
    end)

    
    self.infoFont = love.graphics.newFont("graphics/upheval.ttf", 60)
    
    self.playerInfo = info:new(players[1].name, 24, 4, self.objects["player"][1])
    self.scoreInfo = info:new("Score", (WINDOW_WIDTH - self.infoFont:getWidth("Score")) / 2, 4)
    self.enemyInfo = info:new("Enemy", WINDOW_WIDTH - self.infoFont:getWidth("Enemy") - 20, 4)

    self.powerups = require 'data.powerups'
    self.roulette = nil

    --self:newRoulette()

    self.score = 0
    self.combo = 0
    self.wave = 0

    self.kills = 0
    self.baseKills = 10

    enemy.die = hook.add(enemy.die, function(self)
        if self.health <= 1 then
            local calls = { {"addCombo", 1}, {"addKills", 1}, {"newWave"} }
            state:call(calls)
        end
    end)

    self.comboTimer = timer:new(1, function()
        local combo = state:get("combo")
        state:call("addCombo", -combo)
    end,
    function()
        return state:get("combo") > 0
    end)

    self:newWave(true)
    self.waveFade = 1
    
    self.gameover = false
    self.paused = false
end

function game:generateSpawnCount(wave_number)
    return math.floor(self.baseKills + math.sqrt((wave_number * 10) + 3) ^ 1.5)
end

function game:newWave(force)
    local pass = force or self:canNewWave()

    if not pass then
        return
    end

    waveSound:play()

    self.wave = self.wave + 1
    self.waveFade = 1
    self.kills = 0
end

function game:canNewWave()
     if self.kills == self:generateSpawnCount(self.wave) then
        return true
    end
    return false
end

function game:update(dt)
    if self.gameover then
        if not gameoverSound:isPlaying() then
            state:change("highscores", true, padText(self.score, "0", 6))
        end
        return
    end

    if self.paused then
        return
    end

    if self.roulette then
        self.roulette:update(dt)

        if self.roulette.remove then
            self.roulette = nil
        end
    end

    self.enemyTimer:update(dt)

    self.comboTimer:update(dt)

    self.waveFade = math.max(self.waveFade - dt * 0.9, 0)

    physicsupdate(dt)
end

function game:draw()
    for _, objectLayer in pairs(self.objects) do
        for _, object in ipairs(objectLayer) do
            object:draw()
        end
    end
    
    love.graphics.setFont(self.infoFont)
    self.scoreInfo:draw(self.infoFont)
    self.enemyInfo:draw(self.infoFont)
    self.playerInfo:draw(self.infoFont)

    if self.roulette then
        self.roulette:draw()
    end

    if self.gameover then
        love.graphics.print("GAME OVER", (WINDOW_WIDTH - self.infoFont:getWidth("GAME OVER")) / 2, (WINDOW_HEIGHT - self.infoFont:getHeight()) / 2)
        return
    end

    love.graphics.setColor(1, 1, 1, 1 * self.waveFade)
    love.graphics.print("WAVE " .. self.wave, (WINDOW_WIDTH - self.infoFont:getWidth("WAVE " .. self.wave)) / 2, (WINDOW_HEIGHT - self.infoFont:getHeight()) / 2)

    if self.paused then
        love.graphics.setColor(0, 0, 0, 0.8)
        love.graphics.rectangle("fill", 0, 0, WINDOW_WIDTH, WINDOW_HEIGHT)

        love.graphics.setColor(1, 1, 1)
        love.graphics.print("GAME PAUSED", (WINDOW_WIDTH - self.infoFont:getWidth("GAME PAUSED")) / 2, (WINDOW_HEIGHT - self.infoFont:getHeight()) / 2)
    end
end

function game:gamepadpressed(joy, button)
    local _id = joy:getID()

    if button == "b" then
        self.objects["player"][_id]:shoot()
    elseif button == "plus" then
		if self.waveFade == 0 then
			self.paused = not self.paused
		end
    end
end

function game:gamepadaxis(joy, axis, value)
    local _id = joy:getID()

    if self.objects["player"][1]:isFrozen() then
        return
    end

    if axis == "leftx" then
        if value > 0.5 then
            self.objects["player"][_id]:moveRight()
        elseif value < -0.5 then
            self.objects["player"][_id]:moveLeft()
        else
            self.objects["player"][_id]:stopMoving()
        end
    end
end

function game:addCombo(value)
    self.combo = self.combo + value
    self.comboTimer:reset()
end

function game:addKills(value)
    self.kills = self.kills + value
end

function game:addScore(score)
    self.score = self.score + (score * self.combo)
end

function game:setGameover(value)
    self.gameover = value

    if value then
        gameoverSound:play()
    end
end

function game:newRoulette(clear)
    if clear then
        self.roulette = nil
        return
    end

    if self.roulette then
        return
    end
    self.roulette = roulette:new(self.powerups, self.playerInfo:getWidth(self.infoFont) + 8, 20)
end 

return game