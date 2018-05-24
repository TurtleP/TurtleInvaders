local CAN_UNLOCK = false

return
{
    name = "Easy Pickings",
    description = "Clear the game on Easy",
    
    source = 
    {
        class = "boss",
        func  = "die"
    },

    hook = function(self)
		if GAME_DIFFICULTY == 1 then
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