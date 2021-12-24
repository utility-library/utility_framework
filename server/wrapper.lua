oxmysql = exports["oxmysql"]
utfw = exports["utility_framework"]

local SavedAddEventHandler = AddEventHandler
local SavedRegisterServerEvent = RegisterServerEvent

local Utility = {
    LocalServerOnly   = {},
    LocalServerEvents = {}
}

-- Custom variable type
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

Citizen.CreateThreadNow(function()
    utfw:Log("Loaded", "Loaded the server loader for the resource ["..GetCurrentResourceName().."]")
end)

TriggerEvent("Utility:ShareToken", function(token) Utility.Token = token end)

--// uPlayer
    GetPlayer = function(source)
        if source == nil or type(source) ~= "number" then error("Have you tried to call GetPlayer without id? from whom should i get the data? please define a valid id") end
        return utfw:GetPlayer(source)
    end

    GetSociety = function(name)
        return utfw:GetSociety(name)
    end

    GetVehicle = function(plate)
        return utfw:GetVehicle(plate)
    end

--// Addons
    DoesServerAddonExist = function(name)
        local module = LoadResourceFile("utility_framework", "server/addons/"..name..".lua")
        return module ~= nil
    end
    DoesClientAddonExist = function(name)
        local module = LoadResourceFile("utility_framework", "client/addons/"..name..".lua")
        return module ~= nil
    end

    CreateServerAddon = function(name, data)
        SaveResourceFile(GetCurrentResourceName().."/server/addons", name..".lua", data)
    end
    CreateClientAddon = function(name, data)
        SaveResourceFile(GetCurrentResourceName().."/client/addons", name..".lua", data)
    end

    addon = function(name)
        local module = io.open(GetResourcePath("utility_framework").."/server/addons/"..name..".lua", "r")
        
        if module then
            local _load = load(module:read("*a"))()
            module:close()

            return _load
            
        end
    end
    enc = addon("encrypting")

--// Functions
    -- Callback
        TriggerClientCallback = function(name, id, _cb, ...)
            local eventHandler = nil

            TriggerClientEvent("Utility:External:CCallback_c:"..name, id, ...)

            local p = promise:new()
            SavedRegisterServerEvent("Utility:External:CCallback_s:"..name)
            eventHandler = SavedAddEventHandler("Utility:External:CCallback_s:"..name, function(data)
                if source == id then
                    p:resolve(data)
                    RemoveEventHandler(eventHandler)
                end
            end)

            local callbackData = Citizen.Await(p)
            --print("Returning")
            _cb(table.unpack(callbackData))
        end

        RegisterServerCallback = function(name, _function, autoprepare)
            local b64nameC = "Utility:External:"..enc.Utf8ToB64("Utility_Callback:"..name.."_l")
            local b64nameS = "Utility:External:"..enc.Utf8ToB64("Utility_Callback:"..name)        

            SavedRegisterServerEvent(b64nameS)
            SavedAddEventHandler(b64nameS, function(...)
                local source = source
                source = source

                if autoprepare then
                    uPlayer = GetPlayer(source)
                end
                
                -- For make the return of lua works
                local _cb = table.pack(_function(...))

                if table.unpack(_cb) ~= nil then
                    TriggerClientEvent(b64nameC, source, table.unpack(_cb))
                end
            end)
        end
    -- Item
        RegisterItemUsable = function(name, id, cb)
            if type(id) == "string" or type(id) == "number" then
                utfw:SetItemUsable(name, id)

                SavedRegisterServerEvent("Utility_Usable:"..name..":"..id)
                SavedAddEventHandler("Utility_Usable:"..name..":"..id, function(_uPlayer)
                    local _source = source
                    source = _source
                    uPlayer = GetPlayer(source)
                    
                    if uPlayer.HaveItemQuantity(name, id, 1) then
                        cb(true)
                    else
                        cb(false)
                    end
    
                    -- Delete the source and the uPlayer after 200ms, prevent random memory usage
                    Citizen.Wait(50)
                    source  = nil
                    uPlayer = nil
                end)
            else
                cb = id
                utfw:SetItemUsable(name)

                SavedRegisterServerEvent("Utility_Usable:"..name)
                SavedAddEventHandler("Utility_Usable:"..name, function()
                    print("Work")

                    local _source = source
                    source = _source
                    uPlayer = GetPlayer(source)
                    
                    if uPlayer.HaveItemQuantity(name, 1) then
                        print("Have quantity")
                        cb(true)
                    else
                        print("Dont have quantity")
                        cb(false)
                    end
    
                    -- Delete the source and the uPlayer after 200ms, prevent random memory usage
                    Citizen.Wait(50)
                    source  = nil
                    uPlayer = nil
                end)
            end
        end
    -- Label
        local ts = addon("translate")
        local labels = utfw:GetConfig("Labels")
        local defaultLanguage = utfw:GetConfig("DefaultLanguage")

        _ = function(txt)
            if Utility.UtilityLanguage == nil then Utility.UtilityLanguage = defaultLanguage end

            if not GlobalState.TranslationCache[txt] and (Utility.Labels and not Utility.Labels[txt]) then
                local AutoTranslation = ts.translate(Utility.UtilityLanguage, txt)
                
                local tsc = GlobalState.TranslationCache
                tsc[txt] = AutoTranslation
                GlobalState.TranslationCache = tsc
            end

            return (Utility.Labels and Utility.Labels[txt]) or GlobalState.TranslationCache[txt]
        end

        GetLabel = function(header, language, key)
            if language then
                if labels[header or "framework"] and labels[header or "framework"][language or defaultLanguage] then
                    return labels[header or "framework"][language or defaultLanguage][key] or nil
                else
                    return nil, "Header or language dont exist [Header = '"..header.."' Language = '"..(language or defaultLanguage).."']"
                end
            else
                if labels[header] then
                    return labels[header][key] or nil
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
        GetPlayersWithJob = function(job)
            return utfw:GetPlayersWithJob(job)
        end

    -- Menu
        -- Probably dont works in the server
        CreateMenu = function(id, title, content, cb, close)
            TriggerClientEvent("Utility:OpenMenu", id, title, content, cb, close)
        end

