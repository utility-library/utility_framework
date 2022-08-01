GetLabel = function(key)
    if Config.Labels[key or "framework"] then
        return Config.Labels[key or "framework"][value] or nil
    else
        return nil
    end
end