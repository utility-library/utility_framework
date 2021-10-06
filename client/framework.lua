Utility = {
    PlayerData = nil,
    LabelsList = nil,
    Token = nil
}

TriggerServerCallbackAsync("Utility:GetTriggerKey", function(tk) Utility.Token = tk end)

--// Update Data
    RegisterNetEvent("Utility:UpdateClient")
    AddEventHandler("Utility:UpdateClient", function(type, data)
        Utility.PlayerData[type] = data
    end)

--// Basic PlayerData
    Citizen.CreateThread(function()
        --DoScreenFadeOut(300)
        Citizen.Wait(100)

        -- Get data from the server
        TriggerServerCallbackSync("Utility:GetPlayerData", function(PlayerData)
            if Config.Actived.Pvp then
                SetCanAttackFriendly(player, true, false)
                NetworkSetFriendlyFireOption(true)
            end

            Utility = {
                PlayerData      = uPlayerPopulate(PlayerData),
                Labels          = Config.Labels,
                DefaultLanguage = Config.DefaultLanguage,
                Token           = Utility.Token
            }

            Utility.PlayerData = uPlayerPopulate(PlayerData)

            -- PlayerLoaded trigger
            TriggerEvent("Utility:Loaded", PlayerData)
        end, GetCurrentResourceName())
    end)

    -- Send data to the loader
    RegisterNetEvent("Utility:LoadClient")
    AddEventHandler("Utility:LoadClient", function(name, cb)
        TriggerServerEvent("Utility:Logger", name)
        cb(Utility)
    end)

--// Other
    -- Wanted level
    SetMaxWantedLevel(0)
    SetPlayerWantedLevelNoDrop(PlayerId(), 0, false)

    -- Death
    RegisterNetEvent("Utility:Revive", function()
        local player = PlayerPedId()
        NetworkResurrectLocalPlayer(GetEntityCoords(player), GetEntityHeading(player), true, false)
        ClearPedBloodDamage(player)

        if Config.Actived.Other_info.Death then
            TriggerServerEvent("Utility:SetDeath", Utility.PlayerData.steam, false)
        end
    end)


    AddEventHandler('gameEventTriggered',function(name,data) 
        if name == "CEventNetworkEntityDamage" then
            data[1] = tonumber(data[1])  
            data[2] = tonumber(data[2])  

            if data[1] ~= nil and data[2] ~= nil then
                print("Damage "..json.encode(data))
                if data[1] == PlayerPedId() and GetEntityHealth(PlayerPedId()) == 0 then -- If is death
                    if data[2] == -1 then
                        if Config.Actived.Other_info.Death then
                            TriggerEvent("Utility:OnDeath", {killer = -1, cause = GetPedCauseOfDeath(PlayerPedId())})
                            TriggerServerEvent("Utility:SetDeath", Utility.PlayerData.steam, true)
                        end
                    else
                        if Config.Actived.No_Rp.KillDeath then
                            local killerPlayerIndex = NetworkGetPlayerIndexFromPed(data[2])

                            if NetworkIsPlayerActive(killerPlayerIndex) then 
                                TriggerServerEvent("Utility:SetDeath", Utility.PlayerData.steam, true, {
                                    killer = GetPlayerServerId(killerPlayerIndex), 
                                    victim = data[1]
                                })
                            else
                                TriggerServerEvent("Utility:SetDeath", Utility.PlayerData.steam, true, {
                                    killer = 0, 
                                    victim = data[1]
                                })
                            end
                        else
                            if Config.Actived.Other_info.Death then
                                TriggerEvent("Utility:OnDeath", {killer = NetworkGetPlayerIndexFromPed(data[2]), cause = GetPedCauseOfDeath(PlayerPedId())})
                                TriggerServerEvent("Utility:SetDeath", Utility.PlayerData.steam, true)
                            end
                        end
                    end
                end
            end
        end
    end)

    -- Salaries
    if Config.Actived.Salaries then
        RegisterNetEvent("Utility:Notification")
        AddEventHandler("Utility:Notification", function(msg)
            SetNotificationTextEntry('STRING')
            AddTextComponentSubstringPlayerName(msg)
            DrawNotification(false, true)
        end)
    end

    if Config.Actived.DisableVehicleRewards then
        Citizen.CreateThread(function()
            while true do
                DisablePlayerVehicleRewards(PlayerId())
                Citizen.Wait(5)
            end
        end)
    end

    if Config.Actived.NoWeaponDrop then
        Citizen.CreateThread(function()
            while true do
                local PedList = GetGamePool("CPed")
        
                for i=1, #PedList do
                    SetPedDropsWeaponsWhenDead(PedList[i], false)
                end
                Citizen.Wait(2000)
            end
        end)
    end

    RegisterCommand("ut_reloading", function()
        local PlayerPed = PlayerPedId()

        Citizen.Wait(500)
        if IsPedArmed(PlayerPed, 4) then
            if IsPedReloading(PlayerPed) then
                local weapon = GetSelectedPedWeapon(PlayerPed)
                local maxAmmo = GetAmmoInPedWeapon(PlayerPed, weapon)
                local weaponName

                for k,v in pairs(Utility.PlayerData.other_info.weapon) do
                    if weapon == GetHashKey(k) then
                        weaponName = k
                        break
                    end
                end

                if weaponName ~= nil then
                    --print("Syncing ammo "..weaponName, maxAmmo)
                    TriggerServerEvent("Utility:Weapon:SyncAmmo", Utility.PlayerData.steam, weaponName, maxAmmo)
                end
            end
        end
    end, true)
    RegisterKeyMapping("ut_reloading", "DONT CHANGE THIS KEY!", "keyboard", "r")