local audio = {}

function audio:_load()
    self.sources = {}

    local pathInfo =
    {
        {"audio", "static"},
        {"audio/music", "stream"}
    }

    for i = 1, #pathInfo do
        self:_loadSources(pathInfo[i][1], pathInfo[i][2])
    end
end

function audio:_loadSources(dir, type)
    local items = love.filesystem.getDirectoryItems(dir)

    for i = 1, #items do
        local item = items[i]
        local path = dir .. "/" .. item
        local info = love.filesystem.getInfo(path)
        local name = item:gsub(".ogg", "")

        if info and info.type == "file" then
            local source = love.audio.newSource(path, type)

            if type == "stream" then
                source:setLooping(true)
            end

            self.sources[name] = source
        end
    end
end

function audio:play(name)
    if not self.sources[name] then
        print("Could not play source: " .. name .. "!")
        return
    end

    self.sources[name]:stop()
    self.sources[name]:play()
end

function audio:stop(name)
    if not self.sources[name] then
        print("Could not stop source: " .. name .. "!")
        return
    end

    self.sources[name]:stop()
end

function audio:isPlaying(name)
    if not self.sources[name] then
        print("Could not check source if playing: " .. name .. "!")
        return
    end

    return self.sources[name]:isPlaying()
end

audio:_load()
return audio
