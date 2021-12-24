local self = {
    create = function(obj, param)
        obj.__index = obj
        return function(param)
            return setmetatable(param or {}, obj) 
        end
    end
}

return self