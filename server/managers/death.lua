RegisterServerEvent("Utility:SetDeath")
AddEventHandler("Utility:SetDeath", function(steam, death, info)
    local player = Player(source).state

    local oio = player.other_info

    if Config.Actived.No_Rp.KillDeath then
        if info ~= nil and info.killer ~= 0 then
            local player = Player(info.killer).state
            local oi = player.other_info

            if oi.kill == nil then 
                oi.kill = 0
            end

            oi.kill = oi.kill + 1

            player.other_info = oi
        end

        if oio.death == nil then 
            oio.death = 0 
        end
        oio.death = oio.death + 1
    end
    
    oio.isdead = death
    player.other_info = oio
end)