local BlacklistedSources = {}
local Keys = {}

Citizen.CreateThread(function()
    exports["utility_framework"]:GenerateKeys(function(public, private)
        Keys.public = public
        Keys.private = private
    
        Log("Development", "Generated RSA keys for TBP (Public: "..(Keys.public:gsub("\n", ""))..", Private: "..(Keys.private:gsub("\n", ""))..")")
    end)
end)

RegisterServerCallback("Utility:GetToken", function(clientPublicKey)
    local source = source

    if not BlacklistedSources[source] then
        BlacklistedSources[source] = true

        local p = promise:new()
        exports["utility_framework"]:Encrypt(clientPublicKey, Utility.Token, function(enc) p:resolve(enc) end)
        local enc = Citizen.Await(p)
        
        Log("Development", "Encrypted token with the client public key of "..GetPlayerName(source).." ("..source.."), the result is: "..enc)
        return GetuPlayerIdentifier(source), enc
    else
        -- Already getted the token
        Log("TBP", "Source "..source.." tried to get the token that was already getted, probably a executor")
        return nil
    end
end)

RegisterServerCallback("Utility:RequestPublicKey", function()
    return Keys.public
end)

exports("GetServerToken", function()
    if GetInvokingResource() then
        Log("Development", "The server API requested the private and the token")
        return Keys.private, Utility.Token
    end
end)