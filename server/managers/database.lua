GenerateQueryFromTable = function(_type, uPlayer, coords)
    local uPlayerReadyForDB = {
        identifier = uPlayer.uidentifier
    }
    
    if Config.Actived.Jobs then 
        local compressed_jobs = {}

        for i=1, #uPlayer.jobs do 
            table.insert(compressed_jobs, {[1] = uPlayer.jobs[i].name, [2] = uPlayer.jobs[i].grade and uPlayer.jobs[i].grade.id or 1, [3] = uPlayer.jobs[i].onduty}) 
        end
        
        uPlayerReadyForDB.jobs = compressed_jobs
    end
    if Config.Actived.Identity then 
        uPlayerReadyForDB.identity = uPlayer.identity
    end
    if Config.Actived.Accounts then 
        uPlayerReadyForDB.accounts = uPlayer.accounts
    end
    if Config.Actived.Inventory then 
        uPlayerReadyForDB.inventory = uPlayer.inventory
    end
    if Config.Actived.License then
        uPlayerReadyForDB.licenses = uPlayer.licenses
    end
    if Config.Actived.Weapons then
        uPlayerReadyForDB.weapons = uPlayer.weapons
    end
    if Config.Actived.Bills then
        uPlayerReadyForDB.bills = uPlayer.bills
    end
    if Config.Actived.Coords then
        uPlayerReadyForDB.coords = {
            [1] = mathm.round(coords.x, 2),
            [2] = mathm.round(coords.y, 2),
            [3] = mathm.round(coords.z, 2)
        }

        uPlayer.coords = uPlayerReadyForDB.coords
    end

    if _type == "INSERT" then
        if Config.Database.SaveNameInDb then uPlayerReadyForDB.name = uPlayer.name end

        local params = {}
        local names = ""        
        local values = ""        

        for k,v in pairs(uPlayerReadyForDB) do
            if type(v) == "table" then
                params[k] = json.encode(v)
            else
                params[k] = v
            end

            names = names..k..","
            values = values..":"..k..","
        end

        names = names:sub(1, -2)
        values = values:sub(1, -2)

        local query = 'INSERT INTO users ('..names..') VALUES ('..values..')'
        return query, params
    elseif _type == "UPDATE" then
        local set = ""        
        local params = {
            last_quit = os.date("%Y-%m-%d")
        }

        for k,v in pairs(uPlayerReadyForDB) do
            local skip = false

            if type(v) == "table" then
                if next(v) ~= nil then
                    params[k] = json.encode(v)
                else
                    skip = true
                end
            else
                params[k] = v
            end
            
            if k ~= "identifier" and not skip then
                set = set.." "..k.." = :"..k.."," 
            end
        end

        local query = 'UPDATE users SET '..set..' last_quit = :last_quit WHERE identifier = :identifier'
        return query, params
    end
end

AddEventHandler('onResourceStop', function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then
        return
    end
    
    -- Save all players in the database (prevent lose of data for new players)
    for _, v in ipairs(GetPlayers()) do
        local uPlayer = GetPlayer(tonumber(v))

        if uPlayer and uPlayer.source then -- If the player is online
            local coords = GetEntityCoords(GetPlayerPed(uPlayer.source))
    
            if uPlayer.IsNew then
                local query, params = GenerateQueryFromTable("INSERT", uPlayer, coords)
                MySQL.Async.execute(query, params)
            else
                local query, params = GenerateQueryFromTable("UPDATE", uPlayer, coords)
                MySQL.Async.execute(query, params)
            end
        end
    end

    TriggerEvent("utilityFrameworkRestarted")
end)