addon = function(name)
    local module = LoadResourceFile("utility_framework", "client/addons/"..name..".lua")
    
    if module then
        return load(module)()
    else
        error("Addon \""..name.."\" dont exist")
    end
end

GetVehicleComponents = function(vehicleHandle)
    local colorPrimary, colorSecondary = GetVehicleColours(vehicleHandle)
    local pearlescentColor, wheelColor = GetVehicleExtraColours(vehicleHandle)
    local extras = {}
    local mods = {}

    -- Extra
    for i=0, 12 do
        if DoesExtraExist(vehicleHandle, i) then
            local active = IsVehicleExtraTurnedOn(vehicleHandle, i) == 1

            if active then
                table.insert(extras, tonumber(i))
            end
        end
    end

    -- Mods
    for i=0, 49 do
        table.insert(mods, GetVehicleMod(vehicleHandle, i))
    end

    mods[19] = IsToggleModOn(vehicleHandle, 18)
    mods[21] = IsToggleModOn(vehicleHandle, 20)
    mods[23] = IsToggleModOn(vehicleHandle, 22)

    mods[50] = GetVehicleModVariation(vehicleHandle, 23)

    -- Basic function to round the number
    local function round(value, dec) local power = 10^dec return math.floor((value * power) + 0.5) / (power) end
    local function pack(...) local a = {...} return a end

    return {
        model             = GetEntityModel(vehicleHandle),
        class             = GetVehicleClass(vehicleHandle),
        plate             = {
            GetVehicleNumberPlateText(vehicleHandle), 
            GetVehicleNumberPlateTextIndex(vehicleHandle)
        },
        health            = {
            round(GetVehicleBodyHealth(vehicleHandle), 1),
            round(GetVehicleEngineHealth(vehicleHandle), 1),
            round(GetVehiclePetrolTankHealth(vehicleHandle), 1),
        },

        fuel              = round(GetVehicleFuelLevel(vehicleHandle), 1),
        color             = {colorPrimary,colorSecondary, pearlescentColor, wheelColor, pack(GetVehicleTyreSmokeColor(vehicleHandle))},

        wheels            = GetVehicleWheelType(vehicleHandle),
        windowTint        = GetVehicleWindowTint(vehicleHandle),
        
        neon = {
            GetVehicleXenonLightsColour(vehicleHandle),
            IsVehicleNeonLightEnabled(vehicleHandle, 0),
            IsVehicleNeonLightEnabled(vehicleHandle, 1),
            IsVehicleNeonLightEnabled(vehicleHandle, 2),
            IsVehicleNeonLightEnabled(vehicleHandle, 3),
            pack(GetVehicleNeonLightsColour(vehicleHandle))
        },

        extras            = extras,
        mods = mods,
        livery = GetVehicleLivery(vehicleHandle)
    }
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

CompressWeapon = function(name)
    name = name:gsub("weapon_", "w")
    
    return name:lower()
end

DecompressWeapon = function(name)
    if name:sub(1, 1) == "w" then
        name = name:gsub("w"..name:sub(2, 2), "weapon_"..name:sub(2, 2))
    end
    
    return name:lower()
end

exports("CompressWeapon", CompressWeapon)
exports("DecompressWeapon", DecompressWeapon)



