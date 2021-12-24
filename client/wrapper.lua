--// Variables
local utilityDataHandle = nil
local SavedTriggerServerEvent = TriggerServerEvent
local UtilityExports = exports["utility_framework"]

--// InternalFunctions
function uPlayerPopulate()
    uPlayer = LocalPlayer.state  -- Setting standard data (money, inventory, etc)

    -- Assigning functions to the uPlayer
        -- Money
            GetMoney = function(type)
                return UtilityExports:GetMoney(type)
            end

            HaveMoneyQuantity = function(type, quantity)
                return UtilityExports:HaveMoneyQuantity(type, quantity)
            end
        -- Item
            GetItem = function(name, itemid)
                return UtilityExports:GetItem(name, itemid)
            end
            GetItemIds = function(name)
                return UtilityExports:GetItemIds(name)
            end
            IsItemUsable = function(name, id)
                return UtilityExports:IsItemUsable(name, id)
            end

            UseItem = function(name, id)
                UtilityExports:UseItem(name, id)
            end
            
            HaveItemQuantity = function(name, quantity)
                return UtilityExports:HaveItemQuantity(name, quantity)
            end
            CanCarryItem = function(name, quantity)
                return UtilityExports:CanCarryItem(name, quantity)
            end
        -- Weapon
            AddWeapon = function(weapon, ammo, equipNow)
                UtilityExports:AddWeapon(weapon, ammo, equipNow)
            end

            RemoveWeapon = function(weapon)
                UtilityExports:RemoveWeapon(weapon)
            end

            GetWeapons = function()
                return UtilityExports:GetWeapons()
            end

            HaveWeapon = function(name)
                return UtilityExports:HaveWeapon(name)
            end
        -- License
            GetLicenses = function()      
                return UtilityExports:GetLicenses()
            end

            HaveLicense = function(name)
                return UtilityExports:HaveLicense(name)
            end
        -- Identity
            GetIdentity = function(data)
                return UtilityExports:GetIdentity(data)
            end
        -- Billing
            GetBills = function()
                return UtilityExports:GetBills()
            end

        -- IsDeath
            IsDeath = function()
                return UtilityExports:IsDeath()
            end

        -- Other info integration
            Get = function(id)
                return UtilityExports:Get(id)
            end

        -- Job
            GetJobInfo = function(name)
                return UtilityExports:GetJobInfo(name)
            end
        -- Vehicle
            IsPlateOwned = function(plate)
                return UtilityExports:IsPlateOwned(plate)
            end

            GetComponents = function(plate)
                return TriggerServerCallbackAsync("Utility:GetComponents", plate)
            end

            SpawnOwnedVehicle = function(plate, coords, network)
                if IsPlateOwned(plate) then
                    local components = GetComponents(plate)
                    RequestModel(components.model)
                    
                    while not HasModelLoaded(components.model) do
                        Citizen.Wait(1)
                    end

                    local veh = CreateVehicle(components.model, coords, 0.0, true)
                    SetVehicleComponents(veh, components)
                    return veh, true
                else
                    return nil, false
                end
            end

            GetPlateData = function(plate)
                return TriggerServerCallbackAsync("Utility:uPlayer:GetPlateData", plate)
            end 

            GetTrunk = function(plate)
                return GetPlateData(plate).trunk
            end

        -- Config
            Config = function(field)
                return UtilityExports:Config(field)
            end
end

--// uPlayer
uPlayerPopulate() -- Populating uPlayer

TriggerEvent("Utility:RequestBasicData", function(data) utilityDataHandle = tostring(data) end)

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

TriggerServerCallbackSync = function(name, _function, ...)
    local eventHandler = nil
    local b64nameC = "Utility:External:"..enc.Utf8ToB64("Utility_Callback:"..name.."_l")
    local b64nameS = "Utility:External:"..enc.Utf8ToB64("Utility_Callback:"..name)

    RegisterNetEvent(b64nameC)
    eventHandler = AddEventHandler(b64nameC, function(...)
        if type(_function) == "function" then _function(...) end
        RemoveEventHandler(eventHandler)
    end)
    
    SavedTriggerServerEvent(b64nameS, ...)
