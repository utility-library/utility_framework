--// Variables
local id = GetPlayerServerId(PlayerId())

local Keys = {
    Public = nil,
    Private = nil,
    Token = nil
}

local privateKey, publicKey = nil, nil
local utilityDataHandle = ""

local msgpack_pack = msgpack.pack
local SavedTriggerServerEvent = TriggerServerEvent

Utility = exports["utility_framework"]
Loaded = false
oxmysql = exports["oxmysql"]
ResourceName = GetCurrentResourceName()
ServerIdentifier = nil

--// InternalFunctions
function uPlayerPopulate()
    uPlayer = setmetatable({}, {
        __index = function(_, k)
            --print(k, LocalPlayer.state[k])
            if k == "vehicle" or k == "veh" then
                return GetVehiclePedIsIn(uPlayer.ped)
            elseif k == "coords" then
                if GetCurrentResourceName() == "utility_framework" then
                    return LocalPlayer.state.coords
                else
                    return GetEntityCoords(uPlayer.ped)
                end
            elseif k == "heading" then
                return GetEntityHeading(uPlayer.ped)
            elseif k == "weapon" then
                return GetSelectedPedWeapon(uPlayer.ped)
            elseif k == "armed" then
                return IsPedArmed(uPlayer.ped, 4)
            elseif k == "weaponModel" then
                return GetCurrentPedWeaponEntityIndex(uPlayer.ped)
            elseif k == "id" then
                return id
            elseif k == "ped" then
                if DoesEntityExist(LocalPlayer.state[k]) then
                    return LocalPlayer.state[k]
                else
                    local ped = PlayerPedId()
                    LocalPlayer.state[k] = ped
                    
                    return ped
                end
            elseif type(LocalPlayer.state[k]) == "string" and LocalPlayer.state[k]:find("call") then
                return function(...)
                    local v = LocalPlayer.state[k]
                    v = v:gsub("call:", "")
                    
                    local resource, name = v:match("(.+):(.+)")

                    return exports[resource][name](nil, ...)
                end
            else
                return LocalPlayer.state[k]
            end
        end,
        __newindex = function(_, k, v)
            if type(v) == "function" then
                exports(k, v) -- Create the exports
                LocalPlayer.state[k] = "call:"..ResourceName..":"..k

                --print("State = "..LocalPlayer.state[k])
                -- Assign to the state "call:resource_name:function_name"
            else
                LocalPlayer.state[k] = v
            end
        end,
        __len = function(_) -- Id is gettable also with #uPlayer
            return id
        end
    })

    -- Assigning functions to the uPlayer
        -- Money
            GetMoney = function(type)
                return exports["utility_framework"]:GetMoney(type)
            end

            HaveMoneyQuantity = function(type, quantity)
                return exports["utility_framework"]:HaveMoneyQuantity(type, quantity)
            end
        -- Item
            GetItem = function(name, itemid)
                return exports["utility_framework"]:GetItem(name, itemid)
            end
            IsItemUsable = function(name, id)
                return exports["utility_framework"]:IsItemUsable(name, id)
            end

            UseItem = function(name, id)
                exports["utility_framework"]:UseItem(name, id)
            end
            
            HaveItemQuantity = function(name, quantity)
                return exports["utility_framework"]:HaveItemQuantity(name, quantity)
            end
            CanCarryItem = function(name, quantity)
                return exports["utility_framework"]:CanCarryItem(name, quantity)
            end
        -- Weapon
            AddWeapon = function(weapon, ammo, equipNow)
                exports["utility_framework"]:AddWeapon(weapon, ammo, equipNow)
            end

            RemoveWeapon = function(weapon)
                exports["utility_framework"]:RemoveWeapon(weapon)
            end

            GetWeapons = function()
                return exports["utility_framework"]:GetWeapons()
            end

            GetWeaponLabel = function(name)
                return uConfig.Labels["weapons"][name] or name
            end

            HaveWeapon = function(name)
                return exports["utility_framework"]:HaveWeapon(name)
            end
        -- License
            GetLicenses = function()      
                return exports["utility_framework"]:GetLicenses()
            end

            HaveLicense = function(name)
                return exports["utility_framework"]:HaveLicense(name)
            end
        -- Identity
            GetIdentity = function(data)
                return exports["utility_framework"]:GetIdentity(data)
            end
        -- Billing
            GetBills = function()
                return exports["utility_framework"]:GetBills()
            end

        -- IsDead
            IsDead = function()
                return exports["utility_framework"]:IsDead()
            end

        -- Other info integration
            Get = function(id)
                return exports["utility_framework"]:Get(id)
            end
        
        -- Societies 
            GetSocietyVehicles = function(society)
                
            end

        -- Vehicle
            SpawnOwnedVehicle = function(plate, coords, network)
                local veh = exports["utility_framework"]:GetVehicle(plate)

                RequestModel(veh.data.model)
                
                while not HasModelLoaded(veh.data.model) do
                    Citizen.Wait(1)
                end

                local veh = CreateVehicle(veh.data.model, coords, 0.0, network)
                SetVehicleComponents(veh, veh.data)
                return veh, true
            end

        -- Config
            FrameworkConfig = function(field)
                return exports["utility_framework"]:Config(field)
            end

    while not LocalPlayer.state.loaded do
        --print(LocalPlayer.state.vehicles)
        Citizen.Wait(1)
    end