-- Builders
CreateMetaPlayer = function()
    return setmetatable({}, {
        __index = function(_, k)
            --print(k, LocalPlayer.state[k])
            if k == "vehicle" or k == "veh" then
                return GetVehiclePedIsIn(uPlayer.ped)
            elseif k == "coords" then
                if GetCurrentResourceName() == "utility_framework" then
                    return LocalPlayer.state.coords
                else
                    return GetEntityCoords(uPlayer.ped)
                end
            elseif k == "heading" then
                return GetEntityHeading(uPlayer.ped)
            elseif k == "weapon" then
                return GetSelectedPedWeapon(uPlayer.ped)
            elseif k == "armed" then
                return IsPedArmed(uPlayer.ped, 4)
            elseif k == "weaponModel" then
                return GetCurrentPedWeaponEntityIndex(uPlayer.ped)
            elseif k == "id" then
                return id
            elseif k == "ped" then
                if DoesEntityExist(LocalPlayer.state[k]) then
                    return LocalPlayer.state[k]
                else
                    local ped = PlayerPedId()
                    LocalPlayer.state[k] = ped
                    
                    return ped
                end
            elseif type(LocalPlayer.state[k]) == "string" and LocalPlayer.state[k]:find("call") then
                return function(...)
                    local v = LocalPlayer.state[k]
                    v = v:gsub("call:", "")
                    
                    local resource, name = v:match("(.+):(.+)")

                    return exports[resource][name](nil, ...)
                end
            else
                return LocalPlayer.state[k]
            end
        end,
        __newindex = function(_, k, v)
            if type(v) == "function" then
                exports(k, v) -- Create the exports
                LocalPlayer.state[k] = "call:"..ResourceName..":"..k

                --print("State = "..LocalPlayer.state[k])
                -- Assign to the state "call:resource_name:function_name"
            else
                LocalPlayer.state[k] = v
            end
        end,
        __len = function(_) -- Id is gettable also with #uPlayer
            return id
        end
    })
end

exports("CreateMetaPlayer", CreateMetaPlayer)

CheckFilter = function(data, filter)
    local filterkeys = 0
    local foundkeys = 0
    
    for k,v in pairs(filter) do
        filterkeys = filterkeys + 1
        
        if data[k] == v then
            foundkeys = foundkeys + 1
        end
    end
    
    if filterkeys == foundkeys then
        return true
    else
        return false
    end
end

FindItem = function(name, inv, data)
    for i=1, #inv do
        if inv[i][1] == name then
            if data then
                if inv[i][3] and CheckFilter(inv[i][3], data) then
                    return inv[i], i
                end
            else
                return inv[i], i
            end
        end
    end

    return false
end


GetItemInternal = function(name, data, inv)
    local item = FindItem(name, inv, data)
    return {
        quantity = item[2] or 0, 
        label = Config.Labels["items"][name] or name, 
        [Config.Inventory.Type] = Config.Inventory.ItemWeight[name] or Config.Inventory.DefaultItemWeight, 
        data = item[3] or {}, 
        __type = "item",

        found = item ~= false
    }
end

GetSkinLabel = function(key)
    return Config.Labels["skin"][key] or nil
end

