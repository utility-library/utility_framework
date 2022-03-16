Citizen.CreateThreadNow(function()
    DeleteResourceKvp("utility_ban")
    local bans = GetResourceKvpString("utility_ban")

    if bans then
        bans = json.decode(bans)
        local kicked = false

        for i=1, #bans do
            if bans[i] == GetCurrentServerEndpoint():match("^(.-):") then
                TriggerServerEvent("Utility:Ban:KVP", 1)
                kicked = true
            end
        end

        if not kicked then
            TriggerServerEvent("Utility:Ban:KVP", 2)
        end
    end
end)