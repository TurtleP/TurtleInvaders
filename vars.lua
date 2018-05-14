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

CONTROLS =
{
	{
		["left"] = "dpleft",
		["right"] = "dpright",
		["shoot"] = "b",
		["ability"] = "a"
	}
}

--USEFUL FUNCTIONS
function string:split(delimiter) --Not by me
	local result = {}
	local from   = 1
	local delim_from, delim_to = string.find( self, delimiter, from   )
	while delim_from do
		table.insert( result, string.sub( self, from , delim_from-1 ) )
		from = delim_to + 1
		delim_from, delim_to = string.find( self, delimiter, from   )
	end
	table.insert( result, string.sub( self, from   ) )
	return result
end

function addZeros(text, limit)
	local text = tostring(text)

	for j = #text + 1, limit do
		text = "0" .. text
	end
	return text
end