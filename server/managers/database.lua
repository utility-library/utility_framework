GenerateQueryFromTable = function(_type, uPlayer, coords)
    local tab = {
        steam = uPlayer.steam:gsub("steam:110000", "")
    }

    if Config.Actived.Other_info.Position then            
        uPlayer.other_info.coords = {
            [1] = tonumber(string.format("%.2f", coords.x)),
            [2] = tonumber(string.format("%.2f", coords.y)),
            [3] = tonumber(string.format("%.2f", coords.z))
        }
    end

    local other_info = json.decode(json.encode(uPlayer.other_info))
    for k,v in pairs(other_info) do
        if type(v) == "table" then -- If is a empty table dont save it
            if next(v) == nil then
                other_info[k] = nil
            end
        elseif k == "isdead" and v == false then
            other_info[k] = nil
        end
    end
    
    tab.other_info = other_info

    if Config.Actived.Identity then 
        tab.identity = uPlayer.identity
    end
    if Config.Actived.Jobs then 
        local compressed_jobs = {}

        for i=1, #uPlayer.jobs do 
            print(json.encode(uPlayer.jobs))
            table.insert(compressed_jobs, {[1] = uPlayer.jobs[i].name, [2] = uPlayer.jobs[i].grade and uPlayer.jobs[i].grade.id or 1, [3] = uPlayer.jobs[i].onduty}) 
        end

        --print(json.encode(compressed_jobs))
        tab.jobs = compressed_jobs
    end
    if Config.Actived.Accounts then 
        tab.accounts = uPlayer.accounts
    end
    if Config.Actived.Inventory then 
        tab.inventory = uPlayer.inventory
    end


    if _type == "INSERT" then
        if Config.Database.SaveNameInDb then tab.name = uPlayer.name end

        local params = {}
        local names = ""        
        local values = ""        

        for k,v in pairs(tab) do
            if type(v) == "table" then
                params[k] = json.encode(v)
            else
                params[k] = v
            end

            names = names..k..","
            values = values..":"..k..","
        end

        local query = 'INSERT INTO users ('..names:sub(1, -2)..') VALUES ('..values:sub(1, -2)..')'
        return query, params
    elseif _type == "UPDATE" then
        local params = {}
        local set = ""        

        for k,v in pairs(tab) do
            if type(v) == "table" then
                params[k] = json.encode(v)
            else
                params[k] = v
            end
            
            if k ~= "steam" then
                set = set.." "..k.." = :"..k.."," 
            end
        end

        local last_quit = os.date("%Y-%m-%d")
        params["last_quit"] = last_quit

        local query = 'UPDATE users SET '..set..' last_quit = :last_quit WHERE steam = :steam'

        return query, params
    end
end

AddEventHandler('onResourceStop', function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then
        return
    end
    
    for _, v in ipairs(GetPlayers()) do
        local uPlayer = GetPlayer(tonumber(v))

        if uPlayer and uPlayer.source then
            local coords = GetEntityCoords(GetPlayerPed(uPlayer.source))
    
            if uPlayer.IsNew then
                local query, params = GenerateQueryFromTable("INSERT", uPlayer, coords)
                MySQL.Sync.fetchAll(query, params)
            else
                local query, params = GenerateQueryFromTable("UPDATE", uPlayer, coords)
                MySQL.Sync.fetchAll(query, params)
            end
        end
    end
end)