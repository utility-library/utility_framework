--[[RegisterCommand("openinv", function()
    local elements = {}

    for k,v in pairs(uPlayer.inventory) do
        local item = GetItem(v[1])
        
        table.insert(elements, {
            label = item.label.." "..v[2].."\n"..json.encode(v[3]),
            value = k,
            item = v
        })
    end

    CreateMenu("Inventory", elements, function(data, menu)
        menu.sub(data.item[1], {
            {label = "Use", value = "use"},
        }, function(data2, menu2)
            print("Useitem")
            exports["utility_framework"]:UseItem(data.value, data.data)
            menu.close()
        end)
    end)
end)
RegisterKeyMapping("openinv", "Open Inventory Test", "keyboard", "F3")
]]

--print(GetConvar("ui_updateChannel", "Test"))

RegisterCommand("testMenu", function()
    CreateMenu("Test", {
        {text="Slider", icon="mdiTestTube", type="slider", count=0, min=0, max=10},
        {text="Button", icon="mdiTestTube"},
    }, function(self, data)
        menu.sub("Test2", {
            {text = "Diocane", icon = "mdiTestTube"}
        }, function(self, data)
            print("Sub: "..(data.count or data.text))
        end)

        print(data.count or data.text)
    end)
end)

RegisterCommand("testDialog", function()
    CreateDialog("Import skin", "insert a description here nigga", {
        {name = "Negro", placeholder = "frocio"}
    }, function(self, data)
        print("Value: "..data.Negro)
    end)
end)