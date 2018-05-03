maxhighs = 10
maxenemybullets = 3

maxbatsonscreen = 20
batsshotdelay = {2, 4}
batsshotdelay2 = {2, 3}

shieldAnim = {}
shieldAnim["time"] = 0
shieldAnim["maxtime"] = 5
shieldAnim["x"] = 0
shieldAnim["y"] = 0
shieldAnim["maxsize"] = 200
shieldAnim["alive"] = false
batid = 0

shieldHealth = 16
shieldMiddleDamage = 6
shieldMinSize = .75

enemyspawnpowers = true 

gamecompleted = false

maxpowershots = 1

phoenixspeed = 280

emanceSpeed = 0.5

onlinetriggers = {}

gamepaddeadzone = 0.2

bossHP =
{
	{60, 100, 180},
	{100, 180, 340},
	{160, 260, 420}
}

fieldspeed = 15

nicknames = 
{
	"TurtleP",
	"Hugo",
	"Idiot9.0",
	"Someone",
	"QCode",
	"Pyro"
}

drawhud = true 

coretimer = love.math.random(12)

enemybulletdelay1 = {1.5}
enemybulletdelay2 = {0.5, 1}

width = 600
height = 300

gamemodes = {"Arcade", "Endless"}
gamemodei = 1

creditstext = 
{
"CREDITS:",
"",
"TURTLE: INVADERS",
"A GAME BY TINY TURTLE INDUSTRIES",
"",
"",
"PROGRAMMED BY:",
"TURTLEP",
"ROKIT BOY",
"",
"",
"ADDITIONAL CODE FROM:",
"PYROMANIAC",
"QCODE",
"AUTOMATIK - SAVING HIGHSCORES",
"",
"",
"CREDIT TO EXTERNAL LIBRARIES:",
"CRON - ENRIQUE GARCÍA COTA",
"HBDLIB - HUGOBDESIGNER",
"32LOG - LOVE2D WIKI",
"",
"",
"GRAPHICS BY:",
"HATNINJA",
"HUGOBDESIGNER",
"CHASE - PHONEIX AND BOSS HP",
"",
"",
"MUSIC AND SOUNDS BY:",
"KYLE_PRIOR",
"SAINT HAPPYFACES",
"",
"",
"LOVE 0.9.x PORT",
"PYROMANIAC",
"TURTLEP",
"",
"",
"CHARACTER GRAPHICS:",
"HUGOBDESIGNER",
"RENHOEK/HUGOBDESIGNER - GABEHOEX",
"CHASE - CHASE",
"JORICHI - SCUTTLES",
"FURIOUS - FURIOUSHEDGEHOG",
"POLYBIUS - HUGOBDESIGNER",
"SAULO - SAULO FX",
"IDIOT9.0 - SAULO FX",
"QWERTY - QwertymanO07",
"",
"",
"BETA TESTED BY:",
"HATNINJA",
"PYROMANIAC",
"HUGOBDESIGNER",
"MMAKER",
"JMIESTER14",
"FLUTTER SKYE",
"THUNDERFLIPPER",
"",
"",
"ONLINE MENU DESIGNS:",
"HUGOBDESIGNER",
"TURTLEP",
"",
"",
"THIS GAME IS LICENSED UNDER THE",
"ATTRIBUTION-NONCOMMERCIAL-SHAREALIKE 4.0 INTERNATIONAL",
"SEE: http://creativecommons.org/licenses/by-nc-sa/4.0/",
"",
"",
"",
"",
"VISIT US AT:",
"http://www.jpostelnek.blogspot.com",
"",
"",
"",
"",
"THANKS FOR PLAYING!"
}

--USEFUL/NEEDED FUNCTIONS BELOW--

function string:split(delimiter) --Not by me
	local result = {}
	local from  = 1
	local delim_from, delim_to = string.find( self, delimiter, from  )
	while delim_from do
		table.insert( result, string.sub( self, from , delim_from-1 ) )
		from = delim_to + 1
		delim_from, delim_to = string.find( self, delimiter, from  )
	end
	table.insert( result, string.sub( self, from  ) )
	return result
end

updatechar = ";"
--google docs .txt of a file that contains version numbers of each game
updatelink = "http://jpostelnek.blogspot.com/p/blog-page.html"
