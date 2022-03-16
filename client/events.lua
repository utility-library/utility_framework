RegisterNetEvent("Utility:Notification")
AddEventHandler("Utility:Notification", function(msg)
    SetNotificationTextEntry('STRING')
    AddTextComponentSubstringPlayerName(msg)
    DrawNotification(false, true)
end)

RegisterNetEvent("Utility:ItemNotification")
AddEventHandler("Utility:ItemNotification", function(name, text)
    --print("Sending "..text)

    SendNUIMessage({
        item = true,
        name = name,
        changed = text
    })
end)

RegisterNetEvent("Utility:ButtonNotification")
AddEventHandler("Utility:ButtonNotification", function(msg, duration)
    for word in string.gmatch(msg, "{.*}") do msg = msg:gsub(word, Utility.Button[word]) end
    local time = GetGameTimer()

    while (GetGameTimer() - time) < duration do
        AddTextEntry('ButtonNotification', msg)
        BeginTextCommandDisplayHelp('ButtonNotification')
        EndTextCommandDisplayHelp(0, false, true, -1)
        Citizen.Wait(1)
    end
end)

RegisterNetEvent("Utility:SetClipboard")
AddEventHandler("Utility:SetClipboard", function(text)
    if type(text) == "string" then
        SendNUIMessage({
            clipboard = true,
            text = text 
        })
    end
end)

RegisterNetEvent("Utility:SwapModel")
AddEventHandler("Utility:SwapModel", function(coords, model, newmodel)
    --print("Swapping "..model.." to "..newmodel)
    CreateModelSwap(coords, 1.0, model, newmodel, true)
end)