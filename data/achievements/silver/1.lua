local CAN_UNLOCK = false

return
{
    name = "Risky Battle",
    description = "Defeat Risky Jacques",

    source = 
    {
        class = "racoon",
        func  = "die"
    },

    hook = function(self)
        if self.health <= 1 then
            CAN_UNLOCK = true
        end
    end,

    isValid = function()
        return CAN_UNLOCK
    end
}