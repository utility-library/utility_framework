local menu = {
    ConvertToNumber = function(data)
        for k,v in pairs(data) do
            local number = tonumber(v)
    
            if number ~= nil then
                data[k] = number
            end
        end
    end,

    currentSubMenu = 0,
    menus = {}
}

RegisterNetEvent("Utility:Close")
AddEventHandler("Utility:Close", function()
    menu.menus[1].close(menu.currentSubMenu, menu.menus[menu.currentSubMenu].data, MenuTemplate)

    Citizen.Wait(50)

    if not menu.preventDefault then
        SetNuiFocus(false, false)
        SendNUIMessage({open = false})
    else
        menu.preventDefault = false
    end
end)

-- Open the menu from the function in the loader
CreateMenu = function(title, content, cb, close)
    menu.menus = {}
    menu.currentSubMenu = 1

    menu.menus[1] = {}
    menu.menus[1].data = content
    menu.menus[1].title = title
    menu.menus[1].cb = cb or function()end
    menu.menus[1].close = close or function()end
    
    SendNUIMessage({open = true,content = content, closeLabel=Config.Menu.CloseLabel, title = title})
    SetNuiFocus(true, true)
end

-- Probably dont works in the server
RegisterNetEvent("Utility:OpenMenu")
AddEventHandler("Utility:OpenMenu", CreateMenu)


local MenuTemplate = {
    preventDefault = function()
        menu.preventDefault = true
    end,
    close = function()
        if menu.currentSubMenu > 1 then -- Returns to the previous submenu
            menu.currentSubMenu = menu.currentSubMenu - 1
            menu.menus[1].close(menu.currentSubMenu + 1, menu.menus[menu.currentSubMenu].data, MenuTemplate)
            
            Citizen.Wait(50)

            if not menu.preventDefault then
                SendNUIMessage({update = true, refresh = true, content = menu.menus[menu.currentSubMenu].data, closeLabel=Config.Menu.CloseLabel, title = menu.menus[menu.currentSubMenu].title})
            else
                menu.preventDefault = false
            end
        else -- Close
            menu.menus[1].close(menu.currentSubMenu, menu.menus[menu.currentSubMenu].data, MenuTemplate)

            Citizen.Wait(50)

            if not menu.preventDefault then
                SetNuiFocus(false, false)
                SendNUIMessage({open = false})
            else
                menu.preventDefault = false
            end
        end
    end,
    update = function(content, refresh)
        SendNUIMessage({update = true, refresh = refresh or false, content = content, closeLabel=Config.Menu.CloseLabel})
    end,
    dialog = function(placeholder, cb)
        SendNUIMessage({
            dialog = true,
            placeholder = placeholder          
        })
        menu.menus[menu.currentSubMenu].dialogcb = cb
    end,
    sub = function(title, content, newcb)
        menu.currentSubMenu = menu.currentSubMenu + 1
        menu.menus[menu.currentSubMenu] = {}
        local nuiMessage = nil
        
        if type(title) == "string" then
            menu.menus[menu.currentSubMenu].title = title
            menu.menus[menu.currentSubMenu].data = content
            menu.menus[menu.currentSubMenu].cb = newcb or function()end

            nuiMessage = {update = true, refresh = true, content = content, closeLabel=Config.Menu.CloseLabel, title = title}
        else
            menu.menus[menu.currentSubMenu].data = title
            menu.menus[menu.currentSubMenu].cb = content or function()end

            nuiMessage = {update = true, refresh = true, content = title, closeLabel=Config.Menu.CloseLabel}
        end
        

        SendNUIMessage(nuiMessage)
    end,
    clipboard = function(text)
        SendNUIMessage({
            clipboard = true,
            text = text     
        })
    end
}

RegisterNUICallback("DialogData", function(data)
    if menu.menus[menu.currentSubMenu].dialogcb ~= nil then
        menu.menus[menu.currentSubMenu].dialogcb(data.text)
    end
end)

-- Back to sub menu or close the menu
RegisterNUICallback("backsubmenu", function()
    if menu.currentSubMenu > 1 then -- Returns to the previous submenu
        menu.currentSubMenu = menu.currentSubMenu - 1
        menu.menus[1].close(menu.currentSubMenu + 1, menu.menus[menu.currentSubMenu].data, MenuTemplate)
        
        Citizen.Wait(50)

        if not menu.preventDefault then
            SendNUIMessage({update = true, refresh = true, content = menu.menus[menu.currentSubMenu].data, closeLabel=Config.Menu.CloseLabel, title = menu.menus[menu.currentSubMenu].title})
        else
            menu.preventDefault = false
        end
    else -- Close
        menu.menus[1].close(menu.currentSubMenu, menu.menus[menu.currentSubMenu].data, MenuTemplate)

        Citizen.Wait(50)

        if not menu.preventDefault then
            SetNuiFocus(false, false)
            SendNUIMessage({open = false})
        else
            menu.preventDefault = false
        end
    end
end)

-- Button and slider callback
RegisterNUICallback("button_selection", function(data)
    data.type = "button"
    
    menu.ConvertToNumber(data)

    for k, v in pairs(menu.menus) do
        print(k)
    end

    print("Function = "..tostring(menu.menus[menu.currentSubMenu].cb))

    menu.menus[menu.currentSubMenu].cb(data, MenuTemplate)
end)

RegisterNUICallback("slider", function(data)
    menu.ConvertToNumber(data)
    menu.menus[menu.currentSubMenu].cb(data, MenuTemplate)
end)

-- Toggle off the focus when close from the escape key
RegisterNUICallback("close", function()
    menu.menus[1].close(menu.currentSubMenu, menu.menus[menu.currentSubMenu].data, MenuTemplate)

    Citizen.Wait(50)

    if not menu.preventDefault then
        SetNuiFocus(false, false)
        SendNUIMessage({open = false})
    else
        menu.preventDefault = false
    end
end)