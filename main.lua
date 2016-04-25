_EMULATEHOMEBREW = (love.system.getOS() ~= "3ds")

util = require 'libraries.util'
class = require 'libraries.middleclass'

require 'libraries.physics'
require 'libraries.character'
require 'libraries.functions'

require 'libraries.potion-compat'

require 'classes.star'
require 'classes.timer'
require 'classes.bat'
require 'classes.barrier'
require 'classes.bullet'
require 'classes.player'
require 'classes.explosion'
require 'classes.display'
require 'classes.powerup'
require 'classes.megacannon'
require 'classes.fizzle'

require 'states.intro'
require 'states.title'
require 'states.game'
require 'states.options'
require 'states.charselect'
require 'states.loading'

io.stdout:setvbuf("no")

--[[
	A note worth reading:

	This game was originally made for PC/Mac/Linux/Android devices. This is the Nintendo 3DS homebrew port. You know what I have to work with here?
	Right now it's Love Potion 1.0.8 which can only use up to two fonts and we haven't got audio streaming. This is a big deal since the original
	version used a shitton of audio and fonts. I've got to hotswap fonts and music as needed so it's a pain but worth it!

	If you enjoy this, please private message me on GBATemp.net (TurtleP)! You can find my website at:

	http://TurtleP.github.io/
--]]

function love.load()
	love.graphics.setDefaultFilter("nearest", "nearest")

	introImage = love.graphics.newImage("graphics/intro/intro.png")
	potionImage = love.graphics.newImage("graphics/intro/potionlogo.png")

	titleImage = love.graphics.newImage("graphics/menu/title.png")

	batImage = love.graphics.newImage("graphics/game/bat.png")
	batQuads = {}
	for x = 1, 3 do
		batQuads[x] = {}
		for y = 1, 2 do
			batQuads[x][y] = love.graphics.newQuad((x - 1) * 30, (y - 1) * 14, 30, 14, batImage:getWidth(), batImage:getHeight())
		end
	end

	explosionImage = love.graphics.newImage("graphics/game/explosion.png")
	explosionQuads = {}
	for k = 1, 7 do
		explosionQuads[k] = love.graphics.newQuad((k - 1) * 18, 0, 16, 16, explosionImage:getWidth(), explosionImage:getHeight())
	end

	healthImage = love.graphics.newImage("graphics/game/health.png")
	healthQuads = {}
	for x = 1, 2 do
		healthQuads[x] = {}
		for y = 1, 2 do
			healthQuads[x][y] = love.graphics.newQuad((x - 1) * 8, (y - 1) * 8, 8, 8, healthImage:getWidth(), healthImage:getHeight())
		end
	end

	powerupDisplayImage = love.graphics.newImage("graphics/game/powerupdisplay.png")
	powerupDisplayQuads = {}
	for y = 1, 2 do
		for x = 1, 7 do
			table.insert(powerupDisplayQuads, love.graphics.newQuad((x - 1) * 65, (y - 1) * 65, 64, 64, powerupDisplayImage:getWidth(), powerupDisplayImage:getHeight()))
		end
	end
	
	powerupImage = love.graphics.newImage("graphics/game/powerups.png")
	powerupQuads = {}
	for k = 1, 10 do
		powerupQuads[k] = love.graphics.newQuad((k - 1) * 19, 0, 18, 18, powerupImage:getWidth(), powerupImage:getHeight())
	end

	megaCannonBaseImage = love.graphics.newImage("graphics/game/boombase.png")
	megaCannonBaseQuads = {}
	local boomBaseLimit = {6, 2}
	for y = 1, 2 do
		for x = 1, boomBaseLimit[y] do
			table.insert(megaCannonBaseQuads, love.graphics.newQuad((x - 1) * 80, (y - 1) * 80, 80, 80, megaCannonBaseImage:getWidth(), megaCannonBaseImage:getHeight()))
		end
	end

	megaCannonBoomImage = love.graphics.newImage("graphics/game/boom.png")
	megaCannonBoomQuads = {}
	local boomLimit = {6, 6, 3}
	for y = 1, 3 do
		for x = 1, boomLimit[y] do
			table.insert(megaCannonBoomQuads, love.graphics.newQuad((x - 1) * 80, (y - 1) * 80, 80, 80, megaCannonBoomImage:getWidth(), megaCannonBoomImage:getHeight()))
		end
	end

	megaCannonBeamImage = love.graphics.newImage("graphics/game/beam.png")
	megaCannonBeamQuads = {}
	for k = 1, 5 do
		megaCannonBeamQuads[k] = love.graphics.newQuad((k - 1) * 22, 0, 22, 22, megaCannonBeamImage:getWidth(), megaCannonBeamImage:getHeight())
	end

	cursorImage = love.graphics.newImage("graphics/menu/cursor.png")

	love.graphics.set3D(true)

	menuSong = love.audio.newSource("audio/menu.wav")
	
	waveAdvanceSound = love.audio.newSource("audio/wave.wav")
	gameOverSound = love.audio.newSource("audio/gameover.wav")

	bulletSound = love.audio.newSource("audio/bullet.wav")
	laserSound = love.audio.newSource("audio/laser.wav")

	explodeSound = love.audio.newSource("audio/explode.wav")

	pauseSound = love.audio.newSource("audio/pause.wav")

	addLifeSound = love.audio.newSource("audio/oneup.wav")

	fizzleSound = love.audio.newSource("audio/evaporate.wav")
	megaCannonSound = love.audio.newSource("audio/megacannon.wav")

	hurtSound = {}
	for k = 1, 3 do
		hurtSound[k] = love.audio.newSource("audio/hurt" .. k .. ".wav")
	end

	loadCharacters()

	difficulties = 
	{
		"Easy",
		"Medium",
		"Hard"
	}

	difficultyi = 2

	gameModes =
	{
		"Arcade",
		"Endless"
	}

	gameModei = 1

	controls =
	{
		left = "cpadleft",
		right = "cpadright",
		shoot = "b",
		ability = "a"
	}

	directionPadEnabled = false

	util.changeState("intro")

	love.audio.setVolume(0)
end

function love.update(dt)
	util.updateState(dt)
end

function love.draw()
	util.renderState()
end

function love.keypressed(key)
	util.keyPressedState(key)
end

function love.keyreleased(key)
	util.keyReleasedState(key)
end

if _EMULATEHOMEBREW then
	require 'libraries.3ds'
end