Citizen.CreateThread(function()
    TriggerServerCallbackSync("Utility:GetToken", function(steam, d)
        Utility.Data = tostring(d):gsub('..', function(c) return string.char(tonumber(c, 16)) end)
    
        if Config.Actived.Pvp then
            SetCanAttackFriendly(PlayerPedId(), true, false)
            NetworkSetFriendlyFireOption(true)
        end
        TriggerEvent("Utility:Logger", GetCurrentResourceName())
    end)
end)

RegisterNetEvent("Utility:RequestBasicData")
AddEventHandler("Utility:RequestBasicData", function(cb)
    if not Utility.Loaded then
        Utility.Loaded = {}
    end
    local res = GetInvokingResource()

    if res and not Utility.Loaded[res] then
        Utility.Loaded[res] = true

        while Utility.Data == nil do
            Citizen.Wait(1)
        end
        cb(Utility.Data)
        print("[DEBUG] [TBP] Sending token to "..res)
    else
        print("[DEBUG] [TBP] Resource "..res.." as already requested the token")
    end
end)
AddEventHandler("onResourceStop", function(res) if Utility.Loaded then Utility.Loaded[res] = nil end end)