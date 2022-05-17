Citizen.CreateThreadNow(function()
    TriggerServerEvent("Utility:Loaded")
    while LocalPlayer.state.identifier == nil do
        print("Dont loaded uPlayer", LocalPlayer.state.identifier)
        Citizen.Wait(1)
    end
    print("Loaded uPlayer")
    uPlayer = CreateMetaPlayer()

    LocalPlayer.state.loaded = true
end)


LocalPlayer.state.Labels = Config.Labels
LocalPlayer.state.DefaultLanguage = Config.DefaultLanguage
ut = exports["utility_framework"]