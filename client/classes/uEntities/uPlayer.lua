local utfw = exports["utility_framework"]

-- Exports for loader
    -- Money
        exports("GetMoney", function(type)
            return {quantity = LocalPlayer.state.accounts[type], label = Config.Labels["accounts"][type] or type}
        end)

        exports("HaveMoneyQuantity", function(type, quantity)
            return (LocalPlayer.state.accounts[type] >= quantity)
        end)
    -- Item
        exports("GetItem", function(name, data)
            return GetItemInternal(name, data, LocalPlayer.state.inventory)
        end)
        exports("IsItemUsable", function(name, id)
            if name then
                return GlobalState["item_"..name] or false
            else
                return false
            end
        end)

        exports("UseItem", function(name, data)
            if exports["utility_framework"]:HaveItemQuantity(name, 1, data) then
                TriggerServerEvent("Utility:Usable:"..name, data)
            end
        end)
        
        exports("HaveItemQuantity", function(name, quantity, data)
            check({name = "string", quantity = "number"})

            return HaveItemQuantityInternal(name, quantity, data, LocalPlayer.state.inventory)
        end)
        exports("CanCarryItem", function(name, quantity)
            local weight_limit = Config.Inventory.ItemWeight[name] or Config.Inventory.DefaultItemWeight

            if Config.Inventory.Type == "weight" then
                if (LocalPlayer.state.weight + (weight_limit * quantity)) > LocalPlayer.state.maxWeight then
                    return false
                else
                    return true
                end
            elseif Config.Inventory.Type == "limit" then
                local itemq = GetItemInternal(name, nil, LocalPlayer.state.inventory)
    
                if (itemq + quantity) <= weight_limit then
                    return true
                else
                    return false
                end
            end
        end)
    -- Weapon
        exports("AddWeapon", function(weapon, ammo, equipNow)
            weaponhash = GetHashKey(weapon)

            if IsWeaponValid(weaponhash) then
                GiveWeaponToPed(PlayerPedId(), weaponhash, ammo, false, equipNow)

                TriggerServerEvent("Utility:Weapon:AddWeapon", LocalPlayer.state.identifier, weapon:lower(), ammo)
            else
                return nil, "The weapons is invalid"
            end
        end)

        exports("RemoveWeapon", function(weapon)
            weaponhash = GetHashKey(weapon)

            if IsWeaponValid(weaponhash) and HasPedGotWeapon(PlayerPedId(), weaponhash) then
                RemoveWeaponFromPed(PlayerPedId(), GetHashKey(weapon))
                TriggerServerEvent("Utility:Weapon:RemoveWeapon", LocalPlayer.state.identifier, weapon:lower())
            else
                return nil, "The weapons is invalid or the ped not have the weapon"
            end
        end)

        exports("GetWeapons", function()
            local r = {}
            for k,v in pairs(LocalPlayer.state.weapons) do
                r[DecompressWeapon(k)] = v
            end

            return r
        end)

        exports("HaveWeapon", function(name)
            return LocalPlayer.state.weapons[CompressWeapon(name)] or false
        end)
    -- License
        exports("GetLicenses", function()      
            local _ = {}
            
            for k,v in pairs(LocalPlayer.state.licenses) do
                _[k] = {name = v, label =  Config.Labels["license"][v]}
            end

            return _
        end)

        exports("HaveLicense", function(name)
            return LocalPlayer.state.licenses[name] or false
        end)
    -- Identity
        exports("GetIdentity", function(data)
            if data then
                for i=1, #Config.Identity do
                    if Config.Identity[i] == data then
                        return LocalPlayer.state.identity[i]
                    end
                end
            else
                return LocalPlayer.state.identity
            end
        end)
    -- Billing
        exports("GetBills", function()
            return LocalPlayer.state.bills or {}
        end)

    -- IsDead
        exports("IsDead", function()
            return LocalPlayer.state.external.isdead
        end)

    -- Other info integration
        exports("Get", function(id)
            if id == nil then
                return LocalPlayer.state.external
            else
                if LocalPlayer.state.external[id]:find("{") or LocalPlayer.state.external[id]:find("[") then
                    local decoded = json.decode(LocalPlayer.state.external[id])
    
                    if decoded ~= nil then
                        return decoded
                    else
                        return LocalPlayer.state.external[id] or nil
                    end
                else
                    return LocalPlayer.state.external[id] or nil
                end
            end
        end)

    -- Job
        exports("GetJobInfo", function(name)
            return Config.Jobs.Configuration[name]
        end)
    -- Vehicle
        exports("GetComponents", function(plate)
            return TriggerServerCallback("Utility:GetComponents", plate)
        end)

        exports("SpawnOwnedVehicle", function(plate, coords, network)
            if utfw:IsPlateOwned(plate) then
                local components = utfw:GetComponents(plate)
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
        end)

        exports("GetPlateData", function(plate)
            return TriggerServerCallbackAsync("Utility:uPlayer:GetPlateData", plate)
        end)

        exports("GetTrunk", function(plate)
            return utfw:GetPlateData(plate).trunk
        end)

        -- Config
        local function ResourceExist(name)
            for i = 0, GetNumResources(), 1 do
                local res = GetResourceByFindIndex(i)
                if res and res == name then
                    return true
                end
            end

            return false
        end
        
        exports("Config", function(field)
            return Config[field] or Config
        end)