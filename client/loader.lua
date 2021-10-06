SavedTriggerServerEvent = TriggerServerEvent
SavedAddEventHandler = AddEventHandler

uPlayer = nil
Utility = {}

--// Basic PlayerData
    -- Get data from the framework
    Citizen.CreateThreadNow(function()
        while Utility.PlayerData == nil do
            TriggerEvent("Utility:LoadClient", GetCurrentResourceName(), function(table) Utility = table uPlayer = table.PlayerData end)
            Citizen.Wait(1)
        end
    end)

--// uPlayer
    RefreshuPlayer = function()
        uPlayer = Utility.PlayerData
    end

    RegisterNetEvent("Utility:UpdateClient")
    AddEventHandler("Utility:UpdateClient", function(type, data)
        --print("Refreshing "..type.. " with "..json.encode(data))
        Utility.PlayerData[type] = data
        RefreshuPlayer()
    end)

--// ServerCallback
    TriggerServerCallbackAsync = function(name, _function, ...)
        local handlerData = nil

        RegisterNetEvent("Utility_Callback:"..name.."_l")
        handlerData = AddEventHandler("Utility_Callback:"..name.."_l", function(...)
            _function(...)
            RemoveEventHandler(handlerData)
        end)
        
        SavedTriggerServerEvent("Utility_Callback:"..name, ...)
    end

    TriggerServerCallbackSync = function(name, _function, ...)
        local p = promise.new()        
        local handlerData = nil

        RegisterNetEvent("Utility_Callback:"..name.."_l")
        handlerData = AddEventHandler("Utility_Callback:"..name.."_l", function(...)
            _function(...)
            RemoveEventHandler(handlerData)
            p:resolve()
        end)

        SavedTriggerServerEvent("Utility_Callback:"..name, ...)

        Citizen.Await(p)
    end

--// Internal Emitter
    local utilityOn = OnL
    On = function(name, cb)
        if name == "load" then
            Citizen.CreateThreadNow(function()
                while Utility.PlayerData == nil do
                    Citizen.Wait(1)
                end
        
                cb(Utility.PlayerData)
            end)
        else
            if name ~= "marker" and name ~= "object" then
                RegisterNetEvent("Utility_Emitter:"..name)
                AddEventHandler("Utility_Emitter:"..name, function(...)
                    cb(...)
                end)
            else
                utilityOn(name, cb)
            end
        end
    end

--// Functions
    --// Label
        GetLabel = function(header, language, key)
            if language then
                if Utility.Labels[header or "framework"] and Utility.Labels[header or "framework"][language or Utility.DefaultLanguage] then
                    return Utility.Labels[header or "framework"][language or Utility.DefaultLanguage][key] or nil
                else
                    return nil, "Header or language dont exist [Header = '"..header.."' Language = '"..(language or Utility.DefaultLanguage).."']"
                end
            else
                if Utility.Labels[header] then
                    return Utility.Labels[header][key] or nil
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
    --// TriggerBasicProtection
        encrypting = addon("encrypting")
        local BlacklistedToken = {}

        TriggerServerEvent = function(c, ...) 
            local RandomizedToken, Key = encrypting.Utf8ToSHA(tostring(Utility.Token))
            
            if BlacklistedToken[RandomizedToken] then
                while BlacklistedToken[RandomizedToken] do
                    RandomizedToken, Key = encrypting.Utf8ToSHA(tostring(Utility.Token))
                    Citizen.Wait(5)
                end
            end
            
            BlacklistedToken[RandomizedToken] = true
            local tob64 = encrypting.Utf8ToB64(c)
            
            print("Called trigger "..c.." ["..tob64.."]")
            SavedTriggerServerEvent("Utility_External:"..tob64, RandomizedToken, Key, ...) 
        end

    --// Notification
        ShowNotification = function(msg)
            SetNotificationTextEntry('STRING')
            AddTextComponentSubstringPlayerName(msg)
            DrawNotification(false, true)
        end
    --// Closest
        GetClosestVehicle = function(whitelist, radius)
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

                        if currentDistance <= radius and closestVeh.distance < currentDistance then
                            closestVeh.handle   = vehicleList[i]
                            closestVeh.distance = currentDistance
                        end
                    end
                else
                    local currentDistance = #(GetEntityCoords(vehicleList[i]) - coords)

                    if currentDistance <= radius and closestVeh.distance < currentDistance then
                        closestVeh.handle   = vehicleList[i]
                        closestVeh.distance = currentDistance
                    end
                end
            end

            return closestVeh.handle, vehicleList
        end

        GetClosestPed = function(whitelist, radius)
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

                        if currentDistance <= radius and closestPed.distance < currentDistance then
                            closestPed.handle   = pedList[i]
                            closestPed.distance = currentDistance
                        end
                    end
                else
                    local currentDistance = #(GetEntityCoords(pedList[i]) - coords)

                    if currentDistance <= radius and closestPed.distance < currentDistance then
                        closestPed.handle   = pedList[i]
                        closestPed.distance = currentDistance
                    end
                end
            end

            return closestPed.handle, pedList
        end