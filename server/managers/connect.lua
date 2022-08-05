--// Player Connected
RegisterServerEvent("Utility:Loaded")
AddEventHandler("Utility:Loaded", function()
    local source = source
    local identifier = GetuPlayerIdentifier(source)

    --print(Utility.DatabaseLoaded)
    while not Utility.DatabaseLoaded do
        Citizen.Wait(1)
    end
    
    local uPlayer = GetPlayer(identifier)

    if uPlayer then
        if not uPlayer:IsPreBuilded() and not uPlayer:IsBuilded() then 
            uPlayer:PreBuild()
        end
    
        if not uPlayer:IsBuilded() then
            uPlayer:Build(source)
        end
    
        for k,v in pairs(uPlayer) do
            if type(v) ~= "function" then
                --print("Setting "..tostring(k).." to "..tostring(v).." for "..tostring(source))
                Player(source).state[k] = v
            end
        end
    else
        error("Player "..identifier.." not found")
    end
end)


-- Maintenance, Ban and Steam check
AddEventHandler("playerConnecting", function(name, setKickReason, deferrals)
    local _source = source
    local identifier = GetuPlayerIdentifier(_source)

    if not GetuPlayerIdentifier(_source) then
        Log("NoIdentifier", "The player "..name.." dont have "..Config.Database.Identifier.." opened")

        CancelEvent()
        setKickReason("Utility Framework: Unable to find "..Config.Database.Identifier..", please relaunch FiveM")
    else
        local uPlayer = Utility.Players[identifier]

        if uPlayer and uPlayer:IsBuilded() then
            CancelEvent()
            setKickReason("Utility Framework: Duplicate "..Config.Database.Identifier..", try again in a while")
            return
        end

        if Config.Maintenance then
            if not Config.Group[identifier] then
                CancelEvent()
                setKickReason("Utility Framework: "..ts.translate(Config.DefaultLanguage, Config.Labels["framework"]["Maintenance"]))        
            end
        else
            local identifiers = {}

            for k,v in pairs(GetPlayerIdentifiers(_source))do                            
                if v:find("steam:") then
                    identifiers[1] = v
                elseif v:find("ip:") then
                    identifiers[2] = v
                elseif v:find("discord:") then
                    identifiers[3] = v
                elseif v:find("live:") then
                    identifiers[4] = v
                elseif v:find("license:") then
                    identifiers[5] = v
                elseif v:find("xbl:") then
                    identifiers[6] = v
                end
            end

            for i=1, #Utility.Bans do
                if type(Utility.Bans[i].data) == "string" then
                    Utility.Bans[i].data = json.decode(Utility.Bans[i].data)
                end
                if type(Utility.Bans[i].token) == "string" then
                    Utility.Bans[i].token = json.decode(Utility.Bans[i].token)
                end

                -- Normal data
                
                if Utility.Bans[i].data[1] == identifiers[1] or Utility.Bans[i].data[2] == identifiers[2] or Utility.Bans[i].data[3] == identifiers[3] or Utility.Bans[i].data[4] == identifiers[4] or Utility.Bans[i].data[5] == identifiers[5] or Utility.Bans[i].data[6] == identifiers[6] then
                    CancelEvent()
                    setKickReason("Utility Framework: "..ts.translate(Config.DefaultLanguage, Config.Labels["framework"]["Banned"]))    
                    print("[^1INFO^0] "..name.." tried to join but is ^1banned^0! [Rejection Type: Datas]")   
                    return
                end

                -- Tokens
                for i2=0, #Utility.Bans[i].token do
                    for i3=0, GetNumPlayerTokens(_source) do
                        if GetPlayerToken(_source, i3) then
                            if Utility.Bans[i].token[i2] == GetPlayerToken(_source, i3) then
                                CancelEvent()
                                setKickReason("Utility Framework: "..ts.translate(Config.DefaultLanguage, Config.Labels["framework"]["Banned"])) 
                                print("[^1INFO^0] "..name.." tried to join but is ^1banned^0! [Rejection Type: Tokens]")   
                                return
                            end
                        end
                    end
                end
            end

            if not Utility.Players[identifier] then
                local uPlayer = GeneratePlayer(_source, identifier)
                uPlayer:PreBuild()

                -- Log
                if Config.Logs.Connection.NewUser then 
                    print(Config.PrintType["new"]..ts.translate(Config.DefaultLanguage, Config.Labels["framework"]["ConnectedUser"]):format(uPlayer.name)) 
                    Log("Connection", "New user "..uPlayer.name.." connected and created")
                end
            else
                local uPlayer = Utility.Players[identifier]
                uPlayer:PreBuild()

                -- Log
                if Config.Logs.Connection.OldUser then 
                    print(Config.PrintType["old"]..ts.translate(Config.DefaultLanguage, Config.Labels["framework"]["ConnectedUser"]):format(uPlayer.name)) 
                    Log("Connection", "Old user "..uPlayer.name.." connected")
                end
            end
        end
    end
end)