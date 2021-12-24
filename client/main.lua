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

if Config.Actived.DisableVehicleRewards then
    Citizen.CreateThread(function()
        local player = PlayerPedId()

        while true do
            DisablePlayerVehicleRewards(PlayerId())
            Citizen.Wait(5)
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