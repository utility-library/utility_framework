-- ServerCallback
TriggerServerCallbackAsync = function(name, _function, ...)
    local handlerData = nil

    RegisterNetEvent("Utility_Callback:"..name.."_l")
    handlerData = AddEventHandler("Utility_Callback:"..name.."_l", function(...)
        _function(...)

        RemoveEventHandler(handlerData)
    end)

    
    TriggerServerEvent("Utility_Callback:"..name, ...)
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

    TriggerServerEvent("Utility_Callback:"..name, ...)

    Citizen.Await(p)
end

GetLabel = function(key, header, language)
    if Config.Labels[header or "framework"] and Config.Labels[header or "framework"][language or Config.DefaultLanguage] then
        return Config.Labels[header or "framework"][language or Config.DefaultLanguage][key] or nil
    else
        return nil, "Header or language dont exist [Header = '"..header.."' Language = '"..language.."']"
    end
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

uPlayerPopulate = function(self)
    -- Function
        -- Money
            self.GetMoney = function(type)
                return {count = self.accounts[type], label = GetLabel("accounts", nil, type) or type}
            end

            self.HaveMoneyQuantity = function(type, quantity)
                return (self.accounts[type] >= quantity)
            end
        -- Item
            self.GetItem = function(name, itemid)
                if Config.Actived.ItemData then
                    return {count = self.inventory[name][itemid][1], label = GetLabel("items", nil, name) or name, weight = Config.ItemWeight[name] or Config.DefaultItemWeight, data = self.inventory[name][itemid][2]}
                else
                    return {count = self.inventory[name], label = GetLabel("items", nil, name) or name, weight = Config.ItemWeight[name] or Config.DefaultItemWeight}
                end
            end
            self.GetItemIds = function(name)
                local ids = {}
                
                for k, v in pairs(self.inventory[name]) do
                    table.insert(ids, k)
                end

                return ids
            end
            self.IsItemUsable = function(name)
                return Utility.UsableItem[name] or false
            end

            self.UseItem = function(name, id)
                if id then
                    if Utility.UsableItem[name][id] then
                        TriggerEvent("Utility_Usable:"..name..":"..id, self)
                    end
                else
                    if Utility.UsableItem[name] then
                        TriggerEvent("Utility_Usable:"..name, self)
                    end
                end
            end
            
            self.HaveItemQuantity = function(name, quantity)
                if self.inventory[name] then
                    return (self.inventory[name] >= quantity)
                else
                    return nil
                end
            end
            self.CanCarryItem = function(name, quantity)
                if (self.weight + ((Config.ItemWeight[name] or Config.DefaultItemWeight) * quantity)) > Config.MaxWeight then
                    return false
                else
                    return true
                end
            end
        -- Weapon
            self.AddWeapon = function(weapon, ammo, equipNow)
                weaponhash = GetHashKey(weapon)

                if IsWeaponValid(weaponhash) then
                    GiveWeaponToPed(PlayerPedId(), weaponhash, ammo, false, equipNow)
                    TriggerServerEvent("Utility:Weapon", self.steam, 1, (weapon:lower()):gsub("weapon_", ""), ammo)
                else
                    return nil, "The weapons is invalid"
                end
            end

            self.RemoveWeapon = function(weapon)
                weaponhash = GetHashKey(weapon)

                if IsWeaponValid(weaponhash) and HasPedGotWeapon(PlayerPedId(), weaponhash) then
                    RemoveWeaponFromPed(PlayerPedId(), GetHashKey(weapon))
                    TriggerServerEvent("Utility:Weapon", self.steam, 2, (weapon:lower()):gsub("weapon_", ""))
                else
                    return nil, "The weapons is invalid or the ped not have the weapon"
                end
            end

            self.GetWeapons = function()
                return self.other_info.weapon or {}
            end

            self.HaveWeapon = function(name)
                return self.other_info.weapon[name:lower()] or false
            end
        -- License
            self.GetLicenses = function()        
                local _ = {}
                
                for k,v in pairs(self.other_info.license) do
                    _[k] = {name = v, label = GetLabel("license", nil, v)}
                end

                return _
            end

            self.HaveLicense = function(name)
                return self.other_info.license[name] or false
            end
        -- Identity
            self.GetIdentity = function(data)
                if data then
                    return self.identity[data]
                else
                    return self.identity
                end
            end
        -- Billing
            self.GetBills = function()
                return self.other_info.bills or {}
            end
        
        -- IsDeath
            self.IsDeath = function()
                return self.other_info.isdeath
            end

        -- Other info integration
            self.Get = function(id)
                if id == nil then
                    return self.other_info.scripts
                else
                    return self.other_info.scripts[id] or nil
                end
            end
        
        -- Job
            self.GetJobInfo = function(name)
                return Config.Jobs.Configuration[name]
            end
        -- Vehicle
            self.IsPlateOwned = function(plate)
                for i=1, #self.other_info.vehicles do
                    if self.other_info.vehicles[i] == plate then
                        return true
                    end
                end

                return false
            end

            self.GetComponents = function(plate)
                local a = promise:new()
                
                TriggerServerCallbackSync("Utility:GetComponents", function(comp)
                    a:resolve(comp)
                end, plate)

                return Citizen.Await(a)
            end

            self.SpawnOwnedVehicle = function(plate, coords, network)
                if self.IsPlateOwned(plate) then
                    local components = self.GetComponents(plate)
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

    return self
end

--// Addons
addon = function(name)
    local module = LoadResourceFile("utility_framework", "client/addons/"..name..".lua")
    
    if module then
        return load(module)()
    end
end