local CAN_UNLOCK = false

return
{
    name = "Spacing Out",
    description = "Defeat the mega bat",
    
    source = 
    {
        class = "boss",
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