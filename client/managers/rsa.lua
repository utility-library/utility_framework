local BlacklistedEncrypted = {}

RequestDataFromNui = function(message, type)
    local event = nil
    local p = promise:new()

    event = RegisterNetEvent("__cfx_nui:"..type, function(data)
        p:resolve(data)
    end)

    SendNUIMessage(message)

    local data = Citizen.Await(p)
    RemoveEventHandler(event)
    collectgarbage("collect")

    return data
end

RegisterNuiCallbackType("GenerateKey")
RegisterNuiCallbackType("Decrypted")
RegisterNuiCallbackType("Encrypted")

GenerateKeys = function()
    local data = RequestDataFromNui({type = "generate"}, "GenerateKey")
    return data.publicKey, data.privateKey
end
Encrypt = function(public, text)
    local data = RequestDataFromNui({type = "encrypt", public = public, text = text}, "Encrypted")

    return data.encrypted
end
Decrypt = function(private, encrypted)
    local data = RequestDataFromNui({type = "decrypt", private = private, encrypted = encrypted}, "Decrypted")

    return data.decrypted
end

exports("GenerateKeys", GenerateKeys)
exports("Encrypt", Encrypt)
exports("Decrypt", Decrypt)