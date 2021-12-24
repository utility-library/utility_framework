local crouched, handsup, faint = false, false, false

RegisterCommand("ut_animation", function(source, args)
    local player = PlayerPedId()

    if not IsPauseMenuActive() and not IsPedInAnyVehicle(PlayerPedId()) then 
        if args[1] == "crouch" then
            if Config.Addons.Animation.crouch then
                -- Optimized from https://forum.cfx.re/u/wolfknight
                RequestAnimSet("move_ped_crouched")
                while not HasAnimSetLoaded("move_ped_crouched") do Citizen.Wait(100) end
                
                if crouched then 
                    Citizen.Wait(1)

                    while GetPedStealthMovement(player) do
                        SetPedStealthMovement(PlayerPedId(), false, "DEFAULT_ACTION")
                        Citizen.Wait(1)
                    end      

                    ResetPedMovementClipset(player, 0)
                    crouched = false 
                else
                    Citizen.Wait(1)

                    while GetPedStealthMovement(player) do
                        SetPedStealthMovement(PlayerPedId(), false, "DEFAULT_ACTION")
                        Citizen.Wait(1)
                    end

                    SetPedMovementClipset(player, "move_ped_crouched", 0.25)
                    crouched = true 
                end 
            end
        elseif args[1] == "handsup" then   
            if Config.Addons.Animation.handsup then
                -- Optimized from https://github.com/KadDarem/Walkable-Hands-Up 
                RequestAnimDict("missminuteman_1ig_2")
                while not HasAnimDictLoaded("missminuteman_1ig_2") do Citizen.Wait(100) end

                if handsup then
                    ClearPedTasks(player)
                    handsup = false
                else
                    TaskPlayAnim(player, "missminuteman_1ig_2", "handsup_enter", 8.0, 8.0, -1, 50, 0, false, false, false)
                    handsup = true   
                end
            end
        elseif args[1] == "faint" then
            if Config.Addons.Animation.faint then
                faint = not faint
                
                if faint then
                    Citizen.CreateThread(function()
                        while faint do
                            SetPedToRagdoll(player, 1000, 1000, 0, 0, 0, 0)
                            Citizen.Wait(1)
                        end
                    end)
                end
            end
        end
    end
end, true)

RegisterKeyMapping("ut_animation crouch", "Crouch key", "keyboard", "LCONTROL")
RegisterKeyMapping("ut_animation handsup", "Handsup key", "keyboard", "x")
RegisterKeyMapping("ut_animation faint", "Faint key", "keyboard", "COMMA")