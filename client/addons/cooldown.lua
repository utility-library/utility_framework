local self = {
    create = function(time)
        -- Classes
        local cooldownClasses = {
            timer = GetGameTimer()
        }

        cooldownClasses.ended = function() 
            local ended = cooldownClasses.cooldown() > time

            if ended then
                cooldownClasses.timer = GetGameTimer()
            end

            return ended
        end

        cooldownClasses.cooldown = function()
            return GetGameTimer() - cooldownClasses.timer
        end
        
        return cooldownClasses
    end
}

return self