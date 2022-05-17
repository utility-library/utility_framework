RegisterNetEvent("Utility:Emitter:OnRevive", function()
    if GetInvokingResource() == nil then -- If is called from the server (yes the name of the resource is return ONLY if is called from the side where was created, isolated injector probably can trigger it anyway)
        local player = PlayerPedId()
        NetworkResurrectLocalPlayer(GetEntityCoords(player), GetEntityHeading(player), true, false)
        ClearPedBloodDamage(player)

        if Config.Actived.Addons.Death then
            TriggerServerEvent("Utility:SetDeath", false)
        end
    end
end)

AddEventHandler('gameEventTriggered',function(name,data) 
    if name == "CEventNetworkEntityDamage" then
        data[1] = tonumber(data[1])  
        data[2] = tonumber(data[2])  

        if data[1] ~= nil and data[2] ~= nil then
            --print("Damage "..json.encode(data))
            if data[1] == PlayerPedId() and GetEntityHealth(PlayerPedId()) == 0 then -- If is death
                if data[2] == -1 then
                    if Config.Actived.Addons.Death then
                        TriggerEvent("Utility:OnDeath", data)
                        TriggerServerEvent("Utility:SetDeath", true)
                    end
                else
                    if Config.Actived.No_Rp.KillDeath then
                        local killerPlayerIndex = NetworkGetPlayerIndexFromPed(data[2])

                        if NetworkIsPlayerActive(killerPlayerIndex) then 
                            TriggerServerEvent("Utility:SetDeath", true, {
                                killer = GetPlayerServerId(killerPlayerIndex), 
                                victim = data[1]
                            })
                        else
                            TriggerServerEvent("Utility:SetDeath", true, {
                                killer = 0, 
                                victim = data[1]
                            })
                        end
                    else
                        if Config.Actived.Addons.Death then
                            TriggerEvent("Utility:OnDeath", {killer = NetworkGetPlayerIndexFromPed(data[2]), cause = GetPedCauseOfDeath(PlayerPedId())})
                            TriggerServerEvent("Utility:SetDeath", true)
                        end
                    end
                end
            end
        end
    end
end)