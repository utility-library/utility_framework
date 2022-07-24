-- Log the token generated
Log("TBP", 'Token generated => "'..Utility.Token..'"')

Citizen.CreateThreadNow(function()
    if not StartupCheck() then return end

    analizer.start()

    -- Load uEntities
    local vehicles = LoadVehicles()
    local players  = LoadPlayers()
    local societies = LoadSocieties()
    local stashes = LoadStashes()
    
    -- Loaded Message
    LoadBans()
    StartupMessage(players, societies, vehicles, stashes)

    if GetResourceState("basic-gamemode") == "started" then
        StopResource("basic-gamemode")
    end
    return
end)


-- Advertisement
SetConvarServerInfo("Framework", "Utility")