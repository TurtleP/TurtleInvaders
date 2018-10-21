WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

FIELDCOUNT = 3
STARLIMIT = 256

GAME_VERSION = "2.0"
COPYRIGHT = "(C)"--"©"

SOUND_ENABLED = true
MUSIC_ENABLED = true

CHAR_DIRECTORY = "data/characters"

DIFFICULTIES = 
{
    "Easy",
    "Normal",
    "Hard"
}
GAME_DIFFICULTY = 2

GAME_MODES =
{
    "Arcade",
    "Endless"
}
GAME_MODE = 1

HIGHSCORES = {}
for i = 1, 5 do
    HIGHSCORES[i] = {"??????", "???"}
end

CONTROLS =
{
    ["left"] = "dpleft",
    ["right"] = "dpright",
    ["shoot"] = "b",
    ["ability"] = "a"
}

MAX_WAVES = 30

BOSS_WAVES = {}
BOSS_WAVES[10] = "megabat"
BOSS_WAVES[20] = "raccoon"
BOSS_WAVES[30] = true

function padText(text, rep, limit)
    local text = tostring(text)

    for j = #text + 1, limit do
        text = rep .. text
    end
    return text
end

function dateCompare(a, b)
    local dateA = a.date:split("%.")
    local dateB = b.date:split("%.")

    if not a.unlocked then
        return false
    elseif not b.unlocked then
        return true
    elseif not a.unlocked and not b.unlocked then
        return a.tier > b.tier
    end
    
    for i = 1, 3 do
        return tonumber(dateA[i]) < tonumber(dateB[i])
    end
end

function print_r(arr, concat, wrap)
    local str = ""
    local concat = concat or ", "

    if wrap == nil then
        print(print_r(arr, concat, 4))
        return
    end

    for i = 1, #arr do
        str = str .. arr[i] .. concat
        if (i % wrap) == 0 and i > 0 then
            str = str .. "\n"
        end
    end

    return str
end