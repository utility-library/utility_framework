enc = addon("encrypting")

-- ServerCallback
TriggerServerCallbackAsync = function(name, _function, ...)
    local eventHandler = nil
    local b64nameC = enc.Utf8ToB64(name) -- Prevent noobies to know if a event is a callback or not

    -- Register a new event to handle the callback from the server
    RegisterNetEvent(b64nameC)
    eventHandler = AddEventHandler(b64nameC, function(data)
        if type(_function) == "function" then _function(table.unpack(data)) end
        RemoveEventHandler(eventHandler)
    end)
    
    TriggerServerEvent(name, ...) -- Trigger the server event to get the data
end

TriggerServerCallbackSync = function(name, ...)
    local p = promise.new()        
    local eventHandler = nil
    local b64nameC = enc.Utf8ToB64(name)

    -- Register a new event to handle the callback from the server
    RegisterNetEvent(b64nameC)
    eventHandler = AddEventHandler(b64nameC, function(data)
        RemoveEventHandler(eventHandler)
        p:resolve(data)
    end)

    TriggerServerEvent(name, ...) -- Trigger the server event to get the data
    return table.unpack(Citizen.Await(p))
end