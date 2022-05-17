if Config.Addons.Weather.active then
    local CurrentWeather = "EXTRASUNNY"
    local hour, minute = math.floor(math.random(12, 21)), math.floor(math.random(1, 50))

    function NextWeatherStage()
        if CurrentWeather == "EXTRASUNNY" then
            local new = math.random(1, 10)
    
            if new <= 3 then
                CurrentWeather = "OVERCAST" -- 4/10
            else
                CurrentWeather = "EXTRASUNNY" -- 7/10
            end
        elseif CurrentWeather == "OVERCAST" then
            local new = math.random(1, 10)
    
            if new <= 5 then
                CurrentWeather = "RAIN" -- 6/10
            else
                CurrentWeather = "OVERCAST" -- 4/10
            end
        elseif CurrentWeather == "RAIN" then
            local new = math.random(1, 11)
    
            if new <= 7 then
                CurrentWeather = "CLEARING" -- 7/10
            elseif new == 8 then
                CurrentWeather = "THUNDER" -- 1/10
            elseif new == 9 then
                CurrentWeather = "OVERCAST" -- 1/10
            else
                CurrentWeather = "RAIN" -- 2/10
            end
        elseif CurrentWeather == "THUNDER" then
            local new = math.random(1, 10)
    
            if new <= 7 then
                CurrentWeather = "CLEARING" -- 7/10
            else
                CurrentWeather = "OVERCAST" -- 3/10
            end
        elseif CurrentWeather == "CLEARING" then
            CurrentWeather = "CLOUDS" -- 10/10
        elseif CurrentWeather == "CLOUDS" then
            local new = math.random(1, 10)
    
            if new <= 3 then
                CurrentWeather = "OVERCAST" -- 3/10
            else
                CurrentWeather = "EXTRASUNNY" -- 7/10
            end
        else
            CurrentWeather = "EXTRASUNNY"
        end
    end

    -- Time
    Citizen.CreateThread(function()
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
            Citizen.Wait(2000)
        end
    end)

    -- Weather
    Citizen.CreateThread(function()
        while true do
            Citizen.Wait(10 * 60000)
            --print("Old weather "..CurrentWeather)
            NextWeatherStage()
            --print("New weather "..CurrentWeather)
            TriggerClientEvent("Utility:Weather:SetWeather", -1, CurrentWeather)
        end
    end)

    RegisterServerCallback("Utility:GetTime", function()
        return hour, minute, CurrentWeather
    end)

    RegisterCommand("time", function(source, args)
        hour, minute = tonumber(args[1]), tonumber(args[2])
        TriggerClientEvent("Utility:Weather:SetTime", -1, tonumber(args[1]), tonumber(args[2]))
    end)
    RegisterCommand("weather", function(source, args)
        CurrentWeather = args[1]:upper()
        TriggerClientEvent("Utility:Weather:SetWeather", -1, args[1]:upper())

        print("Setted weahter "..CurrentWeather)
    end)
end