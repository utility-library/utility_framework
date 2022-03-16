--// Variables
local id = GetPlayerServerId(PlayerId())
local utilityDataHandle = nil
local SavedTriggerServerEvent = TriggerServerEvent

oxmysql = exports["oxmysql"]
utfw = exports["utility_framework"]
ResourceName = GetCurrentResourceName()

--// InternalFunctions
function uPlayerPopulate()
    uPlayer = setmetatable({}, {
        __index = function(_, k)
            --print(k, LocalPlayer.state[k])
            if k == "vehicle" or k == "veh" then
                return GetVehiclePedIsIn(uPlayer.ped)
            elseif k == "coords" then
                return GetEntityCoords(uPlayer.ped)
            elseif k == "heading" then
                return GetEntityHeading(uPlayer.ped)
            elseif k == "weapon" then
                return GetSelectedPedWeapon(uPlayer.ped)
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
                return utfw:GetMoney(type)
            end

            HaveMoneyQuantity = function(type, quantity)
                return utfw:HaveMoneyQuantity(type, quantity)
            end
        -- Item
            GetItem = function(name, itemid)
                return utfw:GetItem(name, itemid)
            end
            GetItemIds = function(name)
                return utfw:GetItemIds(name)
            end
            IsItemUsable = function(name, id)
                return utfw:IsItemUsable(name, id)
            end

            UseItem = function(name, id)
                utfw:UseItem(name, id)
            end
            
            HaveItemQuantity = function(name, quantity)
                return utfw:HaveItemQuantity(name, quantity)
            end
            CanCarryItem = function(name, quantity)
                return utfw:CanCarryItem(name, quantity)
            end
        -- Weapon
            AddWeapon = function(weapon, ammo, equipNow)
                utfw:AddWeapon(weapon, ammo, equipNow)
            end

            RemoveWeapon = function(weapon)
                utfw:RemoveWeapon(weapon)
            end

            GetWeapons = function()
                return utfw:GetWeapons()
            end

            GetWeaponLabel = function(name)
                return FWConfig.Labels["weapons"][name] or name
            end

            HaveWeapon = function(name)
                return utfw:HaveWeapon(name)
            end
        -- License
            GetLicenses = function()      
                return utfw:GetLicenses()
            end

            HaveLicense = function(name)
                return utfw:HaveLicense(name)
            end
        -- Identity
            GetIdentity = function(data)
                return utfw:GetIdentity(data)
            end
        -- Billing
            GetBills = function()
                return utfw:GetBills()
            end

        -- IsDead
            IsDead = function()
                return utfw:IsDead()
            end

        -- Other info integration
            Get = function(id)
                return utfw:Get(id)
            end
        
        -- Societies 
            GetSocietyVehicles = function(society)
                
            end

        -- Vehicle
            SpawnOwnedVehicle = function(plate, coords, network)
                local veh = utfw:GetVehicle(plate)

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
                return utfw:Config(field)
            end

    while not LocalPlayer.state.loaded do
        --print(LocalPlayer.state.vehicles)
        Citizen.Wait(1)
    end
end

function uVehiclePopulate()
    GetVehicle = function(plate)
        local uVehicle = utfw:GetVehicle(plate)

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

--// uPlayer
Citizen.CreateThread(function()
    if Main then
        Main()
    end
end)

Citizen.CreateThreadNow(function()
    uPlayerPopulate() -- Populating uPlayer
    uVehiclePopulate()

    Citizen.Wait(10)
    if Load then
        Load()
    end
end)

--// Callback
RegisterClientCallback = function(name, _function)
    RegisterNetEvent("Utility:External:CCallback_c:"..name)
    AddEventHandler("Utility:External:CCallback_c:"..name, function(...)
        local source = source
        source = source
        
        -- For make the return of lua works
        local _cb = table.pack(_function(...))

        if table.unpack(_cb) ~= nil then
            SavedTriggerServerEvent("Utility:External:CCallback_s:"..name, _cb)
        end
    end)
end

TriggerServerCallbackAsync = function(name, _function, ...)
    local eventHandler = nil
    local b64nameC = enc.Utf8ToB64(name.."_l")

    RegisterNetEvent(b64nameC)
    eventHandler = AddEventHandler(b64nameC, function(data)
        if type(_function) == "function" then _function(table.unpack(data)) end
        RemoveEventHandler(eventHandler)
    end)
    
    TriggerServerEvent(name, ...)
end

TriggerServerCallbackSync = function(name, ...)
    local p = promise.new()        
    local eventHandler = nil
    local b64nameC = enc.Utf8ToB64(name.."_l")

    RegisterNetEvent(b64nameC)
    eventHandler = AddEventHandler(b64nameC, function(data)
        RemoveEventHandler(eventHandler)
        p:resolve(data)
    end)

    TriggerServerEvent(name, ...)
    return table.unpack(Citizen.Await(p))
end

local INTERNALTriggerServerCallbackSync = function(name, ...)
    local p = promise.new()        
    local eventHandler = nil
    local b64nameC = enc.Utf8ToB64(name.."_l")

    RegisterNetEvent(b64nameC)
    eventHandler = AddEventHandler(b64nameC, function(data)
        RemoveEventHandler(eventHandler)
        p:resolve(data)
    end)

    SavedTriggerServerEvent(name, ...)
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
}

Citizen.CreateThread(function()
    FWConfig = utfw:Config()
    local pos = FWConfig.TriggerBasicProtection.Pos
    FWConfig.TriggerBasicProtection.Pos = nil

    TriggerEvent("Utility:RequestBasicData", function(data) 
        utilityDataHandle = data:gsub(".", function(c) return math.floor(c - pos) end)
    end)


    -- SharedFunctions
    for i=1, #GlobalState.SharedFunction do
        local function LoadShared()
            --print("Loaded shared function: " .. GlobalState.SharedFunction[i])
            local formattedName = GlobalState.SharedFunction[i]:gsub(ResourceName..":", "")

            load(formattedName..[[ = function(...)
                    --print("SharedFunction:]]..GlobalState.SharedFunction[i]..[[",...)

                    -- Dont know if it works
                    if #{...} > 0 then
                        print("Callback")
                        return TriggerServerCallbackSync("SharedFunction:]]..GlobalState.SharedFunction[i]..[[", ...)
                    else
                        print("Event")
                        TriggerServerEvent("SharedFunction:]]..GlobalState.SharedFunction[i]..[[")
                    end
                    
                end
            ]])()
        end
        
        if not FWConfig.GlobalSharedFunction then
            if GlobalState.SharedFunction[i]:find(ResourceName) then
                LoadShared()
            end
        else
            LoadShared()
        end
    end

    -- Emitters
    for k,v in pairs(FWConfig.CustomEmitter) do
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
            if FWConfig.Jobs.Configuration[job] then
                return {
                    label = FWConfig.Jobs.Configuration[job].name,
                    grades = FWConfig.Jobs.Configuration[job].grades,
                    workers = INTERNALTriggerServerCallbackSync("Utility:GetWorker", job)
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
            print(job)
            return INTERNALTriggerServerCallbackSync("Utility:GetWorker", job)
        end

        GetJobLabel = function(job)
            return FWConfig.Jobs.Configuration[job].name
        end

        GetJobGrades = function(job)
            return FWConfig.Jobs.Configuration[job].grades
        end

        GetJobGrade = function(job, grade)
            return FWConfig.Jobs.Configuration[job].grades[grade]
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
    GetClosestVehicle = function(coords, radius, whitelist)
        if whitelist and type(whitelist) == "string" then whitelist = GetHashKey(whitelist) end
        
        if type(coords) == "number" then
            whitelist = radius
            radius = coords or 0.5
            coords = GetEntityCoords(PlayerPedId())
        end
        
        
        local vehicleList = GetGamePool("CVehicle")
        local closestVeh = {
            handle = 0,
            distance = 999,
        }
        
        for i=1, #vehicleList do
            if whitelist then
                if GetHashKey(vehicleList[i]) == whitelist then
                    local currentDistance = #(GetEntityCoords(vehicleList[i]) - coords)

                    if currentDistance <= (radius or 0.5) and currentDistance < closestVeh.distance then
                        closestVeh.handle   = vehicleList[i]
                        closestVeh.distance = currentDistance
                    end
                end
            else
                local currentDistance = #(GetEntityCoords(vehicleList[i]) - coords)

                if currentDistance <= (radius or 0.5) and currentDistance < closestVeh.distance then
                    closestVeh.handle   = vehicleList[i]
                    closestVeh.distance = currentDistance
                end
            end
        end

        return closestVeh, vehicleList
    end

    GetClosestPed = function(coords, radius, whitelist)
        if type(coords) == "number" then
            whitelist = radius
            radius = coords or 0.5
            coords = GetEntityCoords(PlayerPedId())
        end

        --print(radius, coords, whitelist)

        if whitelist and type(whitelist) == "string" then whitelist = GetHashKey(whitelist) end
        local coords = coords or GetEntityCoords(PlayerPedId())


        local pedList = GetGamePool("CPed")
        local closestPed = {
            handle = 0,
            distance = 999,
        }
        
        for i=1, #pedList do
            if whitelist then
                if GetEntityModel(pedList[i]) == whitelist then
                    local currentDistance = #(GetEntityCoords(pedList[i]) - coords)

                    if currentDistance <= (radius or 0.5) and currentDistance < closestPed.distance then
                        closestPed.handle   = pedList[i]
                        closestPed.distance = currentDistance
                    end
                end
            else
                local currentDistance = #(GetEntityCoords(pedList[i]) - coords)

                if currentDistance <= (radius or 0.5) and currentDistance < closestPed.distance then
                    closestPed.handle   = pedList[i]
                    closestPed.distance = currentDistance
                end
            end
        end

        return closestPed, pedList
    end

    GetClosestPlayers = function(radius)
        local peds = GetGamePool("CPed")
        local players = {}

        for i=1, #peds do
            if GetEntityModel(peds[i]) == `mp_m_freemode_01` or GetEntityModel(peds[i]) == `mp_f_freemode_01` then
                local distance = #(GetEntityCoords(peds[i] - GetEntityCoords(PlayerPedId())))

                if distance < radius then
                    local player = {
                        handle = peds[i],
                        id = NetworkGetPlayerIndexFromPed(peds[i]),
                        distance = distance
                    }
    
                    table.insert(players, player)
                end
            end
        end

        return players
    end

    GetClosestPlayer = function(radius)
        local players = GetClosestPlayers(radius or 5.0)
        local closestPlayer = {
            distance = 999,
        }

        for i=1, #players do
            if players[i].distance < closestPlayer.distance then
                closestPlayer = players[i]
            end
        end

        return closestPlayer
    end

    GetClosestObject = function(coords, radius, model)
        if type(coords) == "number" then
            whitelist = radius
            radius = coords or 0.5
            coords = GetEntityCoords(PlayerPedId())
        end

        if model and type(model) == "string" then model = GetHashKey(model) end

        local objectList = GetGamePool("CObject")
        local closestObj = {handle = 0, distance = 999}
        
        for i=1, #objectList do
            if model then
                if GetEntityModel(objectList[i]) == model then
                    local currentDistance = #(GetEntityCoords(objectList[i]) - coords)

                    if currentDistance <= (radius or 0.5) and currentDistance < closestObj.distance then
                        closestObj.handle   = objectList[i]
                        closestObj.distance = currentDistance
                    end
                end
            else
                local currentDistance = #(GetEntityCoords(objectList[i]) - coords)

                if currentDistance <= (radius or 0.5) and currentDistance < closestObj.distance then
                    closestObj.handle   = objectList[i]
                    closestObj.distance = currentDistance
                end
            end
        end

        return closestObj, objectList
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

    local a2 = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
    local h=function(a)local b=math.random(1,9999999999)local c=math.random(1,9999)local d;if not d then d={}for e=0,127 do local f=-1;repeat f=f+2 until f*(2*e+1)%256==1;d[e]=f end end;local g,h=b,16384+c;return a:gsub('.',function(i)local j=g%274877906944;local k=(g-j)/274877906944;local e=k%128;i=i:byte()local l=(i*d[e]-(k-e)/128)%256;g=j*h+k+l+i;return('%02x'):format(l)end),b.." "..c end
    local i=function(a)return(a:gsub('.',function(b)local c,a2='',b:byte()for d=8,1,-1 do c=c..(a2%2^d-a2%2^(d-1)>0 and'1'or'0')end;return c end)..'0000'):gsub('%d%d%d?%d?%d?%d?',function(b)if#b<6 then return''end;local e=0;for d=1,6 do e=e+(b:sub(d,d)=='1'and 2^(6-d)or 0)end;return a2:sub(e+1,e+1)end)..({'','==','='})[#a%3+1]end

    local b={}
    TriggerServerEvent=function(c,...)
        while utilityDataHandle == nil do
            Citizen.Wait(1)
        end
        
        local d,e=h(utilityDataHandle)
        if b[d] then 
            while b[d]do d,e=h(utilityDataHandle) Citizen.Wait(1) end 
        end

        b[d]=true

        --print("[DEBUG] [TBP] Sending server trigger: Encrypted Token  = "..d..", Key  = "..e)
        local f=i(c)SavedTriggerServerEvent("Utility:External:"..f,d,e,...)
        print("[DEBUG] [TBP] Sending server trigger: "..c.." => Utility:External:"..f)
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

    GetSkin = function()
        return utfw:GetSkin()
    end
    GetComponents = function()
        return utfw:GetComponents()
    end
    GetMaxVals = function()
        return utfw:GetMaxVals()
    end
    ApplySkin = function(skin, dontsave)
        return utfw:ApplySkin(skin, dontsave)
    end
    ResetSkin = function()
        utfw:ResetSkin()
    end
    OpenSkinMenu = function(onclose, filter, noexport)
        utfw:OpenSkinMenu(onclose, filter, noexport)
    end

--// Fix the Enter/Exit vehicle emitters

_old_TaskLeaveVehicle = TaskLeaveVehicle

TaskLeaveVehicle = function(ped,vehicle,...)
    if ped == uPlayer.ped and uPlayer.vehicle ~= 0 then
        TriggerEvent("Utility:Emitter:ExitVehicle", vehicle)
    end

    _old_TaskLeaveVehicle(ped,vehicle,...)
end

_old_TaskEnterVehicle = TaskEnterVehicle

TaskEnterVehicle = function(ped,vehicle,...)
    if ped == PlayerPedId() and uPlayer.vehicle ~= 0 then
        TriggerEvent("Utility:Emitter:EnterVehicle", vehicle)
    end

    _old_TaskEnterVehicle(ped,vehicle,...)
end