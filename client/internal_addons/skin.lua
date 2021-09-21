-- Apply skin on utility load
local Character		= GetResourceKvpString("utility_skin")
local Components = {}

AddEventHandler("Utility:Loaded", function(uPlayer)
    -- Internal GetLabel because i dont have loaded the loader in the framework
    GetLabel = function(key)
        return Config.Labels["skin"][key] or nil
    end
    
    Components = {
        {label = GetLabel("face"), name = "face", value = 0, min = 0},
        {label = GetLabel("skin"), name = "skin", value = 0, min = 0},
        {label = GetLabel("hair_1"), name = "hair_1", value = 0, min = 0},
        {label = GetLabel("hair_2"), name = "hair_2", value = 0, min = 0},
        {label = GetLabel("hair_color_1"), name = "hair_color_1", value = 0, min = 0},
        {label = GetLabel("hair_color_2"), name = "hair_color_2", value = 0, min = 0},
        {label = GetLabel("tshirt_1"), name = "tshirt_1", value = 0, min = 0},
        {label = GetLabel("tshirt_2"), name = "tshirt_2", value = 0, min = 0},
        {label = GetLabel("torso_1"), name = "torso_1", value = 0, min = 0},
        {label = GetLabel("torso_2"), name = "torso_2", value = 0, min = 0},
        {label = GetLabel("decals_1"), name = "decals_1", value = 0, min = 0},
        {label = GetLabel("decals_2"), name = "decals_2", value = 0, min = 0},
        {label = GetLabel("arms"), name = "arms", value = 0, min = 0},
        {label = GetLabel("arms_2"), name = "arms_2", value = 0, min = 0},
        {label = GetLabel("pants_1"), name = "pants_1", value = 0, min = 0},
        {label = GetLabel("pants_2"), name = "pants_2", value = 0, min = 0},
        {label = GetLabel("shoes_1"), name = "shoes_1", value = 0, min = 0},
        {label = GetLabel("shoes_2"), name = "shoes_2", value = 0, min = 0},
        {label = GetLabel("mask_1"), name = "mask_1", value = 0, min = 0},
        {label = GetLabel("mask_2"), name = "mask_2", value = 0, min = 0},
        {label = GetLabel("bproof_1"), name = "bproof_1", value = 0, min = 0},
        {label = GetLabel("bproof_2"), name = "bproof_2", value = 0, min = 0},
        {label = GetLabel("chain_1"), name = "chain_1", value = 0, min = 0},
        {label = GetLabel("chain_2"), name = "chain_2", value = 0, min = 0},
        {label = GetLabel("helmet_1"), name = "helmet_1", value = -1, min = -1},
        {label = GetLabel("helmet_2"), name = "helmet_2", value = 0, min = 0},
        {label = GetLabel("glasses_1"), name = "glasses_1", value = 0, min = 0},
        {label = GetLabel("glasses_2"), name = "glasses_2", value = 0, min = 0},
        {label = GetLabel("watches_1"), name = "watches_1", value = -1, min = -1},
        {label = GetLabel("watches_2"), name = "watches_2", value = 0, min = 0},
        {label = GetLabel("bracelets_1"), name = "bracelets_1", value = -1, min = -1},
        {label = GetLabel("bracelets_2"), name = "bracelets_2", value = 0, min = 0},
        {label = GetLabel("bag"), name = "bags_1", value = 0, min = 0},
        {label = GetLabel("bag_color"), name = "bags_2", value = 0, min = 0},
        {label = GetLabel("eye_color"), name = "eye_color", value = 0, min = 0},
        {label = GetLabel("eyebrow_size"), name = "eyebrows_2", value = 0, min = 0},
        {label = GetLabel("eyebrow_type"), name = "eyebrows_1", value = 0, min = 0},
        {label = GetLabel("eyebrow_color_1"), name = "eyebrows_3", value = 0, min = 0},
        {label = GetLabel("eyebrow_color_2"), name = "eyebrows_4", value = 0, min = 0},
        {label = GetLabel("makeup_type"), name = "makeup_1", value = 0, min = 0},
        {label = GetLabel("makeup_thickness"), name = "makeup_2", value = 0, min = 0},
        {label = GetLabel("makeup_color_1"), name = "makeup_3", value = 0, min = 0},
        {label = GetLabel("makeup_color_2"), name = "makeup_4", value = 0, min = 0},
        {label = GetLabel("lipstick_type"), name = "lipstick_1", value = 0, min = 0},
        {label = GetLabel("lipstick_thickness"), name = "lipstick_2", value = 0, min = 0},
        {label = GetLabel("lipstick_color_1"), name = "lipstick_3", value = 0, min = 0},
        {label = GetLabel("lipstick_color_2"), name = "lipstick_4", value = 0, min = 0},
        {label = GetLabel("ear_accessories"), name = "ears_1", value = -1, min = -1},
        {label = GetLabel("ear_accessories_color"), name = "ears_2", value = 0, min = 0},
        {label = GetLabel("chest_hair"), name = "chest_1", value = 0, min = 0},
        {label = GetLabel("chest_hair_1"), name = "chest_2", value = 0, min = 0},
        {label = GetLabel("wrinkles"), name = "age_1", value = 0, min = 0},
        {label = GetLabel("wrinkle_thickness"), name = "age_2", value = 0, min = 0},
        {label = GetLabel("blemishes"), name = "blemishes_1", value = 0, min = 0},
        {label = GetLabel("blemishes_size"), name = "blemishes_2", value = 0, min = 0},
        {label = GetLabel("blush"), name = "blush_1", value = 0, min = 0},
        {label = GetLabel("blush_1"), name = "blush_2", value = 0, min = 0},
        {label = GetLabel("blush_color"), name = "blush_3", value = 0, min = 0},
        {label = GetLabel("complexion"), name = "complexion_1", value = 0, min = 0},
        {label = GetLabel("complexion_1"), name = "complexion_2", value = 0, min = 0},
        {label = GetLabel("sun"), name = "sun_1", value = 0, min = 0},
        {label = GetLabel("sun_1"), name = "sun_2", value = 0, min = 0},
        {label = GetLabel("freckles"), name = "moles_1", value = 0, min = 0},
        {label = GetLabel("freckles_1"), name = "moles_2", value = 0, min = 0},
        {label = GetLabel("beard_type"), name = "beard_1", value = 0, min = 0},
        {label = GetLabel("beard_size"), name = "beard_2", value = 0, min = 0},
        {label = GetLabel("beard_color_1"), name = "beard_3", value = 0, min = 0},
        {label = GetLabel("beard_color_2"), name = "beard_4", value = 0, min = 0}
    }
    
    if Character == "null" or Character == nil then
        -- Generate the basic character components
        Character = {}
        for i=1, #Components, 1 do
            Character[Components[i].name] = Components[i].value
        end
    else
        -- Decode the character json info
        Character = json.decode(Character)
    end

    -- Function
    function GetMaxVals()
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
            hair_2			= GetNumberOfPedTextureVariations		(playerPed, 2, Character['hair_1']) - 1,
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
            ears_2			= GetNumberOfPedPropTextureVariations	(playerPed, 1, Character['ears_1'] - 1),
            tshirt_1		= GetNumberOfPedDrawableVariations		(playerPed, 8) - 1,
            tshirt_2		= GetNumberOfPedTextureVariations		(playerPed, 8, Character['tshirt_1']) - 1,
            torso_1			= GetNumberOfPedDrawableVariations		(playerPed, 11) - 1,
            torso_2			= GetNumberOfPedTextureVariations		(playerPed, 11, Character['torso_1']) - 1,
            decals_1		= GetNumberOfPedDrawableVariations		(playerPed, 10) - 1,
            decals_2		= GetNumberOfPedTextureVariations		(playerPed, 10, Character['decals_1']) - 1,
            arms			= GetNumberOfPedDrawableVariations		(playerPed, 3) - 1,
            arms_2			= 10,
            pants_1			= GetNumberOfPedDrawableVariations		(playerPed, 4) - 1,
            pants_2			= GetNumberOfPedTextureVariations		(playerPed, 4, Character['pants_1']) - 1,
            shoes_1			= GetNumberOfPedDrawableVariations		(playerPed, 6) - 1,
            shoes_2			= GetNumberOfPedTextureVariations		(playerPed, 6, Character['shoes_1']) - 1,
            mask_1			= GetNumberOfPedDrawableVariations		(playerPed, 1) - 1,
            mask_2			= GetNumberOfPedTextureVariations		(playerPed, 1, Character['mask_1']) - 1,
            bproof_1		= GetNumberOfPedDrawableVariations		(playerPed, 9) - 1,
            bproof_2		= GetNumberOfPedTextureVariations		(playerPed, 9, Character['bproof_1']) - 1,
            chain_1			= GetNumberOfPedDrawableVariations		(playerPed, 7) - 1,
            chain_2			= GetNumberOfPedTextureVariations		(playerPed, 7, Character['chain_1']) - 1,
            bags_1			= GetNumberOfPedDrawableVariations		(playerPed, 5) - 1,
            bags_2			= GetNumberOfPedTextureVariations		(playerPed, 5, Character['bags_1']) - 1,
            helmet_1		= GetNumberOfPedPropDrawableVariations	(playerPed, 0) - 1,
            helmet_2		= GetNumberOfPedPropTextureVariations	(playerPed, 0, Character['helmet_1']) - 1,
            glasses_1		= GetNumberOfPedPropDrawableVariations	(playerPed, 1) - 1,
            glasses_2		= GetNumberOfPedPropTextureVariations	(playerPed, 1, Character['glasses_1'] - 1),
            watches_1		= GetNumberOfPedPropDrawableVariations	(playerPed, 6) - 1,
            watches_2		= GetNumberOfPedPropTextureVariations	(playerPed, 6, Character['watches_1']) - 1,
            bracelets_1		= GetNumberOfPedPropDrawableVariations	(playerPed, 7) - 1,
            bracelets_2		= GetNumberOfPedPropTextureVariations	(playerPed, 7, Character['bracelets_1'] - 1)
        }
    
        return data
    end
    
    function ApplySkin(skin, dontsave)
        local playerPed = PlayerPedId()
    
        for k,v in pairs(skin) do
            Character[k] = v
        end
    
        if not dontsave then
            SetResourceKvp("utility_skin", json.encode(Character))
        end

        SetPedHeadBlendData(playerPed, Character['face'], Character['face'], Character['face'], Character['skin'], Character['skin'], Character['skin'], 1.0, 1.0, 1.0, true)
    
        local data = {
            HeadOverlay = {
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
            },
            ComponentVariation = {
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
        }
    
        for i=1, 12 do
            for k,v in pairs(skin) do
                if data.HeadOverlay[i][1] == k or data.HeadOverlay[i][2] == k then
                    SetPedHeadOverlay(playerPed, i-1, Character[data.HeadOverlay[i][1]], Character[data.HeadOverlay[i][2]]/10 + 0.0)
                end
            end
        end
        for i=1, 11 do
            for k,v in pairs(skin) do
                if data.ComponentVariation[i][1] == k or data.ComponentVariation[i][2] == k then
                    SetPedComponentVariation(playerPed, i, Character[data.ComponentVariation[i][1]], Character[data.ComponentVariation[i][2]], 2)
                end
            end
        end
    
        -- Other data
        SetPedHairColor(playerPed, Character['hair_color_1'], Character['hair_color_2'])
        SetPedEyeColor(playerPed, Character['eye_color'], 0, 1)
        SetPedHeadOverlayColor(playerPed, 1, 1,	Character['beard_3'], Character['beard_4'])
        SetPedHeadOverlayColor(playerPed, 2, 1,	Character['eyebrows_3'], Character['eyebrows_4'])
        SetPedHeadOverlayColor(playerPed, 4, 1,	Character['makeup_3'], Character['makeup_4'])
        SetPedHeadOverlayColor(playerPed, 8, 1,	Character['lipstick_3'], Character['lipstick_4'])
        SetPedHeadOverlayColor(playerPed, 5, 2,	Character['blush_3'])
    
        -- Ears Accessories
        if Character['ears_1'] == -1 then ClearPedProp(playerPed, 2) else SetPedPropIndex(playerPed, 2, Character['ears_1'], Character['ears_2'], 2) end
    
        -- Helmet 
        if Character['helmet_1'] == -1 then ClearPedProp(playerPed, 0) else SetPedPropIndex(playerPed, 0, Character['helmet_1'], Character['helmet_2'], 2) end
    
        -- Glasses
        if Character['glasses_1'] == -1 then ClearPedProp(playerPed, 1) else SetPedPropIndex(playerPed, 1, Character['glasses_1'], Character['glasses_2'], 2) end
    
        -- Watches
        if Character['watches_1'] == -1 then ClearPedProp(playerPed, 6) else SetPedPropIndex(playerPed, 6, Character['watches_1'], Character['watches_2'], 2) end
    
        -- Bracelets
        if Character['bracelets_1'] == -1 then ClearPedProp(playerPed,	7) else SetPedPropIndex(playerPed, 7, Character['bracelets_1'], Character['bracelets_2'], 2) end
    end
    
    function LoadMpPlayer(IsFemale, cb)
        local playerPed, model = PlayerPedId()
    
        if not IsFemale then model = `mp_m_freemode_01` else model = `mp_f_freemode_01` end
    
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

    -- Exports
    exports("GetSkin", function() return Character end)
    exports("GetComponents", function() return Components end)
    exports("ApplySkin", ApplySkin)
    exports("GetMaxVals", GetMaxVals)

    --FreezeEntityPosition(PlayerPedId(), true)

    -- Spawn override
end)