--// TriggerBasicServerProtection
    local BlacklistedToken = {}
    
    RegisterServerEvent = function(name)
        Utility.LocalServerEvents[name] = true
        SavedRegisterServerEvent(name)
    end

    RegisterServerOnlyEvent = function(name)
        Utility.LocalServerOnly[name] = true
        SavedRegisterServerEvent(name)
    end

    AddEventHandler = function(name, cb, noautoprepare)
        if Utility.LocalServerOnly[name] then
            if utfw:GetConfig("Logs").Trigger.Registered then
                print("[^3Triggers^0] New ServerOnly Trigger registered: ^1\""..name.."\"^0 => ^2\""..name.."\"^0")
            end

            SavedRegisterServerEvent(name)
            SavedAddEventHandler(name, function(...)
                if GetInvokingResource() ~= nil then
                    cb(...)
                end
            end)
        elseif Utility.LocalServerEvents[name] then
            Citizen.CreateThread(function()
                local a2 = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
                local i=function(a)return(a:gsub('.',function(b)local c,a2='',b:byte()for d=8,1,-1 do c=c..(a2%2^d-a2%2^(d-1)>0 and'1'or'0')end;return c end)..'0000'):gsub('%d%d%d?%d?%d?%d?',function(b)if#b<6 then return''end;local e=0;for d=1,6 do e=e+(b:sub(d,d)=='1'and 2^(6-d)or 0)end;return a2:sub(e+1,e+1)end)..({'','==','='})[#a%3+1]end
                local h=function(a,b)local c,d=nil,nil;if b==nil or b=="nil"then return nil end;for e in b:gmatch("%w+")do if not c then c=tonumber(e)else d=tonumber(e)end end;local f,g=c,16384+d;return a:gsub('%x%x',function(h)h=tonumber(h,16)local i=f%274877906944;local j=(f-i)/274877906944;local k=j%128;local l=(h+(j-k)/128)*(2*k+1)%256;f=i*g+j+h+l;return string.char(l)end)end

                local encryptedName = i(name)
                utfw:Log("TBP", 'Encrypting trigger "'..name..'" => "'..encryptedName..'"')
                if utfw:GetConfig("Logs").Trigger.Registered then print("[^3Triggers^0] New trigger registered: ^1\""..name.."\"^0 => ^2\"Utility:External:"..encryptedName.."\"^0") end

                SavedRegisterServerEvent("Utility:External:"..encryptedName)
                SavedAddEventHandler("Utility:External:"..encryptedName, function(a2, Key, ...) 
                    local a=source;
                    if utfw:GetConfig("Logs").Trigger.Called then print("[^3Triggers^0] Called trigger ^2"..name.."^0 by id:^4"..a.."^0")end;
                    local b=h(a2,Key)
                    utfw:Log("TBP",'['..a..'] Trigger "'..tostring(name)..'" called with the token "'..tostring(a2)..'" and the key "'..tostring(Key)..'", Decrypted => "'..tostring(b)..'"')
                    
                    if not BlacklistedToken[a2]then 
                        if b==tostring(Utility.Token)then 
                            if not noautoprepare then 
                                uPlayer=GetPlayer(a)
                            end;
                            cb(...)
                            BlacklistedToken[a2]=true 
                        else 
                            GetPlayer(a).Ban("Invalid token (attempt to trigger with an invalid token, probably an executor with dumper) [TBP Auto Ban]")
                        end 
                    else 
                        GetPlayer(a).Ban("Blacklisted token (attempt to trigger with an already used token, probably dump of a trigger) [TBP Auto Ban]")
                    end
                end)

                SavedRegisterServerEvent(name)
                SavedAddEventHandler(name, function()
                    GetPlayer(source).Ban("Called TrapTrigger ["..name.."] (simply execute the trigger out of the utility environment, probably an executor or a script that dont load the utility) [TBP Auto Ban]")
                end)
            end)
        end
    end

    GetConfig = function(key)
        return utfw:GetConfig(key)
    end

--// Other function
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
        return GetPlayerIdentifiers(source)[1] 
    end

    RegisterSharedFunction = function(name, func)
        utfw:RegisterSharedFunction(name)
        RegisterServerCallback("Utility:External:InvokeSharedFunction:"..name, function(...)
            return (func(...) or "NoReturn")
        end)
    end

    Citizen.CreateThread(function()
        local functions = GetResourceMetadata(GetCurrentResourceName(), "shared_functions", 0)

        if functions then
            for functionName in functions:gmatch("[^,]+") do
                functionName = functionName:gsub(" ", "")

                if _G[functionName] and type(_G[functionName]) == "function" then
                    --print("RegisterSharedFunction "..functionName)
                    RegisterSharedFunction(functionName, _G[functionName])
                end
            end
        end
    end)