end

function uVehiclePopulate()
    GetVehicle = function(plate)
        local uVehicle = exports["utility_framework"]:GetVehicle(plate)

        return setmetatable({}, {
            __index = function(_, k)
                if k == "coords" then
                    return GetEntityCoords(uPlayer.entity)
                elseif k == "heading" then
                    return GetEntityHeading(uPlayer.entity)
                else
                    return uVehicle[k]
                end
            end,
            __newindex = function(_, k, v)
                uVehicle[k] = v
            end,
            __len = function(_) -- Plate is gettable also with #uVehicle
                return plate
            end
        })
    end
end

Citizen.CreateThread(function()
    if Main then
        Main()
    end
end)

Citizen.CreateThread(function()
    while GetResourceState("utility_framework") ~= "started" do Citizen.Wait(50) end
    Keys.Public, Keys.Private = exports["utility_framework"]:GenerateKeys()

    local func = exports["utility_framework"]:UtilityOnTop(Keys.Public)

    -- When you join the utility_framework dont load up instantly, so retry until func is defined
    while not func do 
        func = exports["utility_framework"]:UtilityOnTop(Keys.Public) 
        Citizen.Wait(50) 
    end

    local encrypted = func()

    print("[^2API^0] ^3Recieved encrypted token from tbp client^0")
    Keys.Token = exports["utility_framework"]:Decrypt(Keys.Private, encrypted)
    print("[^2API^0] ^3Decrypted token: "..Keys.Token.."^0")

    collectgarbage("collect") -- Collect garbage to free memory from the decryption and the keys generation
end)

Citizen.CreateThread(function()
    while GetResourceState("utility_framework") ~= "started" do -- wait the framework
        Citizen.Wait(1)
    end

    ServerIdentifier = exports["utility_framework"]:GetServerIdentifier()
    uPlayerPopulate() -- Populating uPlayer
    uVehiclePopulate() -- Populating uVehicles
    
    GetStash = function(identifier, replicate) -- wrapper
        return exports["utility_framework"]:GetStash(identifier, replicate) 
    end

    while Keys.Token == nil do
        Citizen.Wait(1)
    end
    Citizen.Wait(5)

    Loaded = true
    if Load then
        Load()
    end
end)

--// Callback
RegisterClientCallback = function(name, _function)
    local name = enc.Utf8ToB64(name) -- Use the same format of secured events (mask the event)

    RegisterNetEvent("Utility:External:"..name)
    AddEventHandler("Utility:External:"..name, function(...)
        local source = source
        source = source
        
        -- For make the return of lua works
        local _cb = table.pack(_function(...))

        if table.unpack(_cb) ~= nil then
            SavedTriggerServerEvent("Utility:External:"..name, _cb)
        end
    end)