AddEventHandler('onClientMapStart', function()
    local uPlayer = Utility.PlayerData

    exports.spawnmanager:setAutoSpawn(false)

    while uPlayer == nil do
        uPlayer = Utility.PlayerData
        Citizen.Wait(1)
    end

    --print("Spawn, "..json.encode(uPlayer.other_info.coords))
    local _coords = uPlayer.other_info.coords

    exports.spawnmanager:spawnPlayer({
        x = _coords.x,
        y = _coords.y,
        z = _coords.z,
        heading = 0.0,
        model = `mp_m_freemode_01`, -- dont know if works
        skipFade = false
    }, function()
        LoadMpPlayer((uPlayer.identity.sex:lower() == "f"), function()
            local player = PlayerPedId()
            ApplySkin(Character, true)
            TriggerEvent("Utility:PlayerLoaded", uPlayer)
            
            if uPlayer.other_info.weapon ~= nil then
                for weapon, ammo in pairs(uPlayer.other_info.weapon) do
                    GiveWeaponToPed(player, GetHashKey(weapon), tonumber(ammo), false, false)
                    
                    SetPedAmmo(player, GetHashKey(weapon), tonumber(ammo))
                end
    
                SetCurrentPedWeapon(player, `weapon_unarmed`, true)
            end
        end)
    end)
end)











