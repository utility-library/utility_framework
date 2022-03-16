class = addon("class")
local ToSave = {}

local self = {
    autoFetch = function(query, params, cb)
        oxmysql:query_async(query, params, function(proxy)
            local class = class.create(proxy)()
            
            ToSave[#ToSave + 1] = class
            cb(ToSave[#ToSave])
        end)
    end
}

return self