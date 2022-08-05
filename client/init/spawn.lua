local kvp = Config.GlobalSkin and "utility_skin" or "utility_skin:"..GetServerIdentifier()

Clothes = ConvertKvp(kvp)

Components = {
    {label = GetSkinLabel("face"), name = "face", value = 0, min = 0},
    {label = GetSkinLabel("skin"), name = "skin", value = 0, min = 0},
    {label = GetSkinLabel("hair_1"), name = "hair_1", value = 0, min = 0},
    {label = GetSkinLabel("hair_2"), name = "hair_2", value = 0, min = 0},
    {label = GetSkinLabel("hair_color_1"), name = "hair_color_1", value = 0, min = 0},
    {label = GetSkinLabel("hair_color_2"), name = "hair_color_2", value = 0, min = 0},
    {label = GetSkinLabel("tshirt_1"), name = "tshirt_1", value = 0, min = 0},
    {label = GetSkinLabel("tshirt_2"), name = "tshirt_2", value = 0, min = 0},
    {label = GetSkinLabel("torso_1"), name = "torso_1", value = 0, min = 0},
    {label = GetSkinLabel("torso_2"), name = "torso_2", value = 0, min = 0},
    {label = GetSkinLabel("decals_1"), name = "decals_1", value = 0, min = 0},
    {label = GetSkinLabel("decals_2"), name = "decals_2", value = 0, min = 0},
    {label = GetSkinLabel("arms"), name = "arms", value = 0, min = 0},
    {label = GetSkinLabel("arms_2"), name = "arms_2", value = 0, min = 0},
    {label = GetSkinLabel("pants_1"), name = "pants_1", value = 0, min = 0},
    {label = GetSkinLabel("pants_2"), name = "pants_2", value = 0, min = 0},
    {label = GetSkinLabel("shoes_1"), name = "shoes_1", value = 0, min = 0},
    {label = GetSkinLabel("shoes_2"), name = "shoes_2", value = 0, min = 0},
    {label = GetSkinLabel("mask_1"), name = "mask_1", value = 0, min = 0},
    {label = GetSkinLabel("mask_2"), name = "mask_2", value = 0, min = 0},
    {label = GetSkinLabel("bproof_1"), name = "bproof_1", value = 0, min = 0},
    {label = GetSkinLabel("bproof_2"), name = "bproof_2", value = 0, min = 0},
    {label = GetSkinLabel("chain_1"), name = "chain_1", value = 0, min = 0},
    {label = GetSkinLabel("chain_2"), name = "chain_2", value = 0, min = 0},
    {label = GetSkinLabel("helmet_1"), name = "helmet_1", value = -1, min = -1},
    {label = GetSkinLabel("helmet_2"), name = "helmet_2", value = 0, min = 0},
    {label = GetSkinLabel("glasses_1"), name = "glasses_1", value = 0, min = 0},
    {label = GetSkinLabel("glasses_2"), name = "glasses_2", value = 0, min = 0},
    {label = GetSkinLabel("watches_1"), name = "watches_1", value = -1, min = -1},
    {label = GetSkinLabel("watches_2"), name = "watches_2", value = 0, min = 0},
    {label = GetSkinLabel("bracelets_1"), name = "bracelets_1", value = -1, min = -1},
    {label = GetSkinLabel("bracelets_2"), name = "bracelets_2", value = 0, min = 0},
    {label = GetSkinLabel("bag"), name = "bags_1", value = 0, min = 0},
    {label = GetSkinLabel("bag_color"), name = "bags_2", value = 0, min = 0},
    {label = GetSkinLabel("eye_color"), name = "eye_color", value = 0, min = 0},
    {label = GetSkinLabel("eyebrow_size"), name = "eyebrows_2", value = 0, min = 0},
    {label = GetSkinLabel("eyebrow_type"), name = "eyebrows_1", value = 0, min = 0},
    {label = GetSkinLabel("eyebrow_color_1"), name = "eyebrows_3", value = 0, min = 0},
    {label = GetSkinLabel("eyebrow_color_2"), name = "eyebrows_4", value = 0, min = 0},
    {label = GetSkinLabel("makeup_type"), name = "makeup_1", value = 0, min = 0},
    {label = GetSkinLabel("makeup_thickness"), name = "makeup_2", value = 0, min = 0},
    {label = GetSkinLabel("makeup_color_1"), name = "makeup_3", value = 0, min = 0},
    {label = GetSkinLabel("makeup_color_2"), name = "makeup_4", value = 0, min = 0},
    {label = GetSkinLabel("lipstick_type"), name = "lipstick_1", value = 0, min = 0},
    {label = GetSkinLabel("lipstick_thickness"), name = "lipstick_2", value = 0, min = 0},
    {label = GetSkinLabel("lipstick_color_1"), name = "lipstick_3", value = 0, min = 0},
    {label = GetSkinLabel("lipstick_color_2"), name = "lipstick_4", value = 0, min = 0},
    {label = GetSkinLabel("ear_accessories"), name = "ears_1", value = -1, min = -1},
    {label = GetSkinLabel("ear_accessories_color"), name = "ears_2", value = 0, min = 0},
    {label = GetSkinLabel("chest_hair"), name = "chest_1", value = 0, min = 0},
    {label = GetSkinLabel("chest_hair_1"), name = "chest_2", value = 0, min = 0},
    {label = GetSkinLabel("wrinkles"), name = "age_1", value = 0, min = 0},
    {label = GetSkinLabel("wrinkle_thickness"), name = "age_2", value = 0, min = 0},
    {label = GetSkinLabel("blemishes"), name = "blemishes_1", value = 0, min = 0},
    {label = GetSkinLabel("blemishes_size"), name = "blemishes_2", value = 0, min = 0},
    {label = GetSkinLabel("blush"), name = "blush_1", value = 0, min = 0},
    {label = GetSkinLabel("blush_1"), name = "blush_2", value = 0, min = 0},
    {label = GetSkinLabel("blush_color"), name = "blush_3", value = 0, min = 0},
    {label = GetSkinLabel("complexion"), name = "complexion_1", value = 0, min = 0},
    {label = GetSkinLabel("complexion_1"), name = "complexion_2", value = 0, min = 0},
    {label = GetSkinLabel("sun"), name = "sun_1", value = 0, min = 0},
    {label = GetSkinLabel("sun_1"), name = "sun_2", value = 0, min = 0},
    {label = GetSkinLabel("freckles"), name = "moles_1", value = 0, min = 0},
    {label = GetSkinLabel("freckles_1"), name = "moles_2", value = 0, min = 0},
    {label = GetSkinLabel("beard_type"), name = "beard_1", value = 0, min = 0},
    {label = GetSkinLabel("beard_size"), name = "beard_2", value = 0, min = 0},
    {label = GetSkinLabel("beard_color_1"), name = "beard_3", value = 0, min = 0},
    {label = GetSkinLabel("beard_color_2"), name = "beard_4", value = 0, min = 0}
}
local HeadOverlay = {
    [1]  = {"blemishes_1", "blemishes_2"},
    [2]  = {"beard_1", "beard_2"},
    [3]  = {"eyebrows_1", "eyebrows_2"},
    [4]  = {"age_1", "age_2"},
    [5]  = {"makeup_1", "makeup_2"},
    [6]  = {"blush_1", "blush_1"},
    [7]  = {"complexion_1", "complexion_2"},
    [8]  = {"sun_1", "sun_2"},
    [9]  = {"lipstick_1", "lipstick_1"},
    [10] = {"moles_1", "moles_1"},
    [11] = {"chest_1", "chest_2"},
    [12] = {"bodyb_1", "bodyb_2"},
}
local ComponentVariation = {
    [1]  = {"mask_1", "mask_2"},
    [2]  = {"hair_1", "hair_2"},
    [3]  = {"arms", "arms_2"},
    [4]  = {"pants_1", "pants_2"},
    [5]  = {"bags_1", "bags_2"},
    [6]  = {"shoes_1", "shoes_2"},
    [7]  = {"chain_1", "chain_2"},
    [8]  = {"tshirt_1", "tshirt_2"},
    [9]  = {"bproof_1", "bproof_2"},
    [10] = {"decals_1", "decals_2"},
    [11] = {"torso_1", "torso_2"},
}

