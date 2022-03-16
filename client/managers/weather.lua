if Config.Addons.Weather.active then
    RegisterNetEvent("Utility:Weather:SetWeather")
    AddEventHandler("Utility:Weather:SetWeather", function(NewWeather)
        print("Setting weather "..NewWeather)

        SetWeatherTypeOverTime(NewWeather, 15.0)
        Citizen.Wait(15100)
        
        uPlayer.weather = NewWeather
        SetWeatherTypePersist(NewWeather)
        SetWeatherTypeNow(NewWeather)
        SetWeatherTypeNowPersist(NewWeather)

        if NewWeather == 'XMAS' then
            SetForceVehicleTrails(true)
            SetForcePedFootstepsTracks(true)
        else
            SetForceVehicleTrails(false)
            SetForcePedFootstepsTracks(false)
        end
    end)

    RegisterNetEvent("Utility:Weather:SetTime")
    AddEventHandler("Utility:Weather:SetTime", function(_hour, _minute)
        hour, minute = _hour, _minute
        NetworkOverrideClockTime(hour, minute, 0)
    end)

    Citizen.CreateThread(function()
        hour, minute, weather = TriggerServerCallbackSync("Utility:GetTime")
        TriggerEvent("Utility:Weather:SetWeather", weather)

        while true do
            minute = minute + 1

            if minute >= 60 then
                hour = hour + 1
                minute = 0
            end

            if hour >= 24 then
                hour = 0
            end

            --print(hour..":"..minute)
            NetworkOverrideClockTime(hour, minute, 0)
            Citizen.Wait(2000)
        end
    end)
end