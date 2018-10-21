require 'vars'
require "libraries.core"

state = require 'libraries.state'
achievements = require 'libraries.achievement'

require 'libraries.character'

local star = require 'classes.common.star'

love.graphics.setDefaultFilter("nearest", "nearest")
io.stdout:setvbuf("no")

local function saveData()
    local achievmentData = {}
    for k, v in ipairs(achievements.achievements) do
        achievmentData[v.name] = {unlocked = v.unlocked, date = v.date}
    end

    local input = 
    {
        highscores = HIGHSCORES, 
        achievements = achievmentData, 
        controls = CONTROLS
    }

    local out = save:format(input)
    save:encode(out)
end

function love.load()
    core.init("Switch")

    --save/load data

    save.write = saveData
    if save:hasData() and save:get("date") then
        HIGHSCORES = save:get("highscores")
        CONTROLS = save:get("controls")

        local achievementSave = save:get("achievements") or {}
        for k, v in ipairs(achievements.achievements) do
            for j, w in pairs(achievementSave) do
                if v.name == j then
                    print(w.unlocked, j)
                    v:unlock(true, w.unlocked, w.date)
                end
            end
        end
    end

    math.randomseed(os.time())

    STARFIELDS = {}
    for fieldIndex = 1, FIELDCOUNT do
        STARFIELDS[fieldIndex] = {}
        for starCount = 1, math.floor(STARLIMIT / FIELDCOUNT) do
            table.insert(STARFIELDS[fieldIndex], star:new(math.random(0, WINDOW_WIDTH), math.random(0, WINDOW_HEIGHT), fieldIndex))
        end
    end

    love.audio.setVolume(0)

    titleSong = love.audio.newSource("audio/music/menu.ogg", "stream")
    titleSong:setLooping(true)

    state:change("intro")
end

function love.update(dt)
    dt = math.min(1 / 30, dt)

    for layer, objects in ipairs(STARFIELDS) do
        for _, star in ipairs(objects) do
            if not state:get("paused") then
                star:update(dt)
            end
        end
    end

    state:update(dt)
    achievements:update(dt)
end

function love.draw()
    for layer, objects in ipairs(STARFIELDS) do
        for _, star in ipairs(objects) do
            star:draw()
        end
    end

    state:draw()
    achievements:draw()
end

function love.gamepadpressed(joy, button)
    state:gamepadpressed(joy, button)
end

function love.gamepadaxis(joy, axis, value)
    state:gamepadaxis(joy, axis, value)
end