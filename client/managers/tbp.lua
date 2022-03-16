local invoking = GetInvokingResource
local data, loaded = nil, {}
local pos = Config.TriggerBasicProtection.Pos
Config.TriggerBasicProtection.Pos = nil


Citizen.CreateThread(function()
    TriggerServerCallbackAsync("Utility:GetToken", function(steam, d)
        data = tostring(d):gsub('.', function(c) return c - pos end)

        if Config.Actived.Pvp then
            SetCanAttackFriendly(PlayerPedId(), true, false)
            NetworkSetFriendlyFireOption(true)
        end
        TriggerEvent("Utility:Logger", GetCurrentResourceName())
    end)
end)

local function ResourceExist(name)
    for i = 0, GetNumResources(), 1 do
        local res = GetResourceByFindIndex(i)
        if res and res == name then
            return true
        end
    end

    return false
end

RegisterNetEvent("Utility:RequestBasicData")
AddEventHandler("Utility:RequestBasicData", function(cb)
    local res = invoking()

    if res and not loaded[res] and ResourceExist(res) then
        loaded[res] = true

        while data == nil do
            Citizen.Wait(1)
        end

        local cdata = data:gsub(".", function(c) return math.floor(c + pos) end)
        cb(cdata)
        print("[DEBUG] [TBP] Sending token to "..res)
    else
        print("[DEBUG] [TBP] Resource "..res.." as already requested the token")
    end
end)
AddEventHandler("onResourceStop", function(res) if loaded then loaded[res] = nil end end)