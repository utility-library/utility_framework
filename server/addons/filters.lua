GetClock = function()
    return os.clock()*1000
end

local lastcalled = {}
local self = {
    time = function(source, time)
        if lastcalled[source] then
            if (GetClock() - lastcalled[source]) > time then
                lastcalled[source] = GetClock()
                return true
            else
                return false
            end
        else
            lastcalled[source] = GetClock()
            return true
        end
    end,
    amount = function(value, min, max)
        if value >= min and value <= max then
            return true
        else
            return false
        end
    end,
    near = function(coords, distance)
        if #(GetEntityCoords(GetPlayerPed(source)) - coords) < distance then
            return true
        else
            return false
        end
    end,
    all = function(source, options)
        local time, amount, near = true, true, true
        
        if options.time then
            time = self.time(source, options.time)
        end
        
        if options.value then
            amount = self.amount(options.value[1], options.value[2], options.value[3])
        end
        
        if options.coords then
            near = self.near(options.coords, options.distance)
        end

        if time and amount and near then
            return true
        else
            return false
        end
    end
}

return self