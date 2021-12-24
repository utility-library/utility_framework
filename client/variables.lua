Citizen.CreateThreadNow(function()
    TriggerServerEvent("Utility:Loaded")
    while LocalPlayer.state.steam == nil do
        print("Dont loaded uPlayer")
        Citizen.Wait(1)
    end
    print("Loaded uPlayer")
    
    uPlayer = LocalPlayer.state
end)


LocalPlayer.state.Labels = Config.Labels
LocalPlayer.state.DefaultLanguage = Config.DefaultLanguage