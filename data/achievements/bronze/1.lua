local CAN_UNLOCK = false

return
{
    name = "Hello World!",
    description = "Play the game for the first time",
    
    source = 
    {
        class = "state",
        func  = "change"
    },

    hook = function(self, state)
        if state == "title" then
            CAN_UNLOCK = true
        end
    end,

    isValid = function()
        return CAN_UNLOCK
    end
}