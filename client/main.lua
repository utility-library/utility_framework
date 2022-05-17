Utility = {
    Button = {
        ["{A}"] = "~INPUT_VEH_FLY_YAW_LEFT~",
        ["{B}"] = "~INPUT_SPECIAL_ABILITY_SECONDARY~",
        ["{C}"] = "~INPUT_LOOK_BEHIND~",
        ["{D}"] = "~INPUT_MOVE_LR~",
        ["{E}"] = "~INPUT_CONTEXT~",
        ["{F}"] = "~INPUT_ARREST~",
        ["{G}"] = "~INPUT_DETONATE~",
        ["{H}"] = "~INPUT_VEH_ROOF~",
        ["{L}"] = "~INPUT_CELLPHONE_CAMERA_FOCUS_LOCK~",
        ["{M}"] = "~INPUT_INTERACTION_MENU~",
        ["{N}"] = "~INPUT_REPLAY_ENDPOINT~",
        ["{O}"] = "UNKOWN_BUTTON",
        ["{P}"] = "~INPUT_FRONTEND_PAUSE~",
        ["{Q}"] = "~INPUT_FRONTEND_LB~",
        ["{R}"] = "~INPUT_RELOAD~",
        ["{S}"] = "~INPUT_MOVE_DOWN_ONLY~",
        ["{T}"] = "~INPUT_MP_TEXT_CHAT_ALL~",
        ["{U}"] = "~INPUT_REPLAY_SCREENSHOT~",
        ["{V}"] = "~INPUT_NEXT_CAMERA~",
        ["{W}"] = "~INPUT_MOVE_UP_ONLY~",
        ["{X}"] = "~INPUT_VEH_DUCK~",
        ["{Y}"] = "INPUT_MP_TEXT_CHAT_TEAM",
        ["{Z}"] = "INPUT_HUD_SPECIAL",
    }
}

-- Wanted level
SetMaxWantedLevel(0)
SetPlayerWantedLevelNoDrop(PlayerId(), 0, false)

if Config.Actived.DisableSoftVehicleRewards then
    local RewardWeapons = {
        "weapon_smg",
        "weapon_carbinerifle",
        "weapon_pumpshotgun",
        "weapon_sniperrifle",
        "weapon_pistol",
    }

    Citizen.CreateThread(function()
        local player = PlayerId()

        while true do
            if uPlayer and uPlayer.loaded then
                for i=1, #RewardWeapons do
                    if HasPedGotWeapon(uPlayer.ped, GetHashKey(RewardWeapons[i])) then
                        if not ut:HaveWeapon(RewardWeapons[i]) then
                            RemoveWeaponFromPed(uPlayer.ped, GetHashKey(RewardWeapons[i]))
                        end
                    end
                end
            end
            Citizen.Wait(1000)
        end
    end)
end

if Config.Actived.DisableHardVehicleRewards then
    Citizen.CreateThread(function()
        local player = PlayerId()

        while true do
            DisablePlayerVehicleRewards(player)
            Citizen.Wait(0)
        end
    end)
end

if Config.Actived.NoWeaponDrop then
    Citizen.CreateThread(function()
        while true do
            local PedList = GetGamePool("CPed")
    
            for i=1, #PedList do
                SetPedDropsWeaponsWhenDead(PedList[i], false)
            end
            Citizen.Wait(2000)
        end
    end)
end

Citizen.CreateThread(function()
    Citizen.Wait(100) -- Wait that NUI Load
    SendNUIMessage({imgdir = Config.Inventory.NotificationImageBaseDirectory})
end)

local pressedF = false
RegisterCommand("enter_exitvehicle", function(source, args)
    local veh = uPlayer.veh

    Citizen.Wait(50)

    if GetVehiclePedIsTryingToEnter(uPlayer.ped) == 0 then
        EmitEvent("ExitVehicle", veh)
    else
        if not pressedF then
            pressedF = true
            while GetVehiclePedIsTryingToEnter(uPlayer.ped) ~= 0 do
                Citizen.Wait(100)
            end
            pressedF = false
        
            veh = uPlayer.veh
            if veh ~= 0 and veh ~= nil then
                EmitEvent("EnterVehicle", uPlayer.veh)
            end
        end
    end
end, true)

RegisterKeyMapping("enter_exitvehicle", "DONT TOUCH", "keyboard", "F")