local PATH = (...):gsub("%.init$", "")

require(PATH .. ".logger")

logger.info("loading default controls")
local controlsPath = "data/core/controls.json"
controls = json:decode(love.filesystem.read(controlsPath))

-- load core things
logger.info("fonts loaded in %.3fms", _env.MEASURE_TIME(function()
    require(PATH .. ".fonts")
end))

logger.info("loaded audio in %.3fms", _env.MEASURE_TIME(function()
    require(PATH .. ".audio")
end))
