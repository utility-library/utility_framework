oxmysql = exports["oxmysql"]
local SavedAddEventHandler = AddEventHandler
local SavedRegisterServerEvent = RegisterServerEvent

local Utility = {
    PlayersData = {}
}

Citizen.CreateThreadNow(function()
    while next(Utility.PlayersData) == nil do
        TriggerEvent("Utility:LoadServer", GetCurrentResourceName(), function(table) Utility = table end)
        Citizen.Wait(50)
    end
end)

--// uPlayer
    -- A cache to store the steam id of the players, can help the performance as you don't have to call every time the GetPlayerIdentifiers which is quite heavy if done every time.
    local steamCache = {}
    GetuPlayer = function(data)
        -- Steam cache check
        if steamCache[data] == nil then 
            steamCache[data] = GetPlayerIdentifiers(data)[1] 
        end

        -- This get data from the main framework and have an updater integrated (to instantly update)
        local _uplayer = nil
        _uplayer = Utility.GetuPlayer(steamCache[data], function(type, _data) 
            _uplayer[type] = _data 
        end)

        if Utility.PlayersData[steamCache[data]] then
            return _uplayer
        end
    end

    GetuSociety = function(name)
        return Utility.GetuSociety(name)
    end

    local _type = type
    type = function(var)
        if _type(var) == "table" then
            if var.__type ~= nil then
                return var.__type
            end
        else
            return _type(var)
        end
    end

--// Functions
    -- ServerCallback
        RegisterServerCallback = function(name, _function, autoprepare)
            SavedRegisterServerEvent("Utility_Callback:"..name)
            SavedAddEventHandler("Utility_Callback:"..name, function(...)
                local source = source
                source = source

                function cb(...)
                    TriggerClientEvent("Utility_Callback:"..name.."_l", source, ...)
                end

                if autoprepare then
                    uPlayer = GetuPlayer(source)
                end
                _function(...)
            end)
        end
    -- Item
        RegisterItemUsable = function(name, id, cb)

            if type(id) == "string" or type(id) == "number" then
                TriggerEvent("Utility_Usable:SetItemUsable", name, id)
                SavedRegisterServerEvent("Utility_Usable:"..name..":"..id)
                SavedAddEventHandler("Utility_Usable:"..name..":"..id, function(_uPlayer)
                    source = _uPlayer.source
                    uPlayer = _uPlayer
                    
                    if _uPlayer.HaveItemQuantity(name, id, 1) then
                        cb(true)
                    else
                        cb(false)
                    end
    
                    -- Delete the source and the uPlayer after 200ms, prevent random memory usage
                    Citizen.Wait(200)
                    source  = nil
                    uPlayer = nil
                end)
            else
                cb = id

                TriggerEvent("Utility_Usable:SetItemUsable", name)
                SavedRegisterServerEvent("Utility_Usable:"..name)
                SavedAddEventHandler("Utility_Usable:"..name, function(_uPlayer)
                    source = _uPlayer.source
                    uPlayer = _uPlayer
                    
                    if _uPlayer.HaveItemQuantity(name, 1) then
                        cb(true)
                    else
                        cb(false)
                    end
    
                    -- Delete the source and the uPlayer after 200ms, prevent random memory usage
                    Citizen.Wait(200)
                    source  = nil
                    uPlayer = nil
                end)
            end
        end
    -- Label
        GetLabel = function(header, language, key)
            if language then
                if Utility.GetConfig("Labels")[header or "framework"] and Utility.GetConfig("Labels")[header or "framework"][language or Utility.GetConfig("DefaultLanguage")] then
                    return Utility.GetConfig("Labels")[header or "framework"][language or Utility.GetConfig("DefaultLanguage")][key] or nil
                else
                    return nil, "Header or language dont exist [Header = '"..header.."' Language = '"..(language or Utility.GetConfig("DefaultLanguage")).."']"
                end
            else
                if Utility.GetConfig("Labels")[header] then
                    return Utility.GetConfig("Labels")[header][key] or nil
                else
                    return nil
                end
            end
        end
        GetJobLabel = function(job, grade)
            return GetLabel("jobs", job, tostring(grade))
        end
        GetJobLabels = function(job)
            local gradeList = {}
            for i=1, 999 do
                local label = GetLabel("jobs", job, tostring(i))

                if label == nil then
                    break
                end

                table.insert(gradeList, {label = label, grade = i})
            end
            return gradeList
        end
    -- Job
        GetPlayersWithJob = function(jobName)
            return Utility.GetPlayersWithJob(jobName)
        end

    -- Menu
        -- Probably dont works in the server
        CreateMenu = function(id, title, content, cb, close)
            TriggerClientEvent("Utility:OpenMenu", id, title, content, cb, close)
        end

--// Addons
    addon = function(name)
        local module = LoadResourceFile("utility_framework", "server/addons/"..name..".lua")
        
        if module then
            return load(module)()
        end
    end

--// TriggerBasicServerProtection
    local registered = {}
    local BlacklistedToken = {}
    local encrypting = addon("encrypting")
    
    RegisterServerEvent = function(name)
        registered[name] = true
        SavedRegisterServerEvent(name)
    end

    AddEventHandler = function(name, cb, autoprepare)
        if registered[name] then
            local encryptedName = encrypting.Utf8ToB64(name)
            Utility.LogToLogger("TBP", 'Encrypting trigger "'..name..'" => "'..encryptedName..'"')

            if Utility.GetConfig("Logs").Trigger.Registered then
                print("[^3Triggers^0] New trigger registered: ^1\""..name.."\"^0 => ^2\"Utility_External:"..encryptedName.."\"^0")
            end

            SavedRegisterServerEvent("Utility_External:"..encryptedName)
            SavedAddEventHandler("Utility_External:"..encryptedName, function(Token, Key, ...)
                if Utility.GetConfig("Logs").Trigger.Called then
                    print("[^3Triggers^0] Called trigger ^2"..name.."^0 by id:^4"..source.."^0")
                end

                local decoded = encrypting.ShaToUtf8(Token, Key)

                Utility.LogToLogger("TBP", '['..source..'] Trigger "'..tostring(name)..'" called with the token "'..tostring(Token)..'" and the key "'..tostring(Key)..'", Decrypted => "'..tostring(decoded)..'"')
                
                if not BlacklistedToken[Token] then
                    if decoded == tostring(Utility.Token) then
                        if autoprepare then
                            uPlayer = GetuPlayer(source)
                        end
                        cb(...)
                        BlacklistedToken[Token] = true
                    else
                        DropPlayer(source, "Token not valid!")
                    end
                else
                    DropPlayer(source, "Token expired "..math.random(0, 99999).."ms ago, "..name)
                end

            end)

            SavedRegisterServerEvent(name)
            SavedAddEventHandler(name, function()
                DropPlayer(source, "Called TrapTrigger, "..name)
                print("Ban, not a trigger, "..name)
            end)
        end
    end


local _print = print

print = function(...)
    local args = {...}
    
    if type(args[1]) == "table" then
        _print(json.encode(args[1]))
    else
        _print(...)
    end
end


GetSteam = function(source)
    if steamCache[source] == nil then 
        steamCache[source] = GetPlayerIdentifiers(source)[1] 
    end

    return steamCache[source]     
end