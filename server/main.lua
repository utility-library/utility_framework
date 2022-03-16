-- Log the token generated
Log("TBP", 'Token generated => "'..Utility.Token..'"')

Citizen.CreateThreadNow(function()
    if not StartupCheck() then return end

    analizer.start()

    local vehicle = LoadVehicles()
    local player  = LoadPlayers()
    local society = LoadSociety()
    
    -- Loaded Message
    StartupMessage(player, society, vehicle)
    LoadBans()
    return
end)


-- Advertisement
SetConvarServerInfo("Framework", "Utility")

















--[[GetPlayer("steam:11000011525c3cc"):Build()
GetPlayer("steam:11000011525c3cc"):Demolish()

GetVehicle("06DLN645"):Build()
GetVehicle("06DLN645"):Demolish()

GetSociety("police"):Build()
GetSociety("police"):Demolish()

for k, v in pairs(Utility.SocietyData) do
    print("^1Executing^0 "..k)
    for k,v in pairs(v) do
        print(k, v, type(v))
    end
end]]