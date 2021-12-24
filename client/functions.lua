addon = function(name)
    local module = LoadResourceFile("utility_framework", "client/addons/"..name..".lua")
    
    if module then
        return load(module)()
    else
        error("Addon \""..name.."\" dont exist")
    end
end

SetVehicleComponents = function(vehicleHandle, component)
    if type(component.plate) == "table" then
        SetVehicleNumberPlateText(vehicleHandle, component.plate[1])
        SetVehicleNumberPlateTextIndex(vehicleHandle, component.plate[2])
    end

    if type(component.health) == "table" then
        SetVehicleBodyHealth(vehicleHandle, component.health[1])
        SetVehicleEngineHealth(vehicleHandle, component.health[2])
        SetVehiclePetrolTankHealth(vehicleHandle, component.health[3])
    end

    if component.fuel then SetVehicleFuelLevel(vehicleHandle, component.fuel) end
    if component.color then 
        SetVehicleColours(vehicleHandle, component.color[1], component.color[2]) 
        SetVehicleExtraColours(vehicleHandle, component.color[3], component.color[4])

        SetVehicleTyreSmokeColor(vehicleHandle, component.color[5][1], component.color[5][2], component.color[5][3])
    end

    if component.wheels then SetVehicleWheelType(vehicleHandle, component.wheels) end
    if component.windowTint then SetVehicleWindowTint(vehicleHandle, component.windowTint) end
    if component.neon then 
        SetVehicleXenonLightsColor(vehicleHandle, component.neon[1])

        SetVehicleNeonLightEnabled(vehicleHandle, 0, component.neon[2])
        SetVehicleNeonLightEnabled(vehicleHandle, 1, component.neon[3])
        SetVehicleNeonLightEnabled(vehicleHandle, 2, component.neon[4])
        SetVehicleNeonLightEnabled(vehicleHandle, 3, component.neon[5])
        SetVehicleNeonLightsColour(vehicleHandle, component.neon[6][1], component.neon[6][2], component.neon[6][3])
    end

    if component.extras then
        for i=1, #component.extras do
            SetVehicleExtra(vehicleHandle, tonumber(component.extras[i]), 1)
        end
    end

    if component.mods then
        for i=1, #component.mods do
            if i < 19 then
                SetVehicleMod(vehicleHandle, i, component.mods[i], false)
            elseif i > 21 then
                SetVehicleMod(vehicleHandle, i, component.mods[i], false)
            end
        end

        ToggleVehicleMod(vehicleHandle, 18, component.mods[19])
        ToggleVehicleMod(vehicleHandle, 20, component.mods[20])
        ToggleVehicleMod(vehicleHandle, 22, component.mods[21])
    end

    if component.livery then
        SetVehicleLivery(vehicleHandle, component.livery)
    end
end