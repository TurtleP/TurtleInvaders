local Animation = Component(function(entity, animation, flags)
    entity.timer     = 0
    entity.quadIndex = 1

    entity.animation = animation
    entity.state = "idle"

    if not flags then
        flags = {}
    end

    entity.rate = flags.rate or 8
    entity.removeOnFinish = flags.removeOnFinish or false
end)

function Animation:ChangeState(newState)
    if self.state ~= newState then
        self.timer = 0
        self.quadIndex = 1
        self.state = newState
    end
end

return Animation
