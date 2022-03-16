oxmysql = exports["oxmysql"]
utfw = exports["utility_framework"]
FWConfig = utfw:GetConfig()
ResourceName = GetCurrentResourceName()

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
    utfw:Log("Loaded", "Loaded the server loader for the resource ["..ResourceName.."]")
end)

TriggerEvent("Utility:ShareToken", function(token) Utility.Token = token end)

--// uPlayer
    GetUtilityPlayers = function()
        return utfw:GetUtilityPlayers()
    end

    GetPreuPlayer = function(source)
        return setmetatable({}, {
            __index = function(_,k)
                local _uPlayer = GetPlayer(source)
                uPlayer = _uPlayer
    
                return _uPlayer[k]
            end
        })
    end

    GetPlayer = function(source)
        if source == nil or type(source) ~= "number" then error("Have you tried to call GetPlayer without id? from whom should i get the data? please define a valid id") end
        
        local uPlayer = utfw:GetPlayer(source)
        uPlayer.ped = GetPlayerPed(source)

        return setmetatable({}, {
            __index = function(_, k)
                if k == "coords" then
                    return GetEntityCoords(uPlayer.ped)
                elseif k == "heading" then
                    return GetEntityHeading(uPlayer.ped)
                else
                    return uPlayer[k]
                end
            end,
            __len = function(_) -- Plate is gettable also with #uVehicle
                return source
            end
        })
    end

    GetSociety = function(name)
        return utfw:GetSociety(name)
    end

    GetVehicle = function(plate)
        return utfw:GetVehicle(plate)
    end

--// Addons
    DoesServerAddonExist = function(name)
        local addon = LoadResourceFile("utility_framework", "server/addons/"..name..".lua")
        return addon ~= nil
    end
    DoesClientAddonExist = function(name)
        local addon = LoadResourceFile("utility_framework", "client/addons/"..name..".lua")
        return addon ~= nil
    end

    CreateServerAddon = function(name, data)
        SaveResourceFile(ResourceName.."/server/addons", name..".lua", data)
    end
    CreateClientAddon = function(name, data)
        SaveResourceFile(ResourceName.."/client/addons", name..".lua", data)
    end

    addon = function(name)
        local addon = io.open(GetResourcePath("utility_framework").."/server/addons/"..name..".lua", "r")
        
        if addon then
            --print(addon:read("*a"))
            local data = addon:read("*a")
            local _load, error = load(data)()
            addon:close()

            return _load
            
        end
    end
    local enc = addon("encrypting")

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

        RegisterServerCallback = function(name, cb)
            local b64nameC = enc.Utf8ToB64(name.."_l")
            
            RegisterServerEvent(name)
            AddEventHandler(name, function(...)
                local source = source
        
                uPlayer = GetPreuPlayer(source)
                
                -- For make the return of lua works
                local _cb = table.pack(cb(...))
        
                uPlayer = nil
            
                if _cb ~= nil then
                    TriggerClientEvent(b64nameC, source, _cb)
                end
            end)
        end
    -- Item
        RegisterItemUsable = function(name, cb)
            utfw:SetItemUsable(name)

            SavedRegisterServerEvent("Utility_Usable:"..name)
            SavedAddEventHandler("Utility_Usable:"..name, function()
                local _source = source
                source = _source
                uPlayer = GetPlayer(source)
                
                if uPlayer.HaveItemQuantity(name, 1) then
                    --print("Have quantity")
                    cb(true)
                    TriggerClientEvent("Utility:Emitter:ItemUsed", _source, name)
                else
                    --print("Dont have quantity")
                    cb(false)
                end

                source  = nil
                uPlayer = nil
            end)
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
    -- Job
        GetJob = function(job)
            return {
                label = Config.Jobs.Configuration[job].name,
                grades = Config.Jobs.Configuration[job].grades,
                worker = utfw:GetPlayersWithJob(job)
            }
        end

        GetJobGrade = function(job, grade)
            return GetJob(job).grades[grade]
        end

        GetJobGrades = function(job)
            return GetJob(job).grades
        end

    -- Menu
        -- Probably dont works in the server
        CreateMenu = function(id, title, content, cb, close)
            TriggerClientEvent("Utility:OpenMenu", id, title, content, cb, close)
        end

