-- Client Logger
RegisterServerEvent("Utility:Logger")
AddEventHandler("Utility:Logger", function(name)
    Log("Loaded", "Loaded the client loader for the resource ["..name.."] [ID:"..source.."]")
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
    AddEventHandler("Utility:Weapon:AddWeapon", function(steam, weapon, ammo)
        if not ammo then
            ammo = 0
        end

        local player = Player(source).state
        local other_info = player.other_info
        if other_info.weapon == nil then other_info.weapon = {} end

        weapon = CompressWeapon(weapon)
        other_info.weapon[weapon] = ammo
        Utility.PlayersData[steam].other_info.weapon[weapon] = ammo

        player.other_info = other_info

        Utility.PlayersData[steam].TriggerEvent("Utility:Emitter:WeaponAdded", weapon, ammo)
    end)
    RegisterServerEvent("Utility:Weapon:RemoveWeapon")
    AddEventHandler("Utility:Weapon:RemoveWeapon", function(steam, weapon)
        local player = Player(source).state
        local other_info = player.other_info

        weapon = CompressWeapon(weapon)
        if other_info.weapon[weapon] then 
            other_info.weapon[weapon] = nil 
            Utility.PlayersData[steam].other_info.weapon[weapon] = nil
        end

        player.other_info = other_info
        Utility.PlayersData[steam].TriggerEvent("Utility:Emitter:WeaponRemoved", weapon)
    end)

    -- Ammo sync
    RegisterServerEvent("Utility:Weapon:SyncAmmo")
    AddEventHandler("Utility:Weapon:SyncAmmo", function(steam, weapon, ammo)
        if not ammo then
            ammo = 0
        end

        local player = Player(source).state
        local other_info = player.other_info
        
        weapon = CompressWeapon(weapon)
        other_info.weapon[weapon] = ammo
        Utility.PlayersData[steam].other_info.weapon[weapon] = ammo

        player.other_info = other_info
    end)