local CAN_UNLOCK = false

return
{
    name = "Average Gamer",
    description = "Clear the game on Medium",

    source = 
    {
        class = "boss",
        func  = "die"
    },

    hook = function(self)
        if GAME_DIFFICULTY == 2 then
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