-- ServerCallback
TriggerServerCallbackAsync = function(name, _function, ...)
    local handlerData = nil

    RegisterNetEvent("Utility:"..name.."_l")
    handlerData = AddEventHandler("Utility:"..name.."_l", function(...)
        _function(...)

        RemoveEventHandler(handlerData)
    end)

    
    TriggerServerEvent("Utility:"..name, ...)
end

TriggerServerCallbackSync = function(name, _function, ...)
    local a = false
    local handlerData = nil

    RegisterNetEvent("Utility:"..name.."_l")
    handlerData = AddEventHandler("Utility:"..name.."_l", function(...)
        _function(...)
        a = true
        RemoveEventHandler(handlerData)
    end)

    TriggerServerEvent("Utility:"..name, ...)

    while not a do
        Citizen.Wait(1)
    end
end

GetLabel = function(key, header, language)
    if Config.Labels[header or "framework"] and Config.Labels[header or "framework"][language or Config.DefaultLanguage] then
        return Config.Labels[header or "framework"][language or Config.DefaultLanguage][key] or nil
    else
        return nil, "Header or language dont exist [Header = '"..header.."' Language = '"..language.."']"
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

    return self
end