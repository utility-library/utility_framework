RegisterServerEvent("Utility:Status:Update")
AddEventHandler("Utility:Status:Update", function()
    local uPlayer = GetPlayer(source)

    for status,default in pairs(Config.Addons.Status.default) do
        if uPlayer then
            local statusvalue = uPlayer.Get(status) or default

            if statusvalue <= 0.0 then
                uPlayer.TriggerEvent("Utility:Status:RemoveHealth")
            else
                local newvalue = mathm.round(statusvalue - Config.Addons.Status.remove, 2)

                if newvalue < 0.0 then
                    newvalue = 0.0
                end

                uPlayer.Set(status, newvalue)
            end
        end
    end
end)