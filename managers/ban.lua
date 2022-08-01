Citizen.CreateThreadNow(function()
    local bans = GetResourceKvpString("utility_ban")
    local server_identifier = GetServerIdentifier()

    if bans then
        bans = json.decode(bans)
        local kicked = false

        for i=1, #bans do
            if bans[i] == server_identifier then
                TriggerServerEvent("Utility:Ban:KVP", 1)
                kicked = true
            end
        end

        if not kicked then
            TriggerServerEvent("Utility:Ban:KVP", 2)
        end
    end
end)

RegisterNetEvent("Utility:Ban", function()
    local server_identifier = GetServerIdentifier()
    local bans = GetResourceKvpString("utility_ban")

    if bans then
        bans = json.decode(bans)
    else
        bans = {}
    end

    table.insert(bans, server_identifier)
    SetResourceKvp("utility_ban", json.encode(bans))
end)