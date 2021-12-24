local function SaveSocieties()
    if not Utility.SocietyAlreadySaved then
        Utility.SocietyAlreadySaved = true
        Log("Save", "Saving automatically society why the server is shutting down")
        
        for k,v in pairs(Utility.SocietyData) do
            oxmysql:executeSync('UPDATE society SET money = :money, deposit = :deposit, weapon = :weapon WHERE name = :name', {
                money   = json.encode(v.money),
                deposit = json.encode(v.deposit or {}),
                weapon  = json.encode(v.weapon or {}),
                name    = k
            })
        end
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
    if reason:find("Server shutting down") then
        SaveSocieties()
    end

    SaveArmour(uPlayer, armour)

    if coords.x ~= 0.0 and coords.y ~= 0.0 then
        analizer.start()

        -- function.lua:649
        RemoveFromJob(uPlayer.jobs[1].name, uPlayer.source)

        if uPlayer.IsNew then
            local query, params = GenerateQueryFromTable("INSERT", uPlayer, coords)
            oxmysql:execute(query, params)
        else
            local query, params = GenerateQueryFromTable("UPDATE", uPlayer, coords)
            oxmysql:execute(query, params)
        end


        print("[SAVED] "..(uPlayer.name or "Unkown").." ["..(uPlayer.source or "unkown").."]")
        Log("Save", (uPlayer.name or "Unkown").." ["..(uPlayer.source or "unkown")..";"..(uPlayer.steam or "error").."] Disconnected, saved in "..analizer.finish().."ms")

        Citizen.Wait(500)
        uPlayer:Demolish()
    end
end)