-- If the player dont have a Clothes, then create it
if Clothes == nil or next(Clothes) == nil then
    for i=1, #Components do
        Clothes[Components[i].name] = Components[i].value
    end

    SetResourceKvp(kvp, json.encode(Clothes))
end

-- Function
function SetSkin(ped, k, v, temp)
    SetSkinPedProp = function(base, id)
        if k == base..'_1' then
            if v == -1 then
                ClearPedProp(ped, id) 
            else 
                SetPedPropIndex(ped, id, v, Clothes[base..'_2'], 2)
            end
        elseif k == base.."_2" then
            SetPedPropIndex(ped, id, Clothes[base..'_1'], v, 2)
        end
    end
    
    SetSkinPedHeadOverlay = function(base, id)
        if k == base.."_3" then 
            SetPedHeadOverlayColor(ped, id, 1, v, Clothes[base..'_4'])
        elseif k == base.."_4" then 
            SetPedHeadOverlayColor(ped, id, 1, Clothes[base..'_3'], v)
        end
    end
    
    SetSkinMultiComponent = function(table)
        for i=1, #table do
            local overlayId = i
            local drawable = table[i][1]
            local second = table[i][2]
    
            if k == drawable then
                print("Setting "..overlayId, v, Clothes[second])

                -- Update only the drawable (but keep the second)
                if table == HeadOverlay then
                    SetPedHeadOverlay(ped, overlayId, v, Clothes[second]/10 + 0.0)
                else
                    SetPedComponentVariation(ped, overlayId, v, Clothes[second], 0)
                end
            elseif k == second then
                -- Update only the second (but keep the drawable)
                if table == HeadOverlay then
                    SetPedHeadOverlay(ped, overlayId, Clothes[drawable], v + 0.0)
                else
                    SetPedComponentVariation(ped, overlayId, Clothes[drawable], v, 0)
                end
            end
        end
    end

    if k == "face" then
        SetPedHeadBlendData(ped, v, v, v, Clothes["skin"], Clothes["skin"], Clothes["skin"], 1.0, 1.0, 1.0, true)
    elseif k == "hair_color_1" then 
        SetPedHairColor(ped, v, Clothes['hair_color_2'])
    elseif k == "hair_color_2" then 
        SetPedHairColor(ped, Clothes['hair_color_1'], v)
    elseif k == "eye_color" then
        SetPedEyeColor(ped, v, 0, 1)
    elseif k == "blush_3" then 
        SetPedHeadOverlayColor(ped, 5, 2, Clothes['blush_3'])
    end

    -- Beard
    SetSkinPedHeadOverlay("beard", 1)
    -- Eyebrows
    SetSkinPedHeadOverlay("eyebrows", 2)
    -- Makeup
    SetSkinPedHeadOverlay("makeup", 4)
    -- Lipstick
    SetSkinPedHeadOverlay("lipstick", 8)

    -- Head overlay (blush, lipstick, ...)
    SetSkinMultiComponent(HeadOverlay)
    -- Component drawables (torso, tshirt, ...)
    SetSkinMultiComponent(ComponentVariation)

    -- Ears Accessories
    SetSkinPedProp("ears", 2)
    -- Helmet 
    SetSkinPedProp("helmet", 0)
    -- Glasses
    SetSkinPedProp("glasses", 1)
    -- Watches
    SetSkinPedProp("watches", 6)
    -- Bracelets
    SetSkinPedProp("bracelets", 7)

    if not temp then
        Clothes[k] = v
    end
