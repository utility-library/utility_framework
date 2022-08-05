--// Custom state bags
local StateBags = {}

local GetStateBagValue = function(identifier, k)
    if identifier and StateBags[identifier] then
        return StateBags[identifier][k]
    end
end

local SetStateBagValue = function(identifier, k, v, r)
    --print("Set state bag value for "..identifier, k, v, r)

    if identifier and StateBags[identifier] then
        StateBags[identifier][k] = v

        if r then
            TriggerClientEvent("Utility:SetStateBagValue", -1, identifier, k, v)
        end
    end
end

DoesStateBagExist = function(identifier)
    return StateBags[identifier] ~= nil
end

NewCustomStateBag = function(identifier, r)
    if identifier then
        if not StateBags[identifier] then
            StateBags[identifier] = {}
        end

        return setmetatable({}, {
            __index = function(_, s)
                if s == 'set' then
                    return function(_, s, v, r)
                        SetStateBagValue(identifier, s, v, r)
                    end
                end
            
                return GetStateBagValue(identifier, s)
            end,
            
            __newindex = function(_, s, v)
                SetStateBagValue(identifier, s, v, r)
            end
        })
    end
end

RegisterServerCallback("Utility:GetStateBagValue", function(identifier)
    if identifier and StateBags[identifier] then
        --print("Returning state bag "..identifier.." to "..source, json.encode(StateBags[identifier]))
        return StateBags[identifier]
    else
        print("state bag with that identifier dont exist\navailable:\n")

        for k,v in pairs(StateBags) do
            print(k)
        end
    end
end)

exports("GetStateBagValue", GetStateBagValue)
exports("SetStateBagValue", SetStateBagValue)
exports("DoesStateBagExist", DoesStateBagExist)