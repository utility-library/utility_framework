CreateMenu = function(title, content, callback, closecb) 
    TriggerEvent("Utility:OpenMenu", title, content, callback, closecb)
end

RegisterCommand("openinv", function()
    local elements = {}

    for k,v in pairs(uPlayer.inventory) do
        local item = GetItem(v[1])
        
        table.insert(elements, {
            label = item.label.." "..v[2].."\n"..json.encode(v[3]),
            value = k
        })
    end

    CreateMenu("Inventory", elements, function(data, menu)
        
    end)
end)
RegisterKeyMapping("openinv", "Open Inventory Test", "keyboard", "F3")


--print(GetConvar("ui_updateChannel", "Test"))