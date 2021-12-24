Citizen.CreateThread(function()
    local Wait = nil
    local WaitMultiplier = 0

    if Config.Addons.Status.every:find("ms") then
        Wait = Config.Addons.Status.every:gsub("ms", "")
        Wait = tonumber(Wait)

        WaitMultiplier = 0
    elseif Config.Addons.Status.every:find("s") then
        Wait = Config.Addons.Status.every:gsub("s", "")
        Wait = tonumber(Wait)
        
        WaitMultiplier = 1000
    elseif Config.Addons.Status.every:find("m") then
        Wait = Config.Addons.Status.every:gsub("m", "")
        Wait = tonumber(Wait)

        WaitMultiplier = 60000
    end

    while true do
        TriggerServerEvent("Utility:Status:Update")
        Citizen.Wait(Wait * WaitMultiplier)
    end
end)

RegisterNetEvent("Utility:Status:RemoveHealth")
AddEventHandler("Utility:Status:RemoveHealth", function()
    local player = PlayerPedId()
    local currentHealth = GetEntityHealth(player)

    SetEntityHealth(player, currentHealth - 10.0)
end)