oxmysql = exports["oxmysql"]
Utility = exports["utility_framework"]
uConfig = Utility:GetConfig()
ResourceName = GetCurrentResourceName()
ServerIdentifier = nil
_TYPE = type

local msgpack_unpack = msgpack.unpack
local SavedAddEventHandler = AddEventHandler
local SavedRegisterServerEvent = RegisterServerEvent

local UtilityData = {
    LocalUnsecureEvents = {},
    LocalServerOnly   = {},
    LocalSecuredEvents = {},
    TranslationCache = {},
    Hooks = {
        uPlayer = {},
        uSociety = {},
        uVehicle = {}
    },
}

-- Custom type checking (for custom Utility objects)
    function type(obj)	
        if _TYPE(obj) == 'table' and obj.__type then
            return obj.__type
        else
            return _TYPE(obj)
        end
    end

-- Log the loading of the API
    Citizen.CreateThreadNow(function()
        Utility:Log("Loaded", "Loaded the server API for the resource ["..ResourceName.."]")
    end)

-- Request the token from the server of the Utility
    Citizen.CreateThread(function()
        UtilityData.PvKey, UtilityData.Token = exports["utility_framework"]:GetServerToken()
        ServerIdentifier = exports["utility_framework"]:GetServerIdentifier()
    end)

