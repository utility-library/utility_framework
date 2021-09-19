local self = {
    create = function(time)
        -- Classes
        local cooldownClasses = {
            timer = os.clock()*1000
        }

        cooldownClasses.ended = function() 
            local ended = cooldownClasses.cooldown() > time

            if ended then
                cooldownClasses.timer = os.clock()*1000
            end

            return ended
        end

        cooldownClasses.cooldown = function()
            return ((os.clock()*1000) - cooldownClasses.timer)
        end
        
        return cooldownClasses
    end
}

return self