local CAN_UNLOCK = false

return
{
    name = "Trio Ping",
    description = "Kill three bats with one laser",

    source = 
    {
        class = "enemy",
        func  = "die"
    },

    hook = function(self, force)
        local player = state:get("player")
        local combos = state:get("combo")

        if player:getPowerup("laser") then
            if combos == 3 then
                CAN_UNLOCK = true
            end
        end
    end,

    isValid = function()
        return CAN_UNLOCK
    end
}