end

TriggerServerCallbackAsync = function(name, ...)
    local p = promise.new()        
    local eventHandler = nil
    local b64nameC = "Utility:External:"..enc.Utf8ToB64("Utility_Callback:"..name.."_l")
    local b64nameS = "Utility:External:"..enc.Utf8ToB64("Utility_Callback:"..name)

    RegisterNetEvent(b64nameC)
    eventHandler = AddEventHandler(b64nameC, function(...)
        RemoveEventHandler(eventHandler)
        p:resolve(...)
    end)

    SavedTriggerServerEvent(b64nameS, ...)
    return Citizen.Await(p)
end

--// Internal Emitter
local EmitterEvents = {
    "JobChange",
    "GradeChange",
    "OnDuty",
}

for i=1, #EmitterEvents do
    RegisterNetEvent("Utility:Emitter:"..EmitterEvents[i])
    AddEventHandler("Utility:Emitter:"..EmitterEvents[i], function(...)
        if _G[EmitterEvents[i]] then
            _G[EmitterEvents[i]](...)
        end
    end)
end

--// Functions
--// Label
    GetLabel = function(header, language, key)
        if language then
            if GlobalState.Labels[header or "framework"] and GlobalState.Labels[header or "framework"][language or GlobalState.DefaultLanguage] then
                return GlobalState.Labels[header or "framework"][language or GlobalState.DefaultLanguage][key] or nil
            else
                return nil, "Header or language dont exist [Header = '"..header.."' Language = '"..(language or GlobalState.DefaultLanguage).."']"
            end
        else
            if GlobalState.Labels[header] then
                return GlobalState.Labels[header][key] or nil
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
        return GlobalState.Jobs[job]
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
                    table.insert(extras, tostring(i))
                end
            end
        end

        -- Mods
        for i=0, 17 do
            table.insert(mods, GetVehicleMod(vehicleHandle, i - 1))
        end

        table.insert(mods, IsToggleModOn(vehicleHandle, 18))
        table.insert(mods, IsToggleModOn(vehicleHandle, 20))
        table.insert(mods, IsToggleModOn(vehicleHandle, 22))
        

        for i=23, 46 do
            table.insert(mods, GetVehicleMod(vehicleHandle, i))
        end

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
        if type(component.plate) == "table" then
            SetVehicleNumberPlateText(vehicleHandle, component.plate[1])
            SetVehicleNumberPlateTextIndex(vehicleHandle, component.plate[2])
        end

        if type(component.health) == "table" then
            SetVehicleBodyHealth(vehicleHandle, component.health[1])
            SetVehicleEngineHealth(vehicleHandle, component.health[2])
            SetVehiclePetrolTankHealth(vehicleHandle, component.health[3])
        end

        if component.fuel then SetVehicleFuelLevel(vehicleHandle, component.fuel) end
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
            for i=1, #component.extras do
                SetVehicleExtra(vehicleHandle, tonumber(component.extras[i]), 1)
            end
        end

        if component.mods then
            for i=1, #component.mods do
                if i < 19 then
                    SetVehicleMod(vehicleHandle, i, component.mods[i], false)
                elseif i > 21 then
                    SetVehicleMod(vehicleHandle, i, component.mods[i], false)
                end
            end

            ToggleVehicleMod(vehicleHandle, 18, component.mods[19])
            ToggleVehicleMod(vehicleHandle, 20, component.mods[20])
            ToggleVehicleMod(vehicleHandle, 22, component.mods[21])
        end

        if component.livery then
            SetVehicleLivery(vehicleHandle, component.livery)
        end
    end

