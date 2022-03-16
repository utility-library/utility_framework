function SaveSocieties()
    Log("Save", "Saving automatically society")
    
    for k,v in pairs(Utility.SocietyData) do
        MySQL.Sync.fetchAll('UPDATE society SET money = :money, deposit = :deposit, weapon = :weapon WHERE name = :name', {
            money   = json.encode(v.money),
            deposit = json.encode(v.deposit or {}),
            weapon  = json.encode(v.weapon or {}),
            name    = k
        })
    end
end
function SaveVehicles()
    Log("Save", "Saving automatically vehicles")
    
    for k,v in pairs(Utility.VehiclesData) do
        MySQL.Sync.fetchAll('UPDATE vehicles SET data = :data, trunk = :trunk WHERE plate = :plate', {
            data   = json.encode(v.data),
            trunk  = json.encode(v.trunk or {}),
            plate  = k
        })
    end
end

local function SaveArmour(uPlayer, armour)
    if Config.Actived.SaveArmour then
        if armour == 0 then
            uPlayer.other_info.armour = nil
        else
            uPlayer.other_info.armour = armour
        end
    end
end

AddEventHandler("playerDropped", function(reason)
    if reason:find(Config.Labels["framework"]["Banned"]) then return end
    local source = source
    local uPlayer = GetPlayer(source)
    
    local coords = GetEntityCoords(GetPlayerPed(source))
    local armour = GetPedArmour(GetPlayerPed(source))

    -- Society saving
    if #GetPlayers() < 2 then -- 1 or 0 (so if the player results as already quitted or not)
        TriggerEvent("onServerEmpty")
        SaveSocieties()
        SaveVehicles()
    end


    if reason:find("Server shutting down") then
        if not Utility.SocietyAlreadySaved then
            Utility.SocietyAlreadySaved = true
            TriggerEvent("onServerStop")
            SaveSocieties()
            SaveVehicles()
        end
    end

    SaveArmour(uPlayer, armour)

    if coords.x ~= 0.0 and coords.y ~= 0.0 then
        analizer.start()

        if uPlayer.IsNew then
            local query, params = GenerateQueryFromTable("INSERT", uPlayer, coords)
            MySQL.Sync.fetchAll(query, params)
        else
            local query, params = GenerateQueryFromTable("UPDATE", uPlayer, coords)
            MySQL.Sync.fetchAll(query, params)
        end

        if Config.Logs.AdvancedLog.actived.Save then 
            print("[^2SAVED^0] "..(uPlayer.name or "Unkown").." ["..(uPlayer.source or "unkown").."]")
        end

        Log("Save", (uPlayer.name or "Unkown").." ["..(uPlayer.source or "unkown").."] ["..(uPlayer.steam or "error").."] Disconnected, saved in "..analizer.finish().."ms")

        Citizen.Wait(500)
        uPlayer:Demolish()
    end
end)