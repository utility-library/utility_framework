local JoinedAt = GetGameTimer()

-- Preventing global overwriting
local invoking, exports = GetInvokingResource, exports
local LoadResourceFile, GetResourceByFindIndex, GetNumResources = LoadResourceFile, GetResourceByFindIndex, GetNumResources

local loaded = {}

local Keys = {
    Private = nil,
    Public = nil,

    Token = nil,
    Exposed = false
}

local function ResourceExist(name)
    for i = 0, GetNumResources(), 1 do
        local res = GetResourceByFindIndex(i)
        if res and res == name then
            return true
        end
    end

    return false
end

local function CanRequestToken(name)
    local manifest = LoadResourceFile(name, "fxmanifest.lua")

    if manifest:find("@utility_framework") then
        return true
    end
end

local _PRINT = print
local function print(text)
    _PRINT("[^4TBP^0] ^3"..text.."^0")
end

exports("UtilityOnTop", function(ClientPublicKey)   
    print("Called UtilityOnTop by "..invoking())
    
    if Keys.Exposed or Keys.ResExposed then -- Prevents the code from being called without actually being requested
        local res = invoking()

        -- Check that the resource that invoked exist
        -- Check that the resoruce dont have already requested the code
        -- Check that resource exist in the list of avaiable resources
        -- And finally check that can request it (by checking the manifest)

        if res and not loaded[res] and ResourceExist(res) and CanRequestToken(res) then
            -- Check that if a resource exposed the token is the same that requested the token 
            -- (Prevent random resource stop and start of the "infected" resource bypassing the exposed system)

            if Keys.ResExposed and res ~= Keys.ResExposed then
                print(res.." is not the resource that has exposed the token.")
                return
            end

            Keys.ResExposed = nil 
            loaded[res] = true

            print("Sending function to get the token to "..res)

            return function() -- Prevent executor event loggers, probably there isnt the functions log
                print("Encrypting token with api public key")

                while Keys.Token == nil do
                    Citizen.Wait(0)
                end

                return exports["utility_framework"]:Encrypt(ClientPublicKey, Keys.Token)
            end
        else
            print("Resource "..res.." as already requested the token")
        end
    else
        -- If is playing on the server more than 20s and not exposed, ban (prevent resource loading ban)
        if NetworkIsSessionActive() and (GetGameTimer() - JoinedAt) > 20000 then
            print("[DEBUG] [TBP] Banning player because he is not exposed, "..invoking())

            --[[TriggerServerEvent("Utility:SelfBan", "Tried to get the private key when isnt exposed [TBP Auto Ban]")

            Citizen.CreateThread(function()
                Citizen.Wait(1000)
                while true do end -- Crash the client
            end)]]
        end
    end
end)

Citizen.CreateThread(function()
    TriggerEvent("Utility:Logger", GetCurrentResourceName())
    if Config.Actived.Pvp then
        SetCanAttackFriendly(PlayerPedId(), true, false)
        NetworkSetFriendlyFireOption(true)
    end

    Citizen.Wait(200)
    
    Keys.Public, Keys.Private = GenerateKeys()

    print("Requesting server token")
    TriggerServerCallbackAsync("Utility:GetToken", function(identifier, ServerEncryptedToken)
        print("Got token from server "..ServerEncryptedToken)
        LocalPlayer.state.identifier = identifier

        Keys.Token = exports["utility_framework"]:Decrypt(Keys.Private, ServerEncryptedToken)
        print("Decrypted token with server private")

        print("Keys token = "..tostring(Keys.Token))

        -- Expose the token to the clients
        print("Exposing token to clients [Exposed = true]")
        Keys.Exposed = true
        while not NetworkIsSessionActive() do
            Citizen.Wait(100)
        end

        Citizen.Wait(500)
        Keys.Exposed = false
        print("Removing exposion of token to clients [Exposed = false]")

    end, Keys.Public)
end)

-- Key Exposing
AddEventHandler("onResourceStop", function(res) 
    if res == "utility_framework" then return end
    Citizen.Wait(1) -- Prevent fake call 

    if GetResourceState(res) == "stopped" then
        print("Resource "..res.." stopped, removing from the loaded list")
        if loaded then loaded[res] = nil end
    end
end)

AddEventHandler("onResourceStarting", function(res)
    if res == "utility_framework" then return end

    print("Resource exposed token: "..res)
    Keys.ResExposed = res
end)