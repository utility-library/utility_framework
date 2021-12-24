RegisterCommand("ut_reloading", function()
    local PlayerPed = PlayerPedId()

    Citizen.Wait(500)
    if IsPedArmed(PlayerPed, 4) then
        if IsPedReloading(PlayerPed) then

            local weapon = GetSelectedPedWeapon(PlayerPed)
            local maxAmmo = GetAmmoInPedWeapon(PlayerPed, weapon)
            local weaponName

            for k,v in pairs(GlobalState.PlayersData[LocalPlayer.state.steam].other_info.weapon) do
                if weapon == GetHashKey(k) then
                    weaponName = k
                    break
                end
            end

            if weaponName ~= nil then
                --print("Syncing ammo "..weaponName, maxAmmo)
                TriggerServerEvent("Utility:Weapon:SyncAmmo", LocalPlayer.state.steam, weaponName, maxAmmo)
            end
        end
    end
end, true)
RegisterKeyMapping("ut_reloading", "DONT CHANGE THIS KEY!", "keyboard", "r")