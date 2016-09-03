local ability = {}
ability.description = "Freeze time to stop bats"

function ability:init(parent)
    self.initialize = true
    self.timer = 6
    
    for k, v in pairs(objects["bat"]) do
        v:freeze(true)
    end
end

function ability:update(dt)
    if not self.initialize then
        return
    end
    
    if self.timer > 0 then
        self.timer = self.timer - dt
    else
        for k, v in pairs(objects["bat"]) do
            if v.frozen then
                v:freeze(false)
            end
        end
        self.initialize = false
    end
end

function ability:trigger(parent)
    if parent then
	    self:init(parent)
	end
end

return ability