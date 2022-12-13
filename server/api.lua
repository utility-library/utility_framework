oxmysql = exports["oxmysql"]
Utility = exports["utility_framework"]
uConfig = Utility:GetConfig()
ResourceName = GetCurrentResourceName()
ServerIdentifier = nil
UFAPI = true
_TYPE = type

local SavedAddEventHandler = AddEventHandler
local SavedRegisterServerEvent = RegisterServerEvent

local UtilityData = {
    RegisteredEvents = {},
    FilteredEvents = {},
    TranslationCache = {},
    
    FilterModules = uConfig.FilterModules,

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

-- Request the identifier from the server of the Utility
    Citizen.CreateThread(function()
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
        SaveResourceFile("utility_framework", "server/addons", name..".lua", data)
    end
    CreateClientAddon = function(name, data)
        SaveResourceFile("utility_framework", "client/addons", name..".lua", data)
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
        TriggerClientCallbackAsync = function(name, id, _function, ...)
            local name = enc.Utf8ToB64(name)
            local eventHandler = nil
        
            -- Register a new event to handle the callback from the client
            SavedRegisterServerEvent("Utility:External:"..name)
            eventHandler = SavedAddEventHandler("Utility:External:"..name, function(data)
                if source == id then
                    if type(_function) == "function" then _function(table.unpack(data)) end
                    Citizen.SetTimeout(1, function()
                        RemoveEventHandler(eventHandler)
                    end)
                end
            end)
            
            TriggerClientEvent("Utility:External:"..name, id, ...) -- Trigger the client event
        end

        TriggerClientCallback = function(name, id, ...)
            local name = enc.Utf8ToB64(name)
            local eventHandler = nil
            local p = promise:new()

            -- Register a new event to handle the callback from the client
            SavedRegisterServerEvent("Utility:External:"..name)
            eventHandler = SavedAddEventHandler("Utility:External:"..name, function(data)
                if source == id then
                    p:resolve(data)
                    Citizen.SetTimeout(1, function()
                        RemoveEventHandler(eventHandler)
                    end)
                end
            end)
            
            TriggerClientEvent("Utility:External:"..name, id, ...) -- Trigger the client event

            return table.unpack(Citizen.Await(p))
        end

        RegisterServerCallback = function(name, cb, filters)
            local b64nameC = enc.Utf8ToB64(name)
            local handler = nil

            RegisterServerEvent(name)
            handler = AddEventHandler(name, function(...)
                local source = source
                uPlayer = GetPreuPlayer(source)
                
                -- For make the return of lua works
                local _cb = table.pack(cb(...))
                    
                if _cb ~= nil then -- If the callback is not nil
                    TriggerClientEvent(b64nameC, source, _cb) -- Trigger the client event
                end
            end, filters)

            return handler
        end
    -- Item
        RegisterItemUsable = function(name, cb)
            Utility:SetItemUsable(name) -- Register the item usable in the Utility
            local handler = nil

            RegisterServerEvent("Utility:Usable:"..name)
            handler = AddEventHandler("Utility:Usable:"..name, function(data)
                uPlayer = GetPlayer(source)
                
                if uPlayer.HaveItemQuantity(name, 1, data) then
                    cb(data)

                    EmitEvent("ItemUsed", uPlayer.source, name, data) -- Emit the event
                end
            end)

            return handler
        end

        ItemUsable = RegisterItemUsable -- Wrapper
    -- Label
        local defaultLanguage = Utility:GetConfig("DefaultLanguage") -- Get the language from the config (to autotranslate)

        _ = function(txt)
            for k,v in pairs(uConfig.Labels) do
                if v[txt] then
                    return v[txt]
                end
            end


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
            end, {})
        end

        CheckTableFilter = function(data, filter)
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

        local ExportWrapper = {
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

--// Events
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

    CreateFilterModule = function(name, func)
        UtilityData.FilterModules[name] = func
    end

    local FilterParamConvertVariable = function(filter, args)
        local argNumber = filter:sub(2, -1) -- escape the $

        filter = args[tonumber(argNumber)]

        return filter
    end

    local FilterParamIsAVariable = function(filter)
        return type(filter) == "string" and filter:sub(1,1) == "$"
    end

    local CheckFilterParamsVariables = function(filter, args)
        -- converts $1 with the first parameter variable
        for i=1, #filter do
            if FilterParamIsAVariable(filter[i]) then -- if the first char its $
                print("Filter "..i.." its a variable")
                filter[i] = FilterParamConvertVariable(filter[i], args) 
            end
        end

        return filter
    end

    local CheckEventFilters = function(source, filter, args)
        local retval = true
        local reason = ""

        for name, module in pairs(UtilityData.FilterModules) do
            local curFilter = filter[name]

            if filter and curFilter then
                local module_retval = nil

                if #curFilter > 0 then -- if have index as number unpack it like args
                    curFilter = CheckFilterParamsVariables(curFilter, args) -- Check and convert any variable

                    -- Execute filter module (function)
                    module_retval = module(source, table.unpack(curFilter))
                else -- otherwise send it as is
                    if FilterParamIsAVariable(curFilter) then
                        curFilter = FilterParamConvertVariable(curFilter, args) -- Check and convert if is a variable
                    end

                    module_retval = module(source, curFilter)
                end

                if module_retval ~= true then
                    return false, module_retval -- something went wrong
                end
            end
        end

        return true
    end

    RegisterServerEvent = function(name, cb, filter)
        UtilityData.RegisteredEvents[name] = true
        SavedRegisterServerEvent(name)

        if filter then
            UtilityData.FilteredEvents[name] = true
        end

        if cb then
            return AddEventHandler(name, cb, filter)
        end
    end

    -- Wrappers
    RegisterNetEvent = RegisterServerEvent
    RegisterEvent = RegisterServerEvent
    RegisterScriptEvent = function(name, cb, filter) RegisterServerEvent(GetCurrentResourceName()..":"..name, cb, filter) end

    AddEventHandler = function(name, cb, filter)
        local eventHandler = nil

        if UtilityData.RegisteredEvents[name] then
            Citizen.CreateThread(function()
                local encryptedName = enc.Utf8ToB64(name)
                local filtered = filter or UtilityData.FilteredEvents[name] or name:find("Utility:")
                
                if Utility:GetConfig("Logs").Trigger.Registered and CanLog(name) then 
                    print("[^3Triggers^0] New trigger registered: ^1\""..name.."\"^0 => ^2\"Utility:External:"..encryptedName.."\"^0") 
                end

                -- DONT REMOVE THIS, ITS FOR YOUR SECURITY
                if not filtered then
                    print("[^1Security^0] ^1The event "..name.." has no filters, may be vulnerable to cheaters, please fix it as soon as possible^0")
                end

                SavedRegisterServerEvent("Utility:External:"..encryptedName)
                eventHandler = SavedAddEventHandler("Utility:External:"..encryptedName, function(...)
                    local source = source

                    if filtered then
                        -- filter or {} - Prevent errors from the internal events (Utility:)
                        local retval, reason = CheckEventFilters(source, filter or {}, {...})

                        if retval then
                            uPlayer = GetPreuPlayer(source)
                            cb(...)
                        else
                            uConfig.FilterFail(source, name, filter or {}, reason)
                        end
                    else
                        uPlayer = GetPreuPlayer(source)
                        cb(...)    
                    end
                end)

                SavedAddEventHandler(name, function()
                    GetPlayer(source).Ban("Called TrapTrigger ["..name.."] (simply execute the trigger out of the utility environment, probably an executor or a script that dont load the utility) [Auto Ban]")
                end)
            end)
        else
            eventHandler = SavedAddEventHandler(name, function(...)
                cb(...)
            end)
        end

        return eventHandler
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