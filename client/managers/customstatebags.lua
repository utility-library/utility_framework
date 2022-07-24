--// Custom state bags
local StateBags = {}

RegisterNetEvent("Utility:SetStateBagValue", function(identifier, k, v) -- Trigger to update something change in a custom state bag that replicate
    print(identifier, k, v)

    if not StateBags[identifier] then
        StateBags[identifier] = {}
    end

    StateBags[identifier][k] = v
end)

NewCustomStateBag = function(identifier, request)
    if identifier then
        if request then -- Dont update every time but update only on call
            StateBags[identifier] = TriggerServerCallback("Utility:GetStateBagValue", identifier)
        end

        if not StateBags[identifier] then
            StateBags[identifier] = {}
        end
        
        return StateBags[identifier]
    end
end

exports("NewStateBag", NewCustomStateBag)