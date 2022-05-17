RegisterServerEvent("Utility:SetDeath")
AddEventHandler("Utility:SetDeath", function(death, info)
    local player = Player(source).state

    local oio = player.external

    if Config.Actived.No_Rp.KillDeath then
        if info ~= nil and info.killer ~= 0 then
            local player = Player(info.killer).state
            local oi = player.external

            if oi.kill == nil then 
                oi.kill = 0
            end

            oi.kill = oi.kill + 1

            player.external = oi
        end

        if oio.death == nil then 
            oio.death = 0 
        end
        oio.death = oio.death + 1
    end
    
    oio.isdead = death
    player.external = oio
end)