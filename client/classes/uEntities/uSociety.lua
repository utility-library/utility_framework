BuildSociety = function(self)
    -- Stash methods
    for k,v in pairs(self.deposit) do
        if self[k] == nil and self[k] ~= "save" then
            self[k] = v
        end
    end

    self.deposit = nil

    return self
end

GetSociety = function(name)
    local datas = TriggerServerCallback("Utility:Society:GetSociety", name)
    datas.deposit = GetStash("society:"..name)

    return BuildSociety(datas)
end

exports("GetSociety", GetSociety)