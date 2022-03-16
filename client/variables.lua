Citizen.CreateThreadNow(function()
    TriggerServerEvent("Utility:Loaded")
    while LocalPlayer.state.steam == nil do
        print("Dont loaded uPlayer")
        Citizen.Wait(1)
    end
    print("Loaded uPlayer")
    uPlayer = CreateMetaPlayer()

    LocalPlayer.state.loaded = true
end)


LocalPlayer.state.Labels = Config.Labels
LocalPlayer.state.DefaultLanguage = Config.DefaultLanguage
ut = exports["utility_framework"]