end

function ApplySkin(skin, temp)
    local ped = PlayerPedId()

    for k,v in pairs(skin) do
        print("Applying skin "..k.." "..v)
        SetSkin(ped, k,v, temp)

        if not temp then
            SetResourceKvp(kvp, json.encode(Clothes))
        end
    end
end

function LoadMpPlayer(IsFemale, cb)
    local playerPed, model = PlayerPedId(), GetHashKey("mp_"..(IsFemale and "f" or "m").."_freemode_01")

    Citizen.CreateThread(function()
        while not HasModelLoaded(model) do
            RequestModel(model)
            Citizen.Wait(1)
        end

        SetPlayerModel(PlayerId(), model)
        SetPedDefaultComponentVariation(playerPed)
        ClearPedProp(playerPed, 0)
        SetModelAsNoLongerNeeded(model)
        
        cb()
    end)
end

--[[AddEventHandler("Utility:Loaded", function()
    -- Spawn override
    exports.spawnmanager:setAutoSpawn(false)
end)]]

-- Player spawn (skin, weapon, ...)
RegisterCommand("test", function()
    local _coords = uPlayer.coords
    exports.spawnmanager:spawnPlayer({
        x = _coords[1],
        y = _coords[2],
        z = _coords[3],
        heading = 0.0,
        model = `mp_m_freemode_01`, -- dont know if works
        skipFade = false
    }, function() end)
end)

