local CAN_UNLOCK = false

return
{
    name = "Combo Madness",
    description = "Get a 7-kill combo",

    source = 
    {
        class = "enemy",
        func  = "die"
    },

    hook = function(self)
        local count = state:get("combo")

        if count >= 7 then
            CAN_UNLOCK = true
        end
    end,

    isValid = function()
        return CAN_UNLOCK
    end
}