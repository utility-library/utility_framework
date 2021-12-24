-- Client Logger
RegisterServerEvent("Utility:Logger")
AddEventHandler("Utility:Logger", function(name)
    Log("Loaded", "Loaded the client loader for the resource ["..name.."] [ID:"..source.."]")
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
        local player = Player(source).state
        local other_info = player.other_info
        if other_info.weapon == nil then other_info.weapon = {} end

        other_info.weapon[weapon] = ammo

        player.other_info = other_info
    end)
    RegisterServerEvent("Utility:Weapon:RemoveWeapon")
    AddEventHandler("Utility:Weapon:RemoveWeapon", function(steam, weapon)
        local player = Player(source).state
        local other_info = player.other_info

        if other_info.weapon[weapon] then 
            other_info.weapon[weapon] = nil 
        end

        player.other_info = other_info
    end)

    -- Ammo sync
    RegisterServerEvent("Utility:Weapon:SyncAmmo")
    AddEventHandler("Utility:Weapon:SyncAmmo", function(steam, weapon, ammo)
        local player = Player(source).state
        local other_info = player.other_info
        
        other_info.weapon[weapon] = ammo
        player.other_info = other_info
    end)