end

TriggerServerCallbackAsync = function(name, _function, ...)
    local eventHandler = nil
    local b64nameC = enc.Utf8ToB64(name) -- Prevent noobies to know if a event is a callback or not (mask the event)

    -- Register a new event to handle the callback from the server
    RegisterNetEvent(b64nameC)
    eventHandler = AddEventHandler(b64nameC, function(data)
        if type(_function) == "function" then _function(table.unpack(data)) end
        RemoveEventHandler(eventHandler)
    end)
    
    TriggerServerEvent(name, ...) -- Trigger the server event to get the data
end

TriggerServerCallback = function(name, ...)
    local p = promise.new()        
    local eventHandler = nil
    local b64nameC = enc.Utf8ToB64(name) -- Prevent noobies to know if a event is a callback or not (mask the event)

    -- Register a new event to handle the callback from the server
    RegisterNetEvent(b64nameC)
    eventHandler = AddEventHandler(b64nameC, function(data)
        RemoveEventHandler(eventHandler)
        p:resolve(data)
    end)

    TriggerServerEvent(name, ...) -- Trigger the server event to get the data
    return table.unpack(Citizen.Await(p))
end

--// Internal Emitter
local EmitterEvents = {
    "EnterVehicle",
    "ExitVehicle",
    "ItemUsed",
    
    "OnRevive",
    
    "MoneyAdded",
    "MoneySetted",
    "MoneyRemoved",
    
    "ItemAdded",
    "ItemRemoved",
    "MaxWeightSetted",
    
    "JobChange",
    "GradeChange",
    "OnDuty",
    
    "IdentitySetted",

    "WeaponAdded",
    "WeaponRemoved",

    "WeaponAmmoAdded",
    "WeaponAmmoRemoved",
    
    "WeaponDisassembled",
    "WeaponAssembled",

    "LicenseAdded",
    "LicenseRemoved",

    "BillPaid",
    "BillRevoked",

    "VehicleBought",
    "VehicleTransferedToPlayer",

    "StashItemAdded",
    "StashItemRemoved",
    "StashItemInserted",
    "StashItemTaken",

    "StashMaxWeightSetted",
    
    "StashWeaponAdded",
    "StashWeaponRemoved",
    
    "StashMoneyAdded",
    "StashMoneyRemoved",
    "StashMoneySetted",
}

function LoadShared(index)
    --print("Loaded shared function: " .. GlobalState.SharedFunction[i])
    local formattedName = GlobalState.SharedFunction[index]:gsub(ResourceName..":", "")

    load(formattedName..[[ = function(...)
            --print("SharedFunction:]]..GlobalState.SharedFunction[index]..[[",...)

            -- Dont know if it works
            local thread, main = coroutine.running()

            if main then
                print("^1@utility_framework: Tried to call the shared function \"]]..formattedName..[[\" but shared functions can't be called from main thread, create a new thread with Citizen.CreateThread^0")
            else
                return TriggerServerCallback("SharedFunction:]]..GlobalState.SharedFunction[index]..[[", ...)
            end
        end
    ]])()
end

Citizen.CreateThreadNow(function()
    uConfig = exports["utility_framework"]:Config()

    -- SharedFunctions
    for i=1, #GlobalState.SharedFunction do        
        if not uConfig.GlobalSharedFunction then
            if GlobalState.SharedFunction[i]:find(ResourceName) then
                LoadShared(i)
            end
        else
            LoadShared(i)
        end
    end

    -- Emitters
    for k,v in pairs(uConfig.CustomEmitter) do
        if _G[v] then
            RegisterNetEvent("Utility:Emitter:"..v)
            AddEventHandler("Utility:Emitter:"..v, function(...)
                --[[print("Emitting "..v)

                for k,v in pairs(debug.getinfo(_G[v])) do
                    print(k,v)
                end]]
                _G[v](...)
            end)
        end
    end

    for i=1, #EmitterEvents do
        if _G[EmitterEvents[i]] then
            RegisterNetEvent("Utility:Emitter:"..EmitterEvents[i])
            AddEventHandler("Utility:Emitter:"..EmitterEvents[i], function(...)
                _G[EmitterEvents[i]](...)
            end)
        end
    end
end)

