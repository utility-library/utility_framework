local function GetAccountIndex(type)
    for i=1, #Config.Accounts do
        if Config.Accounts[i] == type then
            return i
        end
    end
end

local utfw = exports["utility_framework"]

-- Exports for loader
    -- Money
        exports("GetMoney", function(type)
            return {count = LocalPlayer.state.accounts[GetAccountIndex(type)], label = GetLabel("accounts", type) or type}
        end)

        exports("HaveMoneyQuantity", function(type, quantity)
            return (LocalPlayer.state.accounts[GetAccountIndex(type)] >= quantity)
        end)
    -- Item
        exports("GetItem", function(name, itemid)
            if Config.Actived.ItemData then
                if not itemid then -- if there is a itemid defined
                    itemid = "nodata"
                end

                print(name, itemid)
                if Config.Inventory.type == "weight" then
                    return {count = LocalPlayer.state.inventory[name][itemid][1], label = GetLabel("items", name) or name, weight = Config.Inventory.itemdata[name] or Config.Inventory.defaultitem, data = LocalPlayer.state.inventory[name][itemid][2], __type = "item"}
                elseif Config.Inventory.type == "limit" then
                    return {count = LocalPlayer.state.inventory[name][itemid][1], label = GetLabel("items", name) or name, limit = Config.Inventory.itemdata[name] or Config.Inventory.defaultitem, data = LocalPlayer.state.inventory[name][itemid][2], __type = "item"}
                end
            else
                if Config.Inventory.type == "weight" then
                    return {count = LocalPlayer.state.inventory[name], label = GetLabel("items", name) or name, weight = Config.Inventory.itemdata[name] or Config.Inventory.defaultitem, __type = "item"}
                elseif Config.Inventory.type == "limit" then
                    return {count = LocalPlayer.state.inventory[name], label = GetLabel("items", name) or name, limit = Config.Inventory.itemdata[name] or Config.Inventory.defaultitem, __type = "item"}
                end
            end
        end)
        exports("GetItemIds", function(name)
            local ids = {}
            
            for k, v in pairs(LocalPlayer.state.inventory[name]) do
                table.insert(ids, k)
            end

            return ids
        end)
        exports("IsItemUsable", function(name, id)
            if id then
                return GlobalState["item_"..name..":"..id] or false
            end

            return GlobalState["item_"..name] or false
        end)

        exports("UseItem", function(name, id)
            if id then
                TriggerServerEvent("Utility_Usable:"..name..":"..id)
            else
                TriggerServerEvent("Utility_Usable:"..name)
            end
        end)
        
        exports("HaveItemQuantity", function(name, quantity)
            if LocalPlayer.state.inventory[name] then
                return (LocalPlayer.state.inventory[name] >= quantity)
            else
                return nil
            end
        end)
        exports("CanCarryItem", function(name, quantity)
            if (LocalPlayer.state.weight + ((Config.ItemWeight[name] or Config.DefaultItemWeight) * quantity)) > Config.MaxWeight then
                return false
            else
                return true
            end
        end)
    -- Weapon
        exports("AddWeapon", function(weapon, ammo, equipNow)
            weaponhash = GetHashKey(weapon)

            if IsWeaponValid(weaponhash) then
                GiveWeaponToPed(PlayerPedId(), weaponhash, ammo, false, equipNow)

                print("Utility:Weapon:AddWeapon", LocalPlayer.state.steam, (weapon:lower()):gsub("weapon_", ""), ammo)
                TriggerServerEvent("Utility:Weapon:AddWeapon", LocalPlayer.state.steam, (weapon:lower()):gsub("weapon_", ""), ammo)
            else
                return nil, "The weapons is invalid"
            end
        end)

        exports("RemoveWeapon", function(weapon)
            weaponhash = GetHashKey(weapon)

            if IsWeaponValid(weaponhash) and HasPedGotWeapon(PlayerPedId(), weaponhash) then
                RemoveWeaponFromPed(PlayerPedId(), GetHashKey(weapon))
                TriggerServerEvent("Utility:Weapon:RemoveWeapon", LocalPlayer.state.steam, (weapon:lower()):gsub("weapon_", ""))
            else
                return nil, "The weapons is invalid or the ped not have the weapon"
            end
        end)

        exports("GetWeapons", function()
            return LocalPlayer.state.other_info.weapon or {}
        end)

        exports("HaveWeapon", function(name)
            return LocalPlayer.state.other_info.weapon[name:lower()] or false
        end)
    -- License
        exports("GetLicenses", function()      
            local _ = {}
            
            for k,v in pairs(LocalPlayer.state.other_info.license) do
                _[k] = {name = v, label = GetLabel("license", v)}
            end

            return _
        end)

        exports("HaveLicense", function(name)
            return LocalPlayer.state.other_info.license[name] or false
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
            return LocalPlayer.state.other_info.bills or {}
        end)

    -- IsDeath
        exports("IsDeath", function()
            return LocalPlayer.state.other_info.isdeath
        end)

    -- Other info integration
        exports("Get", function(id)
            if id == nil then
                return LocalPlayer.state.other_info.scripts
            else
                local decoded = json.decode(LocalPlayer.state.other_info.scripts[id])

                if decoded ~= nil then
                    return decoded
                else
                    return LocalPlayer.state.other_info.scripts[id] or nil
                end
            end
        end)

    -- Job
        exports("GetJobInfo", function(name)
            return Config.Jobs.Configuration[name]
        end)
    -- Vehicle
        exports("IsPlateOwned", function(plate)
            for i=1, #LocalPlayer.state.other_info.vehicles do
                if LocalPlayer.state.other_info.vehicles[i] == plate then
                    return true
                end
            end

            return false
        end)

        exports("GetComponents", function(plate)
            return TriggerServerCallbackAsync("Utility:GetComponents", plate)
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
            return TriggerServerCallbackSync("Utility:uPlayer:GetPlateData", plate)
        end)

        exports("GetTrunk", function(plate)
            return utfw:GetPlateData(plate).trunk
        end)

        -- Config
        exports("Config", function(field)
            return Config[field] or Config
        end)