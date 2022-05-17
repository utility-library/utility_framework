-- Client Logger
RegisterServerEvent("Utility:Logger")
AddEventHandler("Utility:Logger", function(name)
    Log("Loaded", "Loaded the client API for the resource ["..name.."] [ID:"..source.."]")
end)

RegisterServerEvent("Utility:SelfBan")
AddEventHandler("Utility:SelfBan", function(reason)
    GetPlayer(source).Ban(reason)
end)

RegisterServerEvent("Utility:SwapModel")
AddEventHandler("Utility:SwapModel", function(coords, model, newmodel)
    TriggerClientEvent("Utility:SwapModel", -1, coords, model, newmodel)
end)

-- Explosion
if Config.Addons.DisableExplosion then
    AddEventHandler('explosionEvent', function(sender, ev)
        Log("Explosion", "Cancelled explosion created by ["..sender.."] "..json.encode(ev).."")
        CancelEvent()
    end)
end

-- Weapon
    RegisterServerEvent("Utility:Weapon:AddWeapon")
    AddEventHandler("Utility:Weapon:AddWeapon", function(identifier, weapon, ammo)
        if not ammo then
            ammo = 0
        end

        local player = Player(source).state
        local weapons = player.weapons

        weapon = CompressWeapon(weapon)
        weapons[weapon] = ammo

        player.weapons = weapons

        Utility.PlayersData[identifier].weapons[weapon] = ammo
        Utility.PlayersData[identifier].EmitEvent("WeaponAdded", weapon, ammo)
    end)
    RegisterServerEvent("Utility:Weapon:RemoveWeapon")
    AddEventHandler("Utility:Weapon:RemoveWeapon", function(identifier, weapon)
        local player = Player(source).state
        local weapons = player.weapons

        weapon = CompressWeapon(weapon)
        if weapons[weapon] then 
            weapons[weapon] = nil 
            Utility.PlayersData[identifier].weapons[weapon] = nil
        end

        player.weapons = weapons
        Utility.PlayersData[identifier].EmitEvent("WeaponRemoved", weapon)
    end)

    -- Ammo sync
    RegisterServerEvent("Utility:Weapon:SyncAmmo")
    AddEventHandler("Utility:Weapon:SyncAmmo", function(identifier, weapon, ammo)
        if not ammo then
            ammo = 0
        end

        local player = Player(source).state
        local weapons = player.weapons
        
        weapon = CompressWeapon(weapon)
        weapons[weapon] = ammo
        Utility.PlayersData[identifier].weapons[weapon] = ammo

        player.weapons = weapons
    end)

    RegisterServerEvent("Utility:GiveCarOnlyStaff")
    AddEventHandler("Utility:GiveCarOnlyStaff", function(target, components)
        local uPlayer = GetPlayer(source)
        local uTarget = GetPlayer(target)
    
        if uPlayer.group ~= "user" then
            uTarget.BuyVehicle(components)
        end
    end)