--// uEntities
    GetUtilityPlayers = function()
        return Utility:GetUtilityPlayers()
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
        
        local uPlayer = Utility:GetPlayer(source)
        uPlayer.ped = GetPlayerPed(source)

        return setmetatable({}, {
            __index = function(_, k)
                if k == "coords" then
                    return GetEntityCoords(uPlayer.ped)
                elseif k == "heading" then
                    return GetEntityHeading(uPlayer.ped)
                elseif k == "client" then
                    return uPlayer:Client()
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
        return Utility:GetSociety(name)
    end

    GetVehicle = function(plate)
        return Utility:GetVehicle(plate)
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
            local data = addon:read("*a")
            local _load, error = load(data)()
            addon:close()

            return _load
            
        end
    end

    local enc = addon("encrypting")
    local ts = addon("translate")

--// Functions
    -- Callback
        TriggerClientCallback = function(name, id, _cb, ...)
            local name = enc.Utf8ToB64(name) -- Use the same format of secured events
            local eventHandler = nil
            local p = promise:new()

            TriggerClientEvent("Utility:External:"..name, id, ...) -- Trigger the client event

            -- Wait for the client to produce an output and that the event is triggered
            SavedRegisterServerEvent("Utility:External:"..name)
            eventHandler = SavedAddEventHandler("Utility:External:"..name, function(data)
                if source == id then -- If the source is the same as the selected id (check for fake calls)
                    p:resolve(data)
                    RemoveEventHandler(eventHandler)
                end
            end)

            local callbackData = Citizen.Await(p)
            _cb(table.unpack(callbackData)) -- Unpack the data and call the callback
        end

        RegisterServerCallback = function(name, cb)
            local b64nameC = enc.Utf8ToB64(name)
            
            RegisterServerEvent(name)
            AddEventHandler(name, function(...)
                local source = source
                uPlayer = GetPreuPlayer(source)
                
                -- For make the return of lua works
                local _cb = table.pack(cb(...))
                    
                if _cb ~= nil then -- If the callback is not nil
                    TriggerClientEvent(b64nameC, source, _cb) -- Trigger the client event
                end
            end)
        end
    -- Item
        RegisterItemUsable = function(name, cb)
            Utility:SetItemUsable(name) -- Register the item usable in the Utility

            -- Create a non secured event for the item (no needed secured why it check the quantity)
            SavedRegisterServerEvent("Utility_Usable:"..name)
            SavedAddEventHandler("Utility_Usable:"..name, function(data)
                uPlayer = GetPlayer(source)
                
                if uPlayer.HaveItemQuantity(name, 1, data) then
                    cb(data)

                    EmitEvent("ItemUsed", uPlayer.source, name, data) -- Emit the event
                end
            end)
        end

        ItemUsable = RegisterItemUsable -- Wrapper
    -- Label
        local defaultLanguage = Utility:GetConfig("DefaultLanguage") -- Get the language from the config (to autotranslate)

        _ = function(txt)
            -- If the UtilityLanguage isnt setted by the script use the language from the config
            if UtilityData.UtilityLanguage == nil then UtilityData.UtilityLanguage = defaultLanguage end

            -- If the translation isnt already translated and isnt setted by the script, then translate it
            if not UtilityData.TranslationCache[txt] and (UtilityData.Labels and not UtilityData.Labels[txt]) then
                local AutoTranslation = ts.translate(UtilityData.UtilityLanguage, txt) -- Translate the text (Google Translate)

                UtilityData.TranslationCache[txt] = AutoTranslation
            end

            -- First check if is translated by the script, and after check in the translation cache
            return (UtilityData.Labels and UtilityData.Labels[txt]) or UtilityData.TranslationCache[txt]
        end
    -- Job
        -- Get the job information
        GetJob = function(job)
            return {
                label = uConfig.Jobs.Configuration[job].name,
                grades = uConfig.Jobs.Configuration[job].grades,
                workers = Utility:GetPlayersWithJob(job)
            }
        end

    -- Menu
        -- Probably dont works in the server
        CreateMenu = function(id, title, content, cb, close)
            TriggerClientEvent("Utility:OpenMenu", id, title, content, cb, close)
        end
    -- Other
        local _RegisterCommand = RegisterCommand
        RegisterCommand = function(name, func)
            _RegisterCommand(name, function(source, ...)
                uPlayer = GetPreuPlayer(source)
                func(source, ...)
            end)
        end

        -- JSON Integration
        LoadJson = function(name)
            local file = LoadResourceFile(ResourceName, name)
        
            if file then
                return json.decode(file)
            end
        end
        
        SaveJson = function(name, data, indent)
            local file = json.encode(data, {indent = indent})
        
            SaveResourceFile(ResourceName, name, file, -1)
        end

        -- Special functions
        RegisterSharedFunction = function(name, func)
            name = ResourceName..":"..name

            Utility:RegisterSharedFunction(name)

            RegisterServerCallback("SharedFunction:"..name, function(...)
                return (func(...) or "NoReturn")
            end)
        end

        CheckFilter = function(data, filter)
            local filterkeys = 0
            local foundkeys = 0
            
            for k,v in pairs(filter) do
                filterkeys = filterkeys + 1
                
                if data[k] == v then
                    foundkeys = foundkeys + 1
                end
            end
            
            if filterkeys == foundkeys then
                return true
            else
                return false
            end
        end

        ExportWrapper = {
            "DoesStashExist",
            "CreateStash",
            "GetStash",
            "DeleteStash"
        }

        for i=1, #ExportWrapper do
            _G[ExportWrapper[i]] = function(...)
                return Utility[ExportWrapper[i]](nil, ...)
            end
        end

        EmitEvent = function(name, ...)
            TriggerClientEvent("Utility:Emitter:"..name, source, ...)
            TriggerEvent("Utility:Emitter:"..name, source, ...)
        end

--// TriggerBasicServerProtection
    local BlacklistedEncrypted = {}
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

    RegisterSecureEvent = function(name, cb)
        UtilityData.LocalSecuredEvents[name] = true

        -- insert in SecuredEvents table the event name (if a cheater remove one of them in the client side it simply not provide a token, so it will banned)
        local se = GlobalState.SecuredEvents
        table.insert(se, name)
        GlobalState.SecuredEvents = se

        RegisterServerEvent(name, cb)
    end

    RegisterServerEvent = function(name, cb)
        --print("Registered unsecure event "..name)
        SavedRegisterServerEvent(name)

        if cb then
            SavedAddEventHandler(name, cb)
        end
    end

    -- Wrappers
    RegisterNetEvent = RegisterServerEvent
    RegisterEvent = RegisterServerEvent
    RegisterScriptEvent = function(name, cb) RegisterServerEvent(GetCurrentResourceName()..":"..name, cb) end

    RegisterServerOnlyEvent = function(name, cb)
        UtilityData.LocalServerOnly[name] = true
        SavedRegisterServerEvent(name)

        if cb then
            AddEventHandler(name, cb)
        end
    end

    AddEventHandler = function(name, cb)
        local eventHandler = nil

        if UtilityData.LocalServerOnly[name] then
            if Utility:GetConfig("Logs").Trigger.Registered then
                print("[^3Triggers^0] New ServerOnly Trigger registered: ^1\""..name.."\"^0 => ^2\""..name.."\"^0")
            end

            SavedRegisterServerEvent(name)
            eventHandler = SavedAddEventHandler(name, function(...)
                if GetInvokingResource() ~= nil then
                    cb(...)
                end
            end)
        elseif UtilityData.LocalSecuredEvents[name] then
            Citizen.CreateThread(function()
                local a2 = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
                local i=function(a)return(a:gsub('.',function(b)local c,a2='',b:byte()for d=8,1,-1 do c=c..(a2%2^d-a2%2^(d-1)>0 and'1'or'0')end;return c end)..'0000'):gsub('%d%d%d?%d?%d?%d?',function(b)if#b<6 then return''end;local e=0;for d=1,6 do e=e+(b:sub(d,d)=='1'and 2^(6-d)or 0)end;return a2:sub(e+1,e+1)end)..({'','==','='})[#a%3+1]end

                local encryptedName = i(name)

                Utility:Log("TBP", 'Encrypting trigger "'..name..'" => "'..encryptedName..'"')
                if Utility:GetConfig("Logs").Trigger.Registered and CanLog(name) then 
                    print("[^3Triggers^0] New trigger registered: ^1\""..name.."\"^0 => ^2\"Utility:External:"..encryptedName.."\"^0") 
                end

                SavedRegisterServerEvent("Utility:External:"..encryptedName)
                eventHandler = SavedAddEventHandler("Utility:External:"..encryptedName, function(encrypted, ...) 
                    local _source = tonumber(source);

                    if _source and _source > 0 then
                        if not BlacklistedEncrypted[encrypted] then 
                            local p = promise:new()
                            local encrypted = msgpack_unpack(encrypted)

                            exports["utility_framework"]:Decrypt(UtilityData.PvKey, encrypted, function(decrypted) p:resolve(decrypted) end)
                            local decrypted = Citizen.Await(p)

                            Utility:Log("TBP",'['.._source..'] Trigger "'..tostring(name)..'" called with the token "'..tostring(encrypted)..'", Decrypted => "'..tostring(decrypted)..'"')
                            
                            if Utility:GetConfig("Logs").Trigger.Called and CanLog(name) then 
                                print("[^3Triggers^0] Called trigger ^2"..name.."^0 by id:^4".._source.."^0")
                            end

                            collectgarbage("collect")

                            if decrypted == tostring(UtilityData.Token) then 
                                BlacklistedEncrypted[encrypted]=true 

                                uPlayer = GetPreuPlayer(source)
                                cb(...)
                            else 
                                --print("Invalid token (attempt to trigger with an invalid token, probably an executor with dumper) [TBP Auto Ban]")
                                GetPlayer(_source).Ban("Invalid token (attempt to trigger with an invalid token, probably an executor with dumper) [TBP Auto Ban]")
                            end 
                        else 
                            --print("Blacklisted token (attempt to trigger with an already used token, probably dump of a trigger) [TBP Auto Ban]")
                            GetPlayer(_source).Ban("Blacklisted token (attempt to trigger with an already used token, probably dump of a trigger) [TBP Auto Ban]")
                        end
                    elseif _source == 0 then
                        cb(...)
                    end
                end)

                SavedRegisterServerEvent(name)
                SavedAddEventHandler(name, function()
                    --print("Called TrapTrigger ["..name.."] (simply execute the trigger out of the utility environment, probably an executor or a script that dont load the utility) [TBP Auto Ban]")
                    GetPlayer(source).Ban("Called TrapTrigger ["..name.."] (simply execute the trigger out of the utility environment, probably an executor or a script that dont load the utility) [TBP Auto Ban]")
                end)
            end)

            return eventHandler
        else
            SavedAddEventHandler(name, cb)
        end
    end

    local _TriggerEvent = TriggerEvent
    TriggerEvent = function(name, ...)
        if name:find("__cfx") then -- exports and other cfx stuff
            _TriggerEvent(name, ...)
        else
            local a2 = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
            local i=function(a)return(a:gsub('.',function(b)local c,a2='',b:byte()for d=8,1,-1 do c=c..(a2%2^d-a2%2^(d-1)>0 and'1'or'0')end;return c end)..'0000'):gsub('%d%d%d?%d?%d?%d?',function(b)if#b<6 then return''end;local e=0;for d=1,6 do e=e+(b:sub(d,d)=='1'and 2^(6-d)or 0)end;return a2:sub(e+1,e+1)end)..({'','==','='})[#a%3+1]end
            local h=function(a,b)local c,d=nil,nil;if b==nil or b=="nil"then return nil end;for e in b:gmatch("%w+")do if not c then c=tonumber(e)else d=tonumber(e)end end;local f,g=c,16384+d;return a:gsub('%x%x',function(h)h=tonumber(h,16)local i=f%274877906944;local j=(f-i)/274877906944;local k=j%128;local l=(h+(j-k)/128)*(2*k+1)%256;f=i*g+j+h+l;return string.char(l)end)end
            local encryptedName = i(name)
    
            _TriggerEvent("Utility:External:"..encryptedName, nil, nil, ...)
        end
    end

--// Hooks
    -- Unhook on script stop
    AddEventHandler("onResourceStop", function(res)
        if res == ResourceName then
            for k,v in pairs(UtilityData.Hooks) do
                for i=1, #v do
                    exports["utility_framework"]:Unhook(k, UtilityData.Hooks[k][i])
                end
            end
        end
    end)


    uPlayerHook = setmetatable({}, {
        __newindex = function(self, k, v)
            if type(v) == "function" then
                if not UtilityData.Hooks.uPlayer then UtilityData.Hooks.uPlayer = {} end

                table.insert(UtilityData.Hooks.uPlayer, k)
                exports["utility_framework"]:Hook("uPlayer", k, v)
            end
        end
    })
    uSocietyHook = setmetatable({}, {
        __newindex = function(self, k, v)
            if type(v) == "function" then
                if not UtilityData.Hooks.uSociety then UtilityData.Hooks.uSociety = {} end

                table.insert(UtilityData.Hooks.uSociety, k)
                exports["utility_framework"]:Hook("uSociety", k, v)
            end
        end
    })
    uVehicleHook = setmetatable({}, {
        __newindex = function(self, k, v)
            if type(v) == "function" then
                if not UtilityData.Hooks.uVehicle then UtilityData.Hooks.uVehicle = {} end

                table.insert(UtilityData.Hooks.uVehicle, k)
                exports["utility_framework"]:Hook("uVehicle", k, v)
            end
        end
    })

--// Other
    Citizen.CreateThread(function()
        -- Shared function binded from the manifest
        local functions = GetResourceMetadata(ResourceName, "shared_functions", 0)

        if functions then
            for functionName in functions:gmatch("[^,]+") do
                functionName = functionName:gsub(" ", "")

                if _G[functionName] and type(_G[functionName]) == "function" then
                    RegisterSharedFunction(functionName, _G[functionName])
                end
            end
        end


        -- FX Version auto converter
        local __resource = LoadResourceFile(ResourceName, "__resource.lua")

        if __resource then
            if uConfig.AutoUpdateFXVersion then
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

    NewCustomStateBag = function(identifier, r)
        if identifier and exports["utility_framework"]:DoesStateBagExist(identifier) then
            return setmetatable({}, {
                __index = function(_, s)
                    if s == 'set' then
                        return function(_, s, v, r)
                            exports["utility_framework"]:SetStateBagValue(identifier, s, v, r)
                        end
                    end
                
                    return exports["utility_framework"]:GetStateBagValue(identifier, s)
                end,
                
                __newindex = function(_, s, v)
                    exports["utility_framework"]:SetStateBagValue(identifier, s, v, r)
                end
            })
        end
    end