GetSkinMaxVals = function()
    local playerPed = PlayerPedId()

    local data = {
        face			= 45,
        skin			= 45,
        age_1			= GetNumHeadOverlayValues(3)-1,
        age_2			= 10,
        beard_1			= GetNumHeadOverlayValues(1)-1,
        beard_2			= 10,
        beard_3			= GetNumHairColors()-1,
        beard_4			= GetNumHairColors()-1,
        hair_1			= GetNumberOfPedDrawableVariations		(playerPed, 2) - 1,
        hair_2			= GetNumberOfPedTextureVariations		(playerPed, 2, Clothes['hair_1']) - 1,
        hair_color_1	= GetNumHairColors()-1,
        hair_color_2	= GetNumHairColors()-1,
        eye_color		= 31,
        eyebrows_1		= GetNumHeadOverlayValues(2)-1,
        eyebrows_2		= 10,
        eyebrows_3		= GetNumHairColors()-1,
        eyebrows_4		= GetNumHairColors()-1,
        makeup_1		= GetNumHeadOverlayValues(4)-1,
        makeup_2		= 10,
        makeup_3		= GetNumHairColors()-1,
        makeup_4		= GetNumHairColors()-1,
        lipstick_1		= GetNumHeadOverlayValues(8)-1,
        lipstick_2		= 10,
        lipstick_3		= GetNumHairColors()-1,
        lipstick_4		= GetNumHairColors()-1,
        blemishes_1		= GetNumHeadOverlayValues(0)-1,
        blemishes_2		= 10,
        blush_1			= GetNumHeadOverlayValues(5)-1,
        blush_2			= 10,
        blush_3			= GetNumHairColors()-1,
        complexion_1	= GetNumHeadOverlayValues(6)-1,
        complexion_2	= 10,
        sun_1			= GetNumHeadOverlayValues(7)-1,
        sun_2			= 10,
        moles_1			= GetNumHeadOverlayValues(9)-1,
        moles_2			= 10,
        chest_1			= GetNumHeadOverlayValues(10)-1,
        chest_2			= 10,
        bodyb_1			= GetNumHeadOverlayValues(11)-1,
        bodyb_2			= 10,
        ears_1			= GetNumberOfPedPropDrawableVariations	(playerPed, 1) - 1,
        ears_2			= GetNumberOfPedPropTextureVariations	(playerPed, 1, Clothes['ears_1'] - 1),
        tshirt_1		= GetNumberOfPedDrawableVariations		(playerPed, 8) - 1,
        tshirt_2		= GetNumberOfPedTextureVariations		(playerPed, 8, Clothes['tshirt_1']) - 1,
        torso_1			= GetNumberOfPedDrawableVariations		(playerPed, 11) - 1,
        torso_2			= GetNumberOfPedTextureVariations		(playerPed, 11, Clothes['torso_1']) - 1,
        decals_1		= GetNumberOfPedDrawableVariations		(playerPed, 10) - 1,
        decals_2		= GetNumberOfPedTextureVariations		(playerPed, 10, Clothes['decals_1']) - 1,
        arms			= GetNumberOfPedDrawableVariations		(playerPed, 3) - 1,
        arms_2			= 10,
        pants_1			= GetNumberOfPedDrawableVariations		(playerPed, 4) - 1,
        pants_2			= GetNumberOfPedTextureVariations		(playerPed, 4, Clothes['pants_1']) - 1,
        shoes_1			= GetNumberOfPedDrawableVariations		(playerPed, 6) - 1,
        shoes_2			= GetNumberOfPedTextureVariations		(playerPed, 6, Clothes['shoes_1']) - 1,
        mask_1			= GetNumberOfPedDrawableVariations		(playerPed, 1) - 1,
        mask_2			= GetNumberOfPedTextureVariations		(playerPed, 1, Clothes['mask_1']) - 1,
        bproof_1		= GetNumberOfPedDrawableVariations		(playerPed, 9) - 1,
        bproof_2		= GetNumberOfPedTextureVariations		(playerPed, 9, Clothes['bproof_1']) - 1,
        chain_1			= GetNumberOfPedDrawableVariations		(playerPed, 7) - 1,
        chain_2			= GetNumberOfPedTextureVariations		(playerPed, 7, Clothes['chain_1']) - 1,
        bags_1			= GetNumberOfPedDrawableVariations		(playerPed, 5) - 1,
        bags_2			= GetNumberOfPedTextureVariations		(playerPed, 5, Clothes['bags_1']) - 1,
        helmet_1		= GetNumberOfPedPropDrawableVariations	(playerPed, 0) - 1,
        helmet_2		= GetNumberOfPedPropTextureVariations	(playerPed, 0, Clothes['helmet_1']) - 1,
        glasses_1		= GetNumberOfPedPropDrawableVariations	(playerPed, 1) - 1,
        glasses_2		= GetNumberOfPedPropTextureVariations	(playerPed, 1, Clothes['glasses_1'] - 1),
        watches_1		= GetNumberOfPedPropDrawableVariations	(playerPed, 6) - 1,
        watches_2		= GetNumberOfPedPropTextureVariations	(playerPed, 6, Clothes['watches_1']) - 1,
        bracelets_1		= GetNumberOfPedPropDrawableVariations	(playerPed, 7) - 1,
        bracelets_2		= GetNumberOfPedPropTextureVariations	(playerPed, 7, Clothes['bracelets_1'] - 1)
    }

    return data
end

ConvertKvp = function(string)
    local string = GetResourceKvpString(string)

    if not (string == "null" or string == nil) then
        string = json.decode(string)
    end

    return string or {}
end

EmitEvent = function(name, ...)
    TriggerClientEvent("Utility:Emitter:"..name, source, ...)
    TriggerEvent("Utility:Emitter:"..name, source, ...)
end

local server_identifier = LoadResourceFile("utility_framework", "files/server-identifier.utility") 
GetServerIdentifier = function()
    return server_identifier
end

exports("GetServerIdentifier", GetServerIdentifier)