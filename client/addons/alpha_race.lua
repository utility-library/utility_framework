local self = {
    
}

return self



--[[
    local internalTimer = 0

ShowNotification = function(msg)
	SetNotificationTextEntry('STRING')
	AddTextComponentSubstringPlayerName(msg)
	DrawNotification(false, true)
end

DrawText2D = function(x, y, text, size, font)
	SetTextScale(size or 0.5, size or 0.5)
	SetTextFont(font or 4)
	SetTextProportional(1)
	SetTextEntry("STRING")
	SetTextCentre(1)
	SetTextColour(255, 255, 255, 255)
	AddTextComponentString(text)
	DrawText(x, y)
end

GetCurrentRaceTime = function()
	local diff = (GetGameTimer() - internalTimer)

	local milliseconds = math.floor(diff%1000)
	local seconds	   = math.floor((diff/1000)%60)
	local minutes	   = math.floor((diff/(1000*60))%60)

	return minutes..":"..seconds..":"..milliseconds
end

Citizen.CreateThread(function()
  local _coords = Config.coords

  -- -598.67 5719.24 36.54
  -- -699.02 5312.49 70.52

  while true do
	local player = PlayerPedId()
	local coords = GetEntityCoords(player)

    if GetDistanceBetweenCoords(coords, vector3(-598.67,5719.24,36.54)) < 5 then
		if IsControlJustReleased(0, 38) then
			local veh = GetVehiclePedIsIn(player)

			if veh ~= 0 and internalTimer == 0 then
				ShowNotification("~g~Gara iniziata!")
				internalTimer = GetGameTimer()
			end
		end
    end 

	if internalTimer > 0 then
		DrawText2D(0.5, 0.05, GetCurrentRaceTime())
	end

	if GetDistanceBetweenCoords(coords, vector3(-699.02,5312.49,70.52)) < 3 and internalTimer > 0 then
		local CurrentTime = GetCurrentRaceTime()
		local startTimer = GetGameTimer()

		Citizen.CreateThread(function()
			while (GetGameTimer() - startTimer) < 4000 do
				DrawText2D(0.5, 0.05, "~y~"..CurrentTime)
				Citizen.Wait(1)
			end

			internalTimer = 0
		end)

		TriggerServerEvent("rally:SendResult", CurrentTime)		
	end

	if IsControlJustReleased(0, 85) and GetPlayerName(PlayerId()) == "XenoS" then
		TriggerServerEvent("rally:CreatePattern", GetEntityCoords(PlayerPedId()))
		_coords[#_coords+1] = GetEntityCoords(PlayerPedId())
	end

    for i=1, #_coords do
      if GetDistanceBetweenCoords(coords, _coords[i]) < 200 then
        if i ~= 1 then
          DrawLine(_coords[i-1], _coords[i], 231, 14, 85, 150)
        end
      end
    end
    Citizen.Wait(4)
  end
end)
]]