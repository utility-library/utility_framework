local self = {
    start = function(time)
        -- Classes
        local cooldownClasses = {
            timer = GetGameTimer()
        }

        cooldownClasses.on = function() 
            local ended = ((GetGameTimer() - cooldownClasses.timer) < 0)

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