function OpenSkinMenu(onclose)
    local maxValues = GetMaxVals()
    local content = {
        {label = GetLabel("export"), value = "export"},
        {label = GetLabel("import"), value = "import"},
    }

    -- Generate the menu from the components data
    for i=1, #Components do
        table.insert(content, {label = Components[i].label, type = "scroll", count = Character[Components[i].name], min = Components[i].min, max = maxValues[Components[i].name], value = Components[i].name})
    end

    TriggerEvent("Utility:OpenMenu", "<fa-tshirt> Skin Menu", content, 
    function(data, menu)
        if data.value == "export" then
            SendNUIMessage({
                clipboard = true,
                text = json.encode(Character)     
            })

            SetNotificationTextEntry('STRING')
            AddTextComponentSubstringPlayerName("Exported skin data!")
            DrawNotification(false, true)
        elseif data.value == "import" then
            menu.dialog("Place here the data exported", function(text)
                local newSkin = json.decode(text)
                ApplySkin(newSkin)
            end)
        else
            ApplySkin({
                [data.value] = data.count
            }, true)
    
            -- Refresh the content data
            local maxValues = GetMaxVals()
            local content = {
                {label = GetLabel("export"), value = "export"},
                {label = GetLabel("import"), value = "import"},
            }
        
            for i=1, #Components do
                table.insert(content, {label = Components[i].label, type = "scroll", count = Character[Components[i].name], min = Components[i].min, max = maxValues[Components[i].name], value = Components[i].name})
            end

            -- Update the menu but dont play the refresh animation
            menu.update(content, false)
        end
    end, onclose)
end

exports("OpenSkinMenu", OpenSkinMenu)


-- Skin menu 
RegisterCommand("skin", function()
    local uPlayer = Utility.PlayerData

    if uPlayer.group ~= "user" then
        OpenSkinMenu(function(sub, data, menu) -- Save the skin only when the player or the script have closed the menu
            --print("Saving skin")
            SetResourceKvp("utility_skin", json.encode(Character))
        end)
    end
end)