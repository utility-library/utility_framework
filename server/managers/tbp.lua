local BlacklistedSources = {}
RegisterServerCallback("Utility:GetToken", function()
    if not BlacklistedSources[source] then
        return GetPlayerIdentifiers(source)[1], tostring(Utility.Token):gsub('.', function(c) return string.format('%02X', string.byte(c)) end)
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