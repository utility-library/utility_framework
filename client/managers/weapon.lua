local last = {
    ammo = 0
}

Citizen.CreateThread(function()
    while true do
        local PlayerPed = PlayerPedId()
        
        if IsPedArmed(PlayerPed, 4) then
            local weapon = GetSelectedPedWeapon(PlayerPed)

            if IsPedReloading(PlayerPed) or GetAmmoInPedWeapon(PlayerPed, weapon) == 0 then
                local maxAmmo = GetAmmoInPedWeapon(PlayerPed, weapon)
                local weaponName
    
                for k,v in pairs(LocalPlayer.state.other_info.weapon) do
                    if weapon == GetHashKey(UncompressWeapon(k)) then
                        weaponName = k
                        break
                    end
                end
    
                if weaponName ~= nil then
                    if last.ammo ~= maxAmmo then
                        last.ammo = maxAmmo

                        print("Syncing ammo "..weaponName, maxAmmo)
                        TriggerServerEvent("Utility:Weapon:SyncAmmo", LocalPlayer.state.steam, weaponName, maxAmmo)
                    end
                end
            end
        end
    
        Citizen.Wait(500)
    end
end)