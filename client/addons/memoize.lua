return function(func)
    local cache = {}

    return function(...)
        local argsAsString = JSON.encode({...})
        cache[argsAsString] = cache[argsAsString] or func(...)

        return cache[argsAsString]
    end
end