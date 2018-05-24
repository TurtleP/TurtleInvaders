local save = class("save")

function save:initialize()
    if not love.filesystem.getInfo("save.txt") then
        self:write() --default data :)
    end
    self:read()
end

function save:write(only_achievements)
    local achievmentData = {}
    for k, v in ipairs(achievements.achievements) do
        achievmentData[v.name] = {unlocked = v.unlocked, date = v.date}
    end

    local save =
    {
        date = os.date("%m.%d.%Y"),
        achievements = achievmentData, --error?
        controls = CONTROLS,
        highscores = HIGHSCORES
    }

    love.filesystem.write("save.txt", json:encode_pretty(save))
end

function save:read()
    local data = json:decode(love.filesystem.read("save.txt"))

    --load data
    HIGHSCORES = data.highscores
    CONTROLS = data.controls

    for k, v in ipairs(achievements.achievements) do
        for j, w in pairs(data.achievements) do
            if v.name == j then
                print(w.unlocked, j)
                v:unlock(true, w.unlocked, w.date)
            end
        end
    end

    self:write() --I guess
end

return save:new()