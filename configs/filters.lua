Config.FilterModules = {
    Near = function(source, coords, range)
        local ped = GetPlayerPed(source)
        local selfCoords = GetEntityCoords(ped) 

        if #(coords - selfCoords) < (range or 5) then
            return true
        else
            return "is not close to the location"
        end
    end,
    Jobs = function(source, ...)
        local uPlayer = GetPlayer(source)
        local requiredJobs = {...}

        for jtype, jobs in pairs(requiredJobs) do
            for i=1, #jobs do
                if uPlayer.jobs[jtype].name == jobs[i] then -- one of the required jobs has been found
                    return true 
                end
            end
        end

        return "none of the required job was found"
    end,
    Items = function(source, items)
        local uPlayer = GetPlayer(source)
        local found = 0
        local i = 0

        for item, quantity in pairs(items) do
            i = i + 1
            if uPlayer.HaveItemQuantity(item, quantity) then
                found = found + 1
            end
        end

        return (found == i) or "not all required items were found"
    end
}