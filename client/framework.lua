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
                        TriggerServerEvent("Utility:SetDeath", Utility.PlayerData.steam, true)
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
                            TriggerServerEvent("Utility:SetDeath", Utility.PlayerData.steam, true)
                        end
                    end
                end
            end
        end
    end)

    --[[if Config.Actived.Other_info.Death then
        AddEventHandler("Utility:PlayerLoaded", function()
            while true do
                local source = GetPlayerServerId(PlayerId())

                if IsEntityDead(PlayerPedId()) and not Utility.PlayerData.death then
                    TriggerEvent("Utility:OnDeath", GetPedSourceOfDeath(PlayerPedId()))
                    TriggerServerEvent("Utility:SetDeath", Utility.PlayerData.steam, true)
                end
                Citizen.Wait(1000)
            end
        end)
    end]]

    -- Salaries
    if Config.Actived.Salaries then
        RegisterNetEvent("Utility:Notification")
        AddEventHandler("Utility:Notification", function(msg)
            SetNotificationTextEntry('STRING')
            AddTextComponentSubstringPlayerName(msg)
            DrawNotification(false, true)
        end)
    end

    if Config.Actived.NoWeaponDrop then
        Citizen.CreateThread(function()
            while true do
                DisablePlayerVehicleRewards(PlayerId())
                Citizen.Wait(5)
            end
        end)
        
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

    Citizen.CreateThread(function()
        Citizen.Wait(500)

        local PlayerPed = PlayerPedId()
        local ammo = 0

        while true do
            if IsPedArmed(PlayerPed, 4) then
                if IsPedReloading(PlayerPed) then
                    local weapon = GetSelectedPedWeapon(PlayerPed)
                    local maxAmmo = GetAmmoInPedWeapon(PlayerPed, weapon)
                    local weaponName

                    if ammo ~= maxAmmo then
                        ammo = maxAmmo

                        for k,v in pairs(Utility.PlayerData.other_info.weapon) do
                            if weapon == GetHashKey(k) then
                                weaponName = k
                                break
                            end
                        end

                        if weaponName ~= nil then
                            TriggerServerEvent("Utility:Weapon:SyncAmmo", Utility.PlayerData.steam, weaponName, maxAmmo)
                        end
                    end
                end
            else
                Citizen.Wait(500)
            end
            Citizen.Wait(100)
        end
    end)