local CAN_UNLOCK = false

return
{
    name = "Master Blaster",
    description = "Clear the game on Hard",

    source = 
    {
        class = "boss",
        func  = "die"
    },

	hook = function(self)
		if GAME_DIFFICULTY == 3 then
			if state:get("wave") == MAX_WAVES then
				if self.health <= 1 then
					CAN_UNLOCK = true
				end
			end
		end
    end,

    isValid = function()
        return CAN_UNLOCK
    end
}