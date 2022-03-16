local BlacklistedSources = {}
RegisterServerCallback("Utility:GetToken", function()
    if not BlacklistedSources[source] then
        return GetPlayerIdentifier(source, 0), tostring(Utility.Token):gsub('.', function(c) 
            return c + Config.TriggerBasicProtection.Pos
        end)
    else
        -- Already getted the token
        return nil
    end
end)

RegisterServerEvent("Utility:ShareToken")
AddEventHandler("Utility:ShareToken", function(cb)
    local res = GetInvokingResource()

    if res then
        cb(Utility.Token)
    end
end)