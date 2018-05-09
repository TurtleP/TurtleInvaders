local game = class("game")

require 'classes.game.entity'
require 'classes.game.barrier'

require 'classes.game.effects.explosion'

require 'classes.game.enemies.enemy'

require 'classes.game.entities.bullet'
require 'classes.game.entities.player'

require 'classes.game.utility.timer'

require 'libraries.physics'

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

	self.score = 0
end

function game:update(dt)
	self.enemyTimer:update(dt)

	physicsupdate(dt)
end

function game:draw()
	for _, objectLayer in pairs(self.objects) do
		for _, object in ipairs(objectLayer) do
			object:draw()
		end
	end
end

function game:gamepadpressed(joy, button)
	local _id = joy:getID()

	if button == "a" then
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

function game:addScore(score)
	self.score = self.score + score
end

return game