--// Functions
--// Label
    -- Job
        GetJob = function(job, workers)
            if uConfig.Jobs.Configuration[job] then
                return {
                    label = uConfig.Jobs.Configuration[job].name,
                    grades = uConfig.Jobs.Configuration[job].grades,
                    workers = TriggerServerCallback("Utility:GetWorker", job)
                }
            else
                return {
                    label = "Dont Exist",
                    grades = {},
                    workers = 0,
                    error = true
                }
            end
        end

        GetJobWorkers = function(job)
            --print(job)
            return TriggerServerCallback("Utility:GetWorker", job)
        end

        GetJobLabel = function(job)
            return uConfig.Jobs.Configuration[job].name
        end

        GetJobGrades = function(job)
            return uConfig.Jobs.Configuration[job].grades
        end

        GetJobGrade = function(job, grade)
            return uConfig.Jobs.Configuration[job].grades[grade]
        end

--// Menu
    CreateMenu = function(title, content, callback, closecb) 
        TriggerEvent("Utility:OpenMenu", title, content, callback, closecb)
    end

    CloseAllMenu = function()
        TriggerEvent("Utility:Close")
    end

--// Vehicle
    GetVehicleComponents = function(vehicleHandle)
        local colorPrimary, colorSecondary = GetVehicleColours(vehicleHandle)
        local pearlescentColor, wheelColor = GetVehicleExtraColours(vehicleHandle)
        local extras = {}
        local mods = {}

        -- Extra
        for i=0, 12 do
            if DoesExtraExist(vehicleHandle, i) then
                local active = IsVehicleExtraTurnedOn(vehicleHandle, i) == 1

                if active then
                    table.insert(extras, tonumber(i))
                end
            end
        end

        -- Mods
        for i=0, 49 do
            table.insert(mods, GetVehicleMod(vehicleHandle, i))
        end

        mods[19] = IsToggleModOn(vehicleHandle, 18)
        mods[21] = IsToggleModOn(vehicleHandle, 20)
        mods[23] = IsToggleModOn(vehicleHandle, 22)

        mods[50] = GetVehicleModVariation(vehicleHandle, 23)

        -- Basic function to round the number
        local function round(value, dec) local power = 10^dec return math.floor((value * power) + 0.5) / (power) end
        local function pack(...) local a = {...} return a end

        return {
            model             = GetEntityModel(vehicleHandle),
            class             = GetVehicleClass(vehicleHandle),
            plate             = {
                GetVehicleNumberPlateText(vehicleHandle), 
                GetVehicleNumberPlateTextIndex(vehicleHandle)
            },
            health            = {
                round(GetVehicleBodyHealth(vehicleHandle), 1),
                round(GetVehicleEngineHealth(vehicleHandle), 1),
                round(GetVehiclePetrolTankHealth(vehicleHandle), 1),
            },

            fuel              = round(GetVehicleFuelLevel(vehicleHandle), 1),
            color             = {colorPrimary,colorSecondary, pearlescentColor, wheelColor, pack(GetVehicleTyreSmokeColor(vehicleHandle))},

            wheels            = GetVehicleWheelType(vehicleHandle),
            windowTint        = GetVehicleWindowTint(vehicleHandle),
            
            neon = {
                GetVehicleXenonLightsColour(vehicleHandle),
                IsVehicleNeonLightEnabled(vehicleHandle, 0),
                IsVehicleNeonLightEnabled(vehicleHandle, 1),
                IsVehicleNeonLightEnabled(vehicleHandle, 2),
                IsVehicleNeonLightEnabled(vehicleHandle, 3),
                pack(GetVehicleNeonLightsColour(vehicleHandle))
            },

            extras            = extras,
            mods = mods,
            livery = GetVehicleLivery(vehicleHandle)
        }
    end

    SetVehicleComponents = function(vehicleHandle, component)
        SetVehicleModKit(vehicleHandle, 0)

        if type(component.plate) == "table" then
            SetVehicleNumberPlateText(vehicleHandle, component.plate[1])
            SetVehicleNumberPlateTextIndex(vehicleHandle, component.plate[2])
        end

        if type(component.health) == "table" then
            SetVehicleBodyHealth(vehicleHandle, component.health[1] + 0.0)
            SetVehicleEngineHealth(vehicleHandle, component.health[2] + 0.0)
            SetVehiclePetrolTankHealth(vehicleHandle, component.health[3] + 0.0)
        end

        if component.fuel then 
            SetVehicleFuelLevel(vehicleHandle, component.fuel + 0.0) 
        end
        
        if component.color then 
            SetVehicleColours(vehicleHandle, component.color[1], component.color[2]) 
            SetVehicleExtraColours(vehicleHandle, component.color[3], component.color[4])

            SetVehicleTyreSmokeColor(vehicleHandle, component.color[5][1], component.color[5][2], component.color[5][3])
        end

        if component.wheels then SetVehicleWheelType(vehicleHandle, component.wheels) end
        if component.windowTint then SetVehicleWindowTint(vehicleHandle, component.windowTint) end
        if component.neon then 
            SetVehicleXenonLightsColor(vehicleHandle, component.neon[1])

            SetVehicleNeonLightEnabled(vehicleHandle, 0, component.neon[2])
            SetVehicleNeonLightEnabled(vehicleHandle, 1, component.neon[3])
            SetVehicleNeonLightEnabled(vehicleHandle, 2, component.neon[4])
            SetVehicleNeonLightEnabled(vehicleHandle, 3, component.neon[5])
            SetVehicleNeonLightsColour(vehicleHandle, component.neon[6][1], component.neon[6][2], component.neon[6][3])
        end

        if component.extras then
            for i=0, #component.extras do
                SetVehicleExtra(vehicleHandle, tonumber(component.extras[i]), 0)
            end
        end

        if component.mods then
            for i=1, 51 do
                if i == 51 then
                    SetVehicleMod(vehicleHandle, 23, component.mods[24], component.mods[50])

                    if IsThisModelABike(component.model) then
                        SetVehicleMod(vehicleHandle, 24, component.mods[25], component.mods[50])
                    end
                end

                if i ~= 19 and i ~= 21 and i ~= 23 then
                    --print("SetVehicleMod("..vehicleHandle..", "..(i-1)..", "..tostring(component.mods[i])..")")
                    SetVehicleMod(vehicleHandle, i-1, component.mods[i])
                else
                    ToggleVehicleMod(vehicleHandle, i-1, component.mods[i])
                end
            end
        end

        if component.livery then
            SetVehicleLivery(vehicleHandle, component.livery)
        end
    end

