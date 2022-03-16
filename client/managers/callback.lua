enc = addon("encrypting")

-- ServerCallback
TriggerServerCallbackAsync = function(name, _function, ...)
    local eventHandler = nil
    local b64nameC = enc.Utf8ToB64(name.."_l")

    RegisterNetEvent(b64nameC)
    eventHandler = AddEventHandler(b64nameC, function(data)
        if type(_function) == "function" then _function(table.unpack(data)) end
        RemoveEventHandler(eventHandler)
    end)
    
    TriggerServerEvent(name, ...)
end

TriggerServerCallbackSync = function(name, ...)
    local p = promise.new()        
    local eventHandler = nil
    local b64nameC = enc.Utf8ToB64(name.."_l")

    RegisterNetEvent(b64nameC)
    eventHandler = AddEventHandler(b64nameC, function(data)
        RemoveEventHandler(eventHandler)
        p:resolve(data)
    end)

    TriggerServerEvent(name, ...)
    return table.unpack(Citizen.Await(p))
end