--// TriggerBasicServerProtection
    local BlacklistedToken = {}
    local NoLog = {
        "SharedFunction"
    }

    local function CanLog(name)
        for i=1, #NoLog do
            if name:find(NoLog[i]) then
                return false
            end
        end

        return true
    end

    RegisterServerEvent = function(name, cb)
        Utility.LocalServerEvents[name] = true
        SavedRegisterServerEvent(name)

        if cb then
            AddEventHandler(name, cb)
        end
    end
    RegisterNetEvent = function(name, cb)
        Utility.LocalServerEvents[name] = true
        SavedRegisterServerEvent(name)

        if cb then
            AddEventHandler(name, cb)
        end
    end

    RegisterServerOnlyEvent = function(name, cb)
        Utility.LocalServerOnly[name] = true
        SavedRegisterServerEvent(name)

        if cb then
            AddEventHandler(name, cb)
        end
    end

    AddEventHandler = function(name, cb)
        local eventHandler = nil

        if Utility.LocalServerOnly[name] then
            if utfw:GetConfig("Logs").Trigger.Registered then
                print("[^3Triggers^0] New ServerOnly Trigger registered: ^1\""..name.."\"^0 => ^2\""..name.."\"^0")
            end

            SavedRegisterServerEvent(name)
            eventHandler = SavedAddEventHandler(name, function(...)
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
                if utfw:GetConfig("Logs").Trigger.Registered and CanLog(name) then 
                    print("[^3Triggers^0] New trigger registered: ^1\""..name.."\"^0 => ^2\"Utility:External:"..encryptedName.."\"^0") 
                end

                SavedRegisterServerEvent("Utility:External:"..encryptedName)
                eventHandler = SavedAddEventHandler("Utility:External:"..encryptedName, function(a2, Key, ...) 
                    local a=source;
                    local b=h(a2,Key)

                    utfw:Log("TBP",'['..a..'] Trigger "'..tostring(name)..'" called with the token "'..tostring(a2)..'" and the key "'..tostring(Key)..'", Decrypted => "'..tostring(b)..'"')
                    if utfw:GetConfig("Logs").Trigger.Called and CanLog(name) then 
                        print("[^3Triggers^0] Called trigger ^2"..name.."^0 by id:^4"..a.."^0")
                    end;
                    
                    if not BlacklistedToken[a2]then 
                        if b==tostring(Utility.Token)then 
                            uPlayer = GetPreuPlayer(source)
                            cb(...)
                            BlacklistedToken[a2]=true 
                        else 
                            print("Invalid token (attempt to trigger with an invalid token, probably an executor with dumper) [TBP Auto Ban]")
                            GetPlayer(a).Ban("Invalid token (attempt to trigger with an invalid token, probably an executor with dumper) [TBP Auto Ban]")
                        end 
                    else 
                        print("Blacklisted token (attempt to trigger with an already used token, probably dump of a trigger) [TBP Auto Ban]")
                        GetPlayer(a).Ban("Blacklisted token (attempt to trigger with an already used token, probably dump of a trigger) [TBP Auto Ban]")
                    end
                end)

                SavedRegisterServerEvent(name)
                SavedAddEventHandler(name, function()
                    print("Called TrapTrigger ["..name.."] (simply execute the trigger out of the utility environment, probably an executor or a script that dont load the utility) [TBP Auto Ban]")
                    GetPlayer(source).Ban("Called TrapTrigger ["..name.."] (simply execute the trigger out of the utility environment, probably an executor or a script that dont load the utility) [TBP Auto Ban]")
                end)
            end)

            return eventHandler
        else
            SavedAddEventHandler(name, cb)
        end
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

    LoadJson = function(name)
        local file = LoadResourceFile(GetCurrentResourceName(), name)
    
        if file then
            return json.decode(file)
        end
    end
    
    SaveJson = function(name, data, indent)
        local file = json.encode(data, {indent = indent})
    
        SaveResourceFile(GetCurrentResourceName(), name, file, -1)
    end

    GetSteam = function(source)
        return GetPlayerIdentifiers(source)[1] 
    end

    RegisterSharedFunction = function(name, func)
        name = ResourceName..":"..name

        utfw:RegisterSharedFunction(name)

        RegisterServerCallback("SharedFunction:"..name, function(...)
            return (func(...) or "NoReturn")
        end)
    end

    Citizen.CreateThread(function()
        local functions = GetResourceMetadata(ResourceName, "shared_functions", 0)

        if functions then
            for functionName in functions:gmatch("[^,]+") do
                functionName = functionName:gsub(" ", "")

                if _G[functionName] and type(_G[functionName]) == "function" then
                    RegisterSharedFunction(functionName, _G[functionName])
                end
            end
        end



        local __resource = LoadResourceFile(ResourceName, "__resource.lua")

        if __resource then
            if FWConfig.AutoUpdateFXVersion then
                __resource = __resource:gsub("resource_manifest_version [%w%p%d]+", "")
                __resource = 'fx_version "cerulean"\ngame "gta5"\n'..__resource
                
                SaveResourceFile(ResourceName, "__resource.lua", __resource)
                os.rename(GetResourcePath(ResourceName).."/__resource.lua", GetResourcePath(ResourceName).."/fxmanifest.lua")
                print("The framework have updated the resource manifest of ^3"..ResourceName.."^0 to ^4fxmanifest.lua^0")
            else
                print("^3"..ResourceName.."^0 use a ^1deprectated fxversion^0, set ^4Config.AutoUpdateFXVersion^0 to make the framework convert it automatically")
            end

        end
    end)