--// Addons

    addon = function(name)
        local addon = LoadResourceFile("utility_framework", "client/addons/"..name..".lua")
        
        if addon then
            return load(addon)()
        end
    end
    enc = addon("encrypting")

--// Notification
    ShowNotification = function(msg)
        SetNotificationTextEntry('STRING')
        AddTextComponentSubstringPlayerName(msg)
        DrawNotification(false, true)
    end

    local Button = {
        ["{A}"] = "~INPUT_VEH_FLY_YAW_LEFT~",
        ["{B}"] = "~INPUT_SPECIAL_ABILITY_SECONDARY~",
        ["{C}"] = "~INPUT_LOOK_BEHIND~",
        ["{D}"] = "~INPUT_MOVE_LR~",
        ["{E}"] = "~INPUT_CONTEXT~",
        ["{F}"] = "~INPUT_ARREST~",
        ["{G}"] = "~INPUT_DETONATE~",
        ["{H}"] = "~INPUT_VEH_ROOF~",
        ["{L}"] = "~INPUT_CELLPHONE_CAMERA_FOCUS_LOCK~",
        ["{M}"] = "~INPUT_INTERACTION_MENU~",
        ["{N}"] = "~INPUT_REPLAY_ENDPOINT~",
        ["{O}"] = "UNKOWN_BUTTON",
        ["{P}"] = "~INPUT_FRONTEND_PAUSE~",
        ["{Q}"] = "~INPUT_FRONTEND_LB~",
        ["{R}"] = "~INPUT_RELOAD~",
        ["{S}"] = "~INPUT_MOVE_DOWN_ONLY~",
        ["{T}"] = "~INPUT_MP_TEXT_CHAT_ALL~",
        ["{U}"] = "~INPUT_REPLAY_SCREENSHOT~",
        ["{V}"] = "~INPUT_NEXT_CAMERA~",
        ["{W}"] = "~INPUT_MOVE_UP_ONLY~",
        ["{X}"] = "~INPUT_VEH_DUCK~",
        ["{Y}"] = "INPUT_MP_TEXT_CHAT_TEAM",
        ["{Z}"] = "INPUT_HUD_SPECIAL",
    }
    
    ButtonNotification = function(msg)
        for word in string.gmatch(msg, "{%w}") do msg = msg:gsub(word, Button[word]) end

        AddTextEntry('ButtonNotification', msg)
        BeginTextCommandDisplayHelp('ButtonNotification')
        EndTextCommandDisplayHelp(0, false, true, -1)
    end
--// Closest
    CheckFilterForEntity = function(entity, filter)
        local model = GetEntityModel(entity)

        if type(filter) == "table" then
            for i=1, #filter do
                if type(filter[i]) == "string" then
                    filter[i] = GetHashKey(filter[i])
                end

                if model == filter[i] then
                    return true
                end
            end
        elseif type(filter) == "string" then
            return (model == GetHashKey(filter))
        elseif type(filter) == "number" then
            return (model == filter)
        end
    end

    GetClosestEntity = function(entities, coords, radius, filter)
        local closest = {
            handle   = nil,
            distance = 999,
        }
        
        for i=1, #entities do
            if CheckFilterForEntity(entities[i], filter) then
                local distance = #(GetEntityCoords(entities[i]) - coords)

                if radius and ( -- radius ~= nil
                    distance < radius and distance < closest.distance
                ) or ( -- radius == nil
                    distance < closest.distance 
                ) then
                    closest.handle   = entities[i]
                    closest.distance = distance
                end
            end
        end

        return closest
    end

    GetEntitiesInArea = function(entities, coords, radius, filter)
        local result = {}
        
        for i=1, #entities do
            if CheckFilterForEntity(entities[i], filter) then
                local distance = #(GetEntityCoords(entities[i]) - coords)

                if distance < radius then
                    table.insert(result, entities[i])
                end
            end
        end

        return result
    end

    ---

    GetPeds = function() return GetGamePool("CPed") end
    GetObjects = function() return GetGamePool("CObject") end
    GetVehicles = function() return GetGamePool("CVehicle") end

    ---
    
    GetClosestObject = function(coords, radius, model)
        model = type(model) == "string" and GetHashKey(model) or model

        return GetClosestObjectOfType(coords, radius, model)
    end

    GetClosestVehicle = function(coords, filter)        
        local vehicles = GetVehicles()
        coords = coords or GetEntityCoords(uPlayer.ped)

        return GetClosestEntity(vehicles, coords, false, filter)
    end

    GetClosestPed = function(coords, filter)
        local peds = GetPeds()
        coords = coords or GetEntityCoords(uPlayer.ped)

        return GetClosestEntity(peds, coords, false, filter)
    end

    GetClosestPlayer = function(coords)
        coords = coords or GetEntityCoords(uPlayer.ped)
        local players = GetPlayersInArea(coords)

        return GetClosestEntity(players, coords, false)
    end

    ---

    GetObjectsInArea = function(coords, radius, filter)
        local objects = GetObjects()
        coords = coords or GetEntityCoords(uPlayer.ped)

        return GetEntitiesInArea(objects, coords, radius, filter)
    end

    GetVehiclesInArea = function(coords, radius, filter)
        local vehicles = GetVehicles()
        coords = coords or GetEntityCoords(uPlayer.ped)

        return GetEntitiesInArea(vehicles, coords, radius, filter)
    end

    GetPedsInArea = function(coords, radius, filter)
        local peds = GetPeds()
        coords = coords or GetEntityCoords(uPlayer.ped)

        return GetEntitiesInArea(peds, coords, radius, filter)
    end

    GetPlayersInArea = function(coords, radius)
        local players = GetActivePlayers()
        coords = coords or GetEntityCoords(uPlayer.ped)

        for i=1, #players do
            players[i] = GetPlayerPed(players[i])
        end

        return GetEntitiesInArea(players, coords, radius)
    end

    -- 

    IsAreaClear = function(type, radius)
        if type == "objects" then
            return GetObjectsInArea(nil, radius).handle == nil
        elseif type == "vehicles" then
            return GetVehiclesInArea(nil, radius).handle == nil
        elseif type == "peds" then
            return GetPedsInArea(nil, radius).handle == nil
        elseif type == "players" then
            return GetPlayersInArea(nil, radius).handle == nil
        end
    end

--// Draw
    DrawText2D = function(x, y, text, size, font)
        SetTextScale(size or 0.5, size or 0.5)
        SetTextFont(font or 4)
        SetTextProportional(1)
        SetTextEntry("STRING")
        SetTextCentre(1)
        SetTextColour(255, 255, 255, 255)
        AddTextComponentString(text)
        DrawText(x, y)
    end

    DrawText3D = function(coords, text, scale, font, rectangle)
        local onScreen, _x, _y = World3dToScreen2d(coords.x, coords.y, coords.z)

        if onScreen then
            SetTextScale(scale or 0.35, scale or 0.35)
            SetTextFont(font or 4)
            SetTextEntry("STRING")
            SetTextCentre(1)

            AddTextComponentString(text)
            DrawText(_x, _y)

            if rectangle then
                local factor = (string.len(text))/370
                local _, count = string.gsub(factor, "\n", "\n") * 0.025
                if count == nil then count = 0 end

                DrawRect(_x, _y + 0.0125, 0.025 + factor, 0.025 + count, 0, 0, 0, 90)
            end
        else
            Citizen.Wait(500) -- Prevent loop from going if isnt draw
        end
    end

    local RequestPublicKey = function() -- Request the server public key to encrypt the token
        return TriggerServerCallback("Utility:RequestPublicKey")
    end

    local IsEventSecured = function(name) -- Check if we need to send also the token or not
        local se = GlobalState.SecuredEvents
        
        for i=1, #se do
            if se[i] == name then
                return true
            end
        end
    end

    TriggerServerEvent=function(c,...)
        if IsEventSecured(c) then
            while Keys.Token == nil do -- Wait the framework
                Citizen.Wait(1)
            end
            
            -- Request server the public RSA Key (to share information securely)
            if not Keys.ServerPublic then
                Keys.ServerPublic = RequestPublicKey()
            end
    
            print("[^2API^0] ^3Encrypting token with server public key^0")
            local tosend = exports["utility_framework"]:Encrypt(Keys.ServerPublic, Keys.Token)
            print("[^2API^0] ^3Sending to the server: "..tosend.."^0")
    
    
            --print("[DEBUG] [TBP] Sending server trigger: Encrypted Token  = "..d..", Key  = "..e)
            local f=enc.Utf8ToB64(c)SavedTriggerServerEvent("Utility:External:"..f,msgpack_pack(tosend),...)
            --print("[DEBUG] [TBP] Sending server trigger: "..c.." => Utility:External:"..f)
        else
            SavedTriggerServerEvent(c, ...)
        end
    end
--// Client cache
    SetResourceCache = function(key, value)
        SetResourceKvp(key, value)
    end

    GetResourceCache = function(key, default)
        local _ = GetResourceKvpString(key)

        if _ then
            return _, true
        elseif default then
            SetResourceKvp(key, default)
            return default, false
        end
    end

    DelResourceCache = function(key)
        DeleteResourceKvp(key)
    end
--// Clipboard
    SetClipboard = function(text)
        TriggerEvent("Utility:SetClipboard", text)
    end

    Citizen.CreateThread(function()
        Citizen.Wait(100)

        if OnResourceStop then
            local currentRes = ResourceName
            AddEventHandler("onResourceStop", function(res)
                if res == currentRes then
                    OnResourceStop()
                end
            end)
        end
    end)

    RegisterNetEvent("Utility:PlayerLoaded", function()
        if PlayerLoaded then
            PlayerLoaded()
        end
    end)

--// Other
    CreatePermanentObject = function(...)
        return TriggerServerCallback("Utility:CreatePermanentObject", ...)
    end
    DeletePermanentObject = function(netId)
        SavedTriggerServerEvent("Utility:DeletePermanentObject", netId)
    end

    SetEntityModel = function(entity, model)
        SavedTriggerServerEvent("Utility:SwapModel", GetEntityCoords(entity), GetEntityModel(entity), type(model) == "string" and GetHashKey(model) or model)
    end

    GetRandom = function(table)
        local random = math.random(1, #table)
        return table[random]
    end

    CreateMissionText = function(msg, duration)            
        SetTextEntry_2("STRING")
        AddTextComponentString(msg)
        DrawSubtitleTimed(duration or 60000 * 240, 1) -- 4h

        return {
            delete = function()
                ClearPrints()
            end
        }
    end

    WaitNear = function(coords)
        while #(uPlayer.coords - coords) > 10 do 
            Citizen.Wait(100) 
        end
    end

    apairs = function(t, f)
        local a = {}
        local i = 0
    
        for k in pairs(t) do table.insert(a, k) end
        table.sort(a, f)
        
        local iter = function() -- iterator function
            i = i + 1
            if a[i] == nil then 
                return nil
            else 
                return a[i], t[a[i]]
            end
        end
    
        return iter
    end

    SaveSkin = function()
        return exports["utility_framework"]:SaveSkin()
    end
    GetSkin = function()
        return exports["utility_framework"]:GetSkin()
    end
    GetComponents = function()
        return exports["utility_framework"]:GetComponents()
    end
    ResetSkin = function()
        exports["utility_framework"]:ResetSkin()
    end
    ApplySkin = function(skin, dontsave)
        return exports["utility_framework"]:ApplySkin(skin, dontsave)
    end
    GetSkinMaxVals = function()
        return exports["utility_framework"]:GetSkinMaxVals()
    end
    OpenSkinMenu = function(onclose, filter, noexport)
        exports["utility_framework"]:OpenSkinMenu(onclose, filter, noexport)
    end

    -- Custom State Bag
    NewStateBag = function(...) exports["utility_framework"]:NewCustomStateBag(...) end

    -- RSA
    GenerateKeys = function()
        return exports["utility_framework"]:GenerateKeys()
    end

    Encrypt = function(publicKey, data)
        return exports["utility_framework"]:Encrypt(publicKey, data)
    end

    Decrypt = function(privateKey, data)
        return exports["utility_framework"]:Decrypt(privateKey, data)
    end

--// Fix the Enter/Exit vehicle emitters

_old_TaskLeaveVehicle = TaskLeaveVehicle

TaskLeaveVehicle = function(ped,vehicle,...)
    if ped == uPlayer.ped and uPlayer.vehicle ~= 0 then
        EmitEvent("ExitVehicle", vehicle)
    end

    _old_TaskLeaveVehicle(ped,vehicle,...)
end

_old_TaskEnterVehicle = TaskEnterVehicle

TaskEnterVehicle = function(ped,vehicle,...)
    if ped == PlayerPedId() and uPlayer.vehicle ~= 0 then
        EmitEvent("EnterVehicle", vehicle)
    end

    _old_TaskEnterVehicle(ped,vehicle,...)
end