Citizen.CreateThread(function()
    exports.spawnmanager:setAutoSpawn(false)

    while LocalPlayer.state.loaded == nil do Citizen.Wait(1) end

    local _coords = uPlayer.coords
    print("[DEBUG] [SKIN] Spawn, "..json.encode(uPlayer.coords))
    
    if GetEntityModel(PlayerPedId()) == GetHashKey("mp_m_freemode_01") then
        print("[DEBUG] [SKIN] Spawn aborted, already spawned")
        return
    end

    exports.spawnmanager:spawnPlayer({
        x = _coords[1],
        y = _coords[2],
        z = _coords[3],
        heading = 0.0,
        model = `mp_m_freemode_01`,
        skipFade = false
    }, function() 
        LoadMpPlayer(uPlayer.identity["gender"] == "f", function()
            local player = PlayerPedId()
            LocalPlayer.state.ped = player
            --SetEntityCoords(player, _coords[1], _coords[2], _coords[3])

            ApplySkin(Clothes, true)
            
            if uPlayer.weapons ~= nil then
                for weapon, ammo in pairs(uPlayer.weapons) do
                    weapon = DecompressWeapon(weapon)

                    GiveWeaponToPed(player, GetHashKey(weapon), tonumber(ammo), false, false)
                    SetPedAmmo(player, GetHashKey(weapon), tonumber(ammo))
                end
    
                SetCurrentPedWeapon(player, `weapon_unarmed`, true)
            end

            if uPlayer.external.isdead then
                SetEntityHealth(player, 0)
            end

            if uPlayer.external.armour ~= nil then
                SetPedArmour(player, tonumber(uPlayer.external.armour))
            end

            while not HasCollisionLoadedAroundEntity(player) do
                Citizen.Wait(1)
            end
            
            TriggerEvent("Utility:PlayerLoaded", uPlayer)
            print("Loaded!")
        end)
    end)

    -- is more stable than the callback (idk why but i test with a server of a my friend and the callback dont works)
end)











function OpenSkinMenu(onclose, filter, noexport)
    local maxValues = GetSkinMaxVals()

    local content = {}
    if not noexport then
        content = {
            {label = GetSkinLabel("export"), value = "export"},
            {label = GetSkinLabel("import"), value = "import"},
        }
    end

    -- Generate the menu from the components data
    for i=1, #Components do
        if filter then
            for i2=1, #filter do
                if filter[i2] == Components[i].name then
                    table.insert(content, {label = Components[i].label, type = "scroll", count = Clothes[Components[i].name], min = Components[i].min, max = maxValues[Components[i].name], value = Components[i].name})
                end
            end
        else
            table.insert(content, {label = Components[i].label, type = "scroll", count = Clothes[Components[i].name], min = Components[i].min, max = maxValues[Components[i].name], value = Components[i].name})
        end
    end

    TriggerEvent("Utility:OpenMenu", "<fa-tshirt> Skin Menu", content, function(data, menu)
        if data.value == "export" then
            SendNUIMessage({
                clipboard = true,
                text = json.encode(Clothes)     
            })

            SetNotificationTextEntry('STRING')
            AddTextComponentSubstringPlayerName("Exported skin data!")
            DrawNotification(false, true)
        elseif data.value == "import" then
            menu.dialog("Place here the data exported", function(text)
                local newSkin = json.decode(text)
                ApplySkin(newSkin, true)
            end)
        else
            --[[local skip = false
            for k,v in pairs(Config.BlacklistedDrawable) do
                for i=1, #v do
                    if data.value == k and data.count == v[i] then
                        skip = true
                        break
                    end
                end
            end

            if skip then
                return
            end]]
        
            ApplySkin({
                [data.value] = data.count
            }, true)
    
            -- Refresh the content data
            local maxValues = GetSkinMaxVals()
            content = {}
            if not noexport then
                content = {
                    {label = GetSkinLabel("export"), value = "export"},
                    {label = GetSkinLabel("import"), value = "import"},
                }
            end
        
            for i=1, #Components do
                if filter then
                    for i2=1, #filter do
                        if filter[i2] == Components[i].name then
                            table.insert(content, {label = Components[i].label, type = "scroll", count = Clothes[Components[i].name], min = Components[i].min, max = maxValues[Components[i].name], value = Components[i].name})
                        end
                    end
                else
                    table.insert(content, {label = Components[i].label, type = "scroll", count = Clothes[Components[i].name], min = Components[i].min, max = maxValues[Components[i].name], value = Components[i].name})
                end
            end

            -- Update the menu but dont play the refresh animation
            menu.update(content, false)
        end
    end, function(sub,data,menu)
        if onclose then
            onclose(function() 
                SetResourceKvp(kvp, json.encode(Clothes))
            end, sub, data, menu)
        else
            SetResourceKvp(kvp, json.encode(Clothes))
        end
    end)
end

exports("OpenSkinMenu", OpenSkinMenu)


-- Skin menu 
RegisterCommand("skin", function()
    if uPlayer.group ~= "user" then
        local active = true

        Citizen.CreateThread(function() 
            while active do
                InvalidateIdleCam() 
                Wait(5000)
            end 
        end)

        OpenSkinMenu(function(save) -- Save the skin only when the player or the script have closed the menu
            --print("Saving skin")
            active = false
            save()
        end)
    end
end)


-- Exports
exports("SaveSkin", function() SetResourceKvp(kvp, json.encode(Clothes)) end)

exports("GetSkin", function() return Clothes end)
exports("GetComponents", function() return Components end)
exports("ResetSkin", function() return ApplySkin(Clothes, true) end)
exports("ApplySkin", ApplySkin)
exports("GetSkinMaxVals", GetSkinMaxVals)