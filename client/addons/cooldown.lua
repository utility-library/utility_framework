local self = {
    start = function(time)
        -- Classes
        local cooldownClasses = {
            timer = GetGameTimer()
        }

        cooldownClasses.on = function() 
            local ended = (cooldownClasses.time() > time)

            if ended then
                cooldownClasses.timer = GetGameTimer()
            end

            return ended
        end

        cooldownClasses.time = function()
            return GetGameTimer() - cooldownClasses.timer
        end
        
        return cooldownClasses
    end
}

return self