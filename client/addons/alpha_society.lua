local mathm = addon("math")
local defaultMenus = {
    ["bar"] = {
        {label = "Billing", value = "bill"}
    },
    ["illegal"] = {
        {label = "Search", value = "search"},
        {label = "Handcuff", value = "handcuff"},
        {label = "Drag", value = "drag"},
    }
}

local function GetClosestPlayer(radius)
    local peds = GetGamePool("CPed")
    local players = {}

    for i=1, #peds do
        if GetEntityModel(peds[i]) == `mp_m_freemode_01` or GetEntityModel(peds[i]) == `mp_f_freemode_01` then
            local player = NetworkGetPlayerIndexFromPed(peds[i])

            table.insert(players, player)
        end
    end

    return players
end


local self = {
    blip = function(coords, sprite, color)
        local blip = AddBlipForCoord(coords)

        SetBlipSprite(blip, sprite)
        SetBlipColour(blip, color)
    end,
    menu = function(society_name, key, customMenu)
        local menuString = "society_menu_"..mathm.random(5)

        RegisterCommand(menuString, function(source, args)
            local components = {}

            if type(customMenu) == "table" then
                components = customMenu
            elseif type(customMenu) == "string" then
                components = defaultMenus[customMenu]
            end

            TriggerEvent("Utility:OpenMenu", "<fa-building> Society menu", components, function(data, menu)
                if data.value == "bill" then
                    local players = GetClosestPlayer(5.0)
                    local components = {}

                    for i=1, #players do
                        table.insert(components, {label = GetPlayerName(players[i]), value = players[i]})
                    end

                    menu.sub("<fa-users> Select a player", components, function(data2, menu2)
                        local selectedPlayer = data2.value

                        menu.dialog("How much is?", function(quantity)
                            quantity = tonumber(quantity)

                            if quantity then
                                -- Bill create
                            end
                        end)
                    end)
                end
            end)
        end, true)

        RegisterKeyMapping(menuString, "Menu of a society", "keyboard", key)

        return {
            bill = function()

            end
        }
    end
}

return self