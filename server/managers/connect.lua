--// Player Connected
RegisterServerEvent("Utility:Loaded")
AddEventHandler("Utility:Loaded", function()
    local source = source
    local steam = GetPlayerIdentifier(source, 0)

    while not Utility.DatabaseLoaded do
        Citizen.Wait(1)
    end
    
    local uPlayer = GetPlayer(steam)

    if uPlayer.__type ~= "uPlayer" then 
        uPlayer:Build(source)
    end

    uPlayer:ClientBuild(source)
    for k,v in pairs(Utility.PlayersData[steam]) do
        Player(source).state[k] = v
    end

    print("Loaded player "..steam)
end)


-- Maintenance, Ban and Steam check
AddEventHandler("playerConnecting", function(name, setKickReason, deferrals)
    local _source = source
    local identifiers = GetPlayerIdentifiers(_source)

    if not identifiers[1]:find("steam") then
        Log("NoSteam", "The player "..name.." dont have steam opened")

        CancelEvent()
        setKickReason("Utility Framework: Unable to find SteamId, please relaunch FiveM with steam open or restart FiveM & Steam if steam is already open")
    else
        if Config.Maintenance then
            if not Config.Group[identifiers[1]] then
                CancelEvent()
                setKickReason("Utility Framework: "..ts.translate(Config.DefaultLanguage, Config.Labels["framework"]["Maintenance"]))        
            end
        else
            local identifier = {}

            for k,v in pairs(GetPlayerIdentifiers(_source))do                            
                if v:find("steam:") then
                    identifier[1] = v
                elseif v:find("ip:") then
                    identifier[2] = v
                elseif v:find("discord:") then
                    identifier[3] = v
                elseif v:find("live:") then
                    identifier[4] = v
                elseif v:find("license:") then
                    identifier[5] = v
                elseif v:find("xbl:") then
                    identifier[6] = v
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
                if Utility.Bans[i].data[1] == identifier[1] or Utility.Bans[i].data[2] == identifier[2] or Utility.Bans[i].data[3] == identifier[3] or Utility.Bans[i].data[4] == identifier[4] or Utility.Bans[i].data[5] == identifier[5] or Utility.Bans[i].data[6] == identifier[6] then
                    CancelEvent()
                    setKickReason("Utility Framework: "..ts.translate(Config.DefaultLanguage, Config.Labels["framework"]["Banned"]))    
                    print("[^1INFO^0] "..name.." tried to join but is ^1banned^0! [Rejection Type: 1]")   
                    return
                end

                -- Tokens
                for i2=0, #Utility.Bans[i].token do
                    for i3=0, GetNumPlayerTokens(_source) do
                        if GetPlayerToken(_source, i3) then
                            if Utility.Bans[i].token[i2] == GetPlayerToken(_source, i3) then
                                CancelEvent()
                                setKickReason("Utility Framework: "..ts.translate(Config.DefaultLanguage, Config.Labels["framework"]["Banned"])) 
                                print("[^1INFO^0] "..name.." tried to join but is ^1banned^0! [Rejection Type: 2]")   
                                return
                            end
                        end
                    end
                end
            end

            local steam = identifier[1]

            if not Utility.PlayersData[steam] then
                local uPlayer = GeneratePlayer(_source, steam)
                uPlayer:Build()
                
                -- Log
                if Config.Logs.Connection.NewUser then 
                    print(Config.PrintType["new"]..ts.translate(Config.DefaultLanguage, Config.Labels["framework"]["ConnectedUser"]):format(uPlayer.name)) 
                    Log("Connection", "New user "..uPlayer.name.." connected and created")
                end
            else
                local uPlayer = Utility.PlayersData[steam]
                uPlayer:Build()

                -- Log
                if Config.Logs.Connection.OldUser then 
                    print(Config.PrintType["old"]..ts.translate(Config.DefaultLanguage, Config.Labels["framework"]["ConnectedUser"]):format(uPlayer.name)) 
                    Log("Connection", "Old user "..uPlayer.name.." connected")
                end
            end
        end
    end
end)