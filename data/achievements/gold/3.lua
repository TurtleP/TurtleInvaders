local CAN_UNLOCK = true

return
{
    name = "is this a hacker?",
    description = "Finish the game without losing a life",
    hidden = true,

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
        if not state:is("game") then
            return
        end

        local player = state:get("player")
        local endgame = state:get("wave") == MAX_WAVES

        if player:getHealth() < player:getMaxHealth() then
            CAN_UNLOCK = false
        end

        return CAN_UNLOCK and endgame
    end
}