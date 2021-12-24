enc = addon("encrypting")

-- ServerCallback
TriggerServerCallbackSync = function(name, _function, ...)
    local handlerData = nil
    local b64nameC = "Utility:External:"..enc.Utf8ToB64("Utility_Callback:"..name.."_l")
    local b64nameS = "Utility:External:"..enc.Utf8ToB64("Utility_Callback:"..name)

    RegisterNetEvent(b64nameC)
    handlerData = AddEventHandler(b64nameC, function(...)
        _function(...)

        RemoveEventHandler(handlerData)
    end)

    
    TriggerServerEvent(b64nameS, ...)
end

TriggerServerCallbackAsync = function(name, _function, ...)
    local p = promise.new()        
    local handlerData = nil
    local b64nameC = "Utility:External:"..enc.Utf8ToB64("Utility_Callback:"..name.."_l")
    local b64nameS = "Utility:External:"..enc.Utf8ToB64("Utility_Callback:"..name)

    RegisterNetEvent(b64nameC)
    handlerData = AddEventHandler(b64nameC, function(...)
        _function(...)
        RemoveEventHandler(handlerData)
        p:resolve()
    end)

    TriggerServerEvent(b64nameS, ...)

    Citizen.Await(p)
end