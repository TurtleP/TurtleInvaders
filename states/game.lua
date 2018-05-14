local game = class("game")

require 'classes.common.entity'

require 'classes.game.effects.explosion'

require 'classes.game.enemies.enemy'

require 'classes.game.entities.barrier'
require 'classes.game.entities.bullet'
require 'classes.game.entities.player'

require 'classes.game.utility.timer'

require 'classes.game.ui.info'

require 'libraries.physics'

local waveSound = love.audio.newSource("audio/wave.ogg", "static")

function game:load(players)
	self.objects = {}

	self.objects["barrier"] = {}
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
end

function game:newWave(force)
	local pass = false or force

	if self.kills == self.baseKills then
		pass = true
		self.baseKills = math.ceil(self.kills + (self.baseKills * 0.5) ^ 1.5)
		self.kills = 0
		print(self.baseKills)
	end

	if pass then
		waveSound:play()
		self.wave = self.wave + 1
	end
end

function game:update(dt)
	self.enemyTimer:update(dt)

	self.comboTimer:update(dt)

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
end

function game:gamepadpressed(joy, button)
	local _id = joy:getID()

	if button == "b" then
		self.objects["player"][_id]:shoot()
	end
end

function game:gamepadaxis(joy, axis, value)
	local _id = joy:getID()

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
end

function game:addKills(value)
	self.kills = self.kills + value
end

function game:addScore(score)
	self.score = self.score + (score * self.combo)
end

return game