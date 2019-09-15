local AnimationSystem = System({Components.Sprite, Components.Animation})

function AnimationSystem:update(dt)
    for _, entity in ipairs(self.pool) do
        local spriteData    = entity:get(Components.Sprite)
        local animationData = entity:get(Components.Animation)
        local frames

        if type(animationData.animation) == "table" then
            frames = animationData.animation[animationData.state].frames
            local index = math.floor(animationData.timer % #frames) + 1

            if animationData.animation[animationData.state].stopAtEnd then
                if index >= #animationData.animation[animationData.state].frames then
                    return
                end
            end

            animationData.timer = animationData.timer + animationData.animation[animationData.state].rate * dt

            animationData.quadIndex = animationData.animation[animationData.state].frames[index]

            spriteData.quad = spriteData.quads[animationData.quadIndex]
        else
            frames = spriteData.quads

            animationData.timer = animationData.timer + animationData.rate * dt

            animationData.quadIndex = math.floor(animationData.timer % #frames) + 1

            spriteData.quad = spriteData.quads[animationData.quadIndex]
        end

        if animationData.removeOnFinish then
            if animationData.quadIndex >= #frames then
                state:call("removeEntity", entity)
            end
        end
    end
end

function AnimationSystem:entityRemoved(entity)
    local spriteData = entity:get(Components.Sprite)
    spriteData.quad = spriteData.quads[1]
end

return AnimationSystem
