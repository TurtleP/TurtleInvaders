logger = {}

logger.ENABLED = 1
logger.FILENAME = "logs/" .. os.date("%m-%d-%Y") .. ".log"
logger.VERBOSE = 0
logger.FILE = nil
logger.VERSION = "2019.06.10"

local function log(level, strformat, ...)
    if not logger.ENABLED then
        return
    end

    local datetime = os.date("%m/%d/%Y %H:%M")
    local padding = string.rep(" ", 6)

    local outString = string.format("%s %s %s : => %s", datetime, level, padding, strformat:format(...))

    logger.FILE:write(outString .. "\n")
    logger.FILE:flush()

    if logger.VERBOSE ~= 0 then
        print(outString)
    end
end

function logger.initialize()
    if not logger.ENABLED then
        return
    end

    if not love.filesystem.getInfo(logger.FILENAME, "file") then
        love.filesystem.createDirectory("logs")
    end
    logger.FILE = love.filesystem.newFile(logger.FILENAME, "w")

    logger.dumpMeta()
end

function logger.dumpMeta()
    logger.info("Application Title: %s", love.window.getTitle())
    logger.info("Operating System: %s", love.system.getOS())
    
    local device = {love.graphics.getRendererInfo()}
    logger.info("GPU Info: %s %s (%s %s)", unpack(device))

    logger.info("Program Version %s", _env.VERSION)
    
    local version = {love.getVersion()}
    logger.info("LÖVE Version: %s", unpack(version))
end

function logger.info(message, ...)
    log("INFO", message, ...)
end

function logger.warn(message, ...)
    log("WARNING", message, ...)
end

function logger.crit(message, ...)
    log("CRITICAL", message, ...)
end

logger.initialize()
