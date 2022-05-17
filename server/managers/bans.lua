LoadBans = function()
    MySQL.Async.fetchAll('SELECT data, token FROM bans', {}, function(bans) Utility.Bans = bans end)
end

-- KVP Ban
RegisterServerEvent("Utility:Ban:KVP")
AddEventHandler("Utility:Ban:KVP", function(number)
    if number == 1 then
        print("[^1INFO^0] "..GetPlayerName(source).." tried to join but is ^1banned^0! [Rejection Type: 3]")   
        DropPlayer(source, ts.translate(Config.DefaultLanguage, Config.Labels["framework"]["Banned"]))
    elseif number == 2 then
        print("[^3INFO^0] The player "..GetPlayerName(source).." is banned from other servers with the utility_framework, has not been banned from this server as well since we cannot verify the source, but we advise you to pay attention!")
    end
end)