--// Addons

    addon = function(name)
        local module = LoadResourceFile("utility_framework", "client/addons/"..name..".lua")
        
        if module then
            return load(module)()
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
        for word in string.gmatch(msg, "{.*}") do msg = msg:gsub(word, Button[word]) end

        AddTextEntry('ButtonNotification', msg)
        BeginTextCommandDisplayHelp('ButtonNotification')
        EndTextCommandDisplayHelp(0, false, true, -1)
    end
--// Closest
    GetClosestVehicle = function(radius, whitelist)
        if whitelist and type(whitelist) == "string" then whitelist = GetHashKey(whitelist) end
        local coords = GetEntityCoords(PlayerPedId())
        
        
        local vehicleList = GetGamePool("CVehicle")
        local closestVeh = {
            handle = nil,
            distance = 999,
        }
        
        for i=1, #vehicleList do
            if whitelist then
                if GetHashKey(vehicleList[i]) == whitelist then
                    local currentDistance = #(GetEntityCoords(vehicleList[i]) - coords)

                    if currentDistance <= radius and currentDistance < closestVeh.distance then
                        closestVeh.handle   = vehicleList[i]
                        closestVeh.distance = currentDistance
                    end
                end
            else
                local currentDistance = #(GetEntityCoords(vehicleList[i]) - coords)

                if currentDistance <= radius and currentDistance < closestVeh.distance then
                    closestVeh.handle   = vehicleList[i]
                    closestVeh.distance = currentDistance
                end
            end
        end

        return closestVeh, vehicleList
    end

    GetClosestPed = function(radius, whitelist)
        if whitelist and type(whitelist) == "string" then whitelist = GetHashKey(whitelist) end
        local coords = GetEntityCoords(PlayerPedId())


        local pedList = GetGamePool("CPed")
        local closestPed = {
            handle = nil,
            distance = 999,
        }
        
        for i=1, #pedList do
            if whitelist then
                if GetHashKey(pedList[i]) == whitelist then
                    local currentDistance = #(GetEntityCoords(pedList[i]) - coords)

                    if currentDistance <= radius and currentDistance < closestPed.distance then
                        closestPed.handle   = pedList[i]
                        closestPed.distance = currentDistance
                    end
                end
            else
                local currentDistance = #(GetEntityCoords(pedList[i]) - coords)

                if currentDistance <= radius and currentDistance < closestPed.distance then
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
                local player = {
                    handle = peds[i],
                    id = NetworkGetPlayerIndexFromPed(peds[i]),
                    distance = #(GetEntityCoords(peds[i] - GetEntityCoords(PlayerPedId())))
                }

                table.insert(players, player)
            end
        end

        return players
    end

    GetClosestPlayer = function(radius)
        local players = GetClosestPlayers(radius)
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
        if model and type(model) == "string" then model = GetHashKey(model) end

        local objectList = GetGamePool("CObject")
        local closestObj = {handle = nil, distance = 999}
        
        for i=1, #objectList do
            if model then
                if GetEntityModel(objectList[i]) == model then
                    local currentDistance = #(GetEntityCoords(objectList[i]) - coords)

                    if currentDistance <= radius and currentDistance < closestObj.distance then
                        closestObj.handle   = objectList[i]
                        closestObj.distance = currentDistance
                    end
                end
            else
                local currentDistance = #(GetEntityCoords(objectList[i]) - coords)

                if currentDistance <= radius and currentDistance < closestObj.distance then
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
--// SharedFunction
    for i=1, #GlobalState.SharedFunction do
        load([[
            ]]..GlobalState.SharedFunction[i]..[[ = function(...)
                --print("Utility:External_InvokeSharedFunction:]]..GlobalState.SharedFunction[i]..[[",...)
                return TriggerServerCallbackAsync("Utility:External:InvokeSharedFunction:]]..GlobalState.SharedFunction[i]..[[", nil, ...)
            end
        ]])()
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

        print("[DEBUG] [TBP] Sending server trigger: Encrypted Token  = "..d..", Key  = "..e)
        local f=i(c)SavedTriggerServerEvent("Utility:External:"..f,d,e,...)
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