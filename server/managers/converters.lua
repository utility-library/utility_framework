ESXConvertTemplate = {
    -- Basic player data of ESX
    ["ESX(%s?)=(%s?)nil"] = {"string", ""},
    ["local ESX(%s?)=(%s?)nil"] = {"string", ""},
    ["esx_"] = {"string", "utility_"},
    
    ["xPlayer"] = {"string", "uPlayer"},
    ["TriggerEvent"] = {"function", "TriggerEvent", function(line, params) if params[1]:find("esx:getSharedObject") then return "" else return line end end},
    ["%.GetPlayerFromId"] = {
        "function", 
        ".GetPlayer", 
        function(line, params)
            return line:gsub("(%a-)%.", "")
        end
    },


    -- xPlayer functions
        ["%.addAccountMoney"] = {
            "function", 
            ".AddMoney"
        },
        ["%.addInventoryItem"] = {
            "function", 
            ".AddItem"
        },
        ["%.addMoney"] = {
            "function", 
            ".AddMoney", 
            function(line, params)
                return line:gsub(params[1], '"cash", '..params[1])
            end
        },
        ["%.addWeapon"] = {
            "function", 
            ".AddWeapon"
        },

        ["%.addWeaponAmmo"] = {
            "function", 
            ".AddWeaponAmmo"
        },
        ["%.addWeaponComponent"] = {
            "function", 
            ".NO_CONVERTED_addWeaponComponent"
        },

        ["%.canCarryItem"] = {
            "function", 
            ".CanCarryItem"
        },
        ["%.canSwapItem"] = {
            "function", 
            ".NO_CONVERTED_canSwapItem"
        },
        ["%.getAccount"] = {
            "function", 
            ".GetMoney"
        },
        ["%.getAccounts"] = {
            "function", 
            ".accounts", 
            function(line, params)
                return line:gsub("%(%)", "")
            end
        },
        ["%.getCoords"] = {
            "function", 
            ".coords"
        },
        ["%.getGroup"] = {
            "function", 
            ".group", 
            function(line, params)
                return line:gsub("%(%)", "")
            end
        },
        ["%.getIdentifier"] = {
            "function", 
            ".identifier", 
            function(line, params)
                return line:gsub("%(%)", "")
            end
        },
        ["%.getInventory"] = {
            "function", 
            ".inventory", 
            function(line, params)
                return line:gsub("%(%)", "")
            end
        },
        ["%.getInventoryItem"] = {
            "function", 
            ".GetItem"
        },
        ["%.getJob"] = {
            "function", 
            ".jobs", 
            function(line, params)
                return line:gsub("%(%)", "")
            end
        },
        ["%.getJob"] = {
            "function", 
            ".jobs", 
            function(line, params)
                return line:gsub("%(%)", "")
            end
        },
        ["%.getLoadout"] = {
            "function", 
            ".GetWeapons"
        },
        ["%.getMoney"] = {
            "function", 
            ".GetMoney", 
            function(line, params)
                return line:gsub("%(%)", '("cash").quantity')
            end
        },
        ["%.getName"] = {
            "function", 
            ".name", 
            function(line, params)
                return line:gsub("%(%)", "")
            end
        },
        ["%.getWeight"] = {
            "function", 
            ".weight", 
            function(line, params)
                return line:gsub("%(%)", "")
            end
        },
        ["%.hasWeapon"] = {
            "function", 
            ".HaveWeapon"
        },
        ["%.hasWeaponComponent"] = {
            "function", 
            ".NO_CONVERTED_hasWeaponComponent"
        },
        ["%.kick"] = {
            "function", 
            ".kick", 
            function(line, params)
                line = line:gsub("%(.*", "") -- Remove everything after (
                local var = line:match("(.-).kick"):gsub(" ", "")

                return line:gsub(var.."%.kick", "DropPlayer("..var..".source, "..params[1]..")")
            end
        },
        ["%.removeAccountMoney"] = {
            "function", 
            ".RemoveMoney"
        },
        ["%.removeInventoryItem"] = {
            "function", 
            ".RemoveItem"
        },
        ["%.removeMoney"] = {
            "function", 
            ".RemoveMoney",
            function(line, params)
                return line:gsub("%(", '("cash", ')
            end
        },
        ["%.removeWeapon"] = {
            "function", 
            ".RemoveWeapon"
        },

        ["%.removeWeaponAmmo"] = {
            "function", 
            ".NO_CONVERTED_removeWeaponAmmo"
        },
        ["%.removeWeaponComponent"] = {
            "function", 
            ".NO_CONVERTED_removeWeaponComponent"
        },
        ["%.setAccountMoney"] = {
            "function", 
            ".SetMoney"
        },
        ["%.setCoords"] = {
            "function", 
            ".source", 
            function(line, params)
                line = line:gsub("%(.*", "") -- Remove everything after (
                local var = line:match("(.-).source"):gsub(" ", "")

                return line:gsub(var.."%.source", "SetEntityCoords(GetPlayerPed("..var..".source), "..params[1]..","..params[2]..","..params[3]..")")
            end
        },
        ["%.setInventoryItem"] = {
            "function", 
            ".NO_CONVERTED_setInventoryItem"
        },
        ["%.setJob"] = {
            "function", 
            ".SetJob"
        },
        ["%.setMaxWeight"] = {
            "function", 
            ".SetMaxWeight"
        },
        ["%.setMoney"] = {
            "function", 
            ".SetMoney",
            function(line, params)
                return line:gsub("%(", '("cash", ')
            end
        },
        ["%.setName"] = {
            "function", 
            ".SetIdentity", 
            function(line, params)
                line = line:gsub("%(", "({\n        firstname = "..params[1].."\n    })")

                return line:gsub("%}%).*", "})")
            end
        },
        ["%.setWeaponTint"] = {
            "function", 
            ".NO_CONVERTED_setWeaponTint"
        },
        ["%.showHelpNotification"] = {
            "function", 
            ".ButtonNotification"
        },
        ["%.showNotification"] = {
            "function", 
            ".ShowNotification"
        },
        ["%.triggerEvent"] = {
            "function", 
            ".TriggerEvent"
        },

    -- ESX Server Functions
        ["%.GetItemLabel"] = {
            "function", 
            ".GetLabel", 
            function(line, params)
                local cleaned = line:gsub("(%a*)%.", "")
                return cleaned:gsub("%(", '("items", nil, ')
            end
        },
        ["%.GetPlayers"] = {
            "function", 
            ".GetPlayers", 
            function(line, params)
                return line:gsub("(%a-)%.", "")
            end
        },
        ["%.RegisterServerCallback"] = {
            "function", 
            ".RegisterServerCallback", 
            function(line, params)
                return line:gsub("(%a-)%.", "")
            end
        },
        ["cb"] = {
            "function", 
            "return", 
            function(line, params)
                return line:gsub("%(", " "):gsub("%)", "")
            end
        },
        ["%.RegisterUsableItem"] = {
            "function", 
            ".RegisterItemUsable", 
            function(line, params)
                return line:gsub("(%a-)%.", "")
            end
        },
        ["%.UseItem"] = {
            "function", 
            ".UseItem", 
            function(line, params)
                line = line:gsub("(%a-)%.", "uPlayer.")
                return line:gsub("%((%d+),%s?", "(")
            end
        },
        ["%.UI.Menu.CloseAll"] = {
            "function", 
            ".CloseAllMenu", 
            function(line, params)
                return line:gsub("(%a-)%.", "")
            end
        },

    -- Server => Client Event
        ["TriggerClientEvent"] = {
            "function", 
            "TriggerClientEvent", 
            function(line, params)
                if params[1]:find("esx:showNotification") then
                    line = line:gsub("TriggerClientEvent%(", "uPlayer.ShowNotification(")
                    line = (line:gsub(params[2]..",", "")):gsub(params[1]..",", "")

                    return line:gsub("uPlayer.ShowNotification%( ", "uPlayer.ShowNotification(") -- Remove the parameter space
                end

                return line
            end
        },

    -- Client
        -- Events
            ["esx:playerLoaded"] = {"string", "Utility:Loaded"},
        -- Functions
            ["%.GetPlayerData"] = {
                "function", 
                ".GetPlayerData",
                function(line, params) 
                    return line:gsub("(%a*)%.GetPlayerData%(%)", "uPlayer")
                end
            },
            ["%.IsPlayerLoaded"] = {
                "function", 
                ".IsPlayerLoaded",
                function(line, params) 
                    return line:gsub("(%a*)%.IsPlayerLoaded%(%)", "uPlayer ~= nil -- (use On \"load\" instead)")
                end
            },
            ["%.ShowHelpNotification"] = {
                "function", 
                ".ButtonNotification", 
                function(line, params)
                    return line:gsub("(%a*)%.", "")
                end
            },
            ["%.ShowNotification"] = {
                "function", 
                ".ShowNotification", 
                function(line, params)
                    return line:gsub("(%a*)%.", "")
                end
            },
            ["%.TriggerServerCallback"] = {
                "function", 
                ".TriggerServerCallback", 
                function(line, params)
                    return line:gsub("(%a*)%.", "")
                end
            },

            -- Game
                ["%.Game%.DeleteObject"] = {
                    "function", 
                    ".Game.DeleteObject", 
                    function(line, params)
                        return line:gsub("(%a*)%.Game%.", "")
                    end
                },
                ["%.Game%.DeleteVehicle"] = {
                    "function", 
                    ".Game.DeleteVehicle", 
                    function(line, params)
                        return line:gsub("(%a*)%.Game%.", "")
                    end
                },
                ["%.Game%.GetClosestObject"] = {
                    "function", 
                    ".Game.GetClosestObject", 
                    function(line, params)
                        return line:gsub("(%a*)%.Game%.", "")
                    end
                },
                ["%.Game%.GetClosestPed"] = {
                    "function", 
                    ".Game.GetClosestPed", 
                    function(line, params)
                        return line:gsub("(%a*)%.Game%.", "")
                    end
                },
                ["%.Game%.GetClosestVehicle"] = {
                    "function", 
                    ".Game.GetClosestVehicle", 
                    function(line, params)
                        return line:gsub("(%a*)%.Game%.", "")
                    end
                },
                ["%.Game%.GetObjects"] = {
                    "function", 
                    ".Game.GetObjects", 
                    function(line, params)
                        line = line:gsub("[%a%p]+", "")
                        return line.."GetGamePool(\"CObject\")"
                    end
                },
                ["%.Game%.GetPeds"] = {
                    "function", 
                    ".Game.GetPeds", 
                    function(line, params)
                        line = line:gsub("[%a%p]+", "")
                        return line.."GetGamePool(\"CPed\")"
                    end
                },
                ["%.Game%.GetVehicles"] = {
                    "function", 
                    ".Game.GetVehicles", 
                    function(line, params)
                        line = line:gsub("[%a%p]+", "")
                        return line.."GetGamePool(\"CVehicle\")"
                    end
                },

                ["%.Game%.GetVehicleProperties"] = {
                    "function", 
                    ".Game.GetVehicleComponents", 
                    function(line, params)
                        return line:gsub("(%a*)%.Game%.", "")
                    end
                },
                ["%.Game%.Utils%.DrawText3D"] = {
                    "function", 
                    ".Game.Utils.DrawText3D", 
                    function(line, params)
                        return line:gsub("(%a*)%.(%a*)%.Utils%.", "")
                    end
                },

    -- Common
        -- Events
            ["esx:onPlayerDeath"] = {"string", "Utility:OnDeath"},

        -- Functions
            ["%.Math%.Round"] = {
                "function", 
                "Round", 
                function(line, params)
                    local cleaned = line:gsub("(%a+)Round", "mathm.round")
                    return cleaned
                end
            },
            ["%.Math%.GroupDigits"] = {
                "function", 
                "GroupDigits", 
                function(line, params)
                    local cleaned = line:gsub("(%a+)GroupDigits", "mathm.humanize")
                    return cleaned
                end
            },
            ["%.GetConfig"] = {
                "function", 
                ".GetConfig", 
                function(line, params)
                    local cleaned = line:gsub("(%a*)%.", "")
                    return cleaned
                end
            },
            ["%.GetRandomString"] = {
                "function", 
                ".GetRandomString", 
                function(line, params)
                    local cleaned = line:gsub("(%a*)%.", "")
                    return cleaned:gsub("GetRandomString", "mathm.randoms")
                end
            },
            ["%.Game%.DeleteObject"] = {
                "function", 
                ".DeleteObject", 
                function(line, params)
                    return line:gsub("(%a-)%.", "")
                end
            },
            ["%.Game%.GetClosestPlayer"] = {
                "function", 
                ".GetClosestPlayer", 
                function(line, params)
                    return line:gsub("(%a-)%.", ""), true
                end
            },
}

function UnpackParameters(input)
    local self = {}
        
    for params in input:gmatch("([^,]+)") do
        table.insert(self, params)
    end

    return self
end

function PackParameters(tab)
    local self = ""
    for i=1, #tab do
        self = self..", "..tab[i]
    end

    return self:sub(3, #self)
end

function os.capture(cmd)
    local f = assert(io.popen(cmd, 'r'))
    local s = assert(f:read('*a'))
    f:close()
    return s
end

local defaultaddons = {
    ["mathm"] = "math"
}

function GetResourceLuaFiles(resource)
    local result = {}
    local directory = os.capture("dir \""..GetResourcePath(resource).."\" /b /r /s")

    for s in directory:gmatch("[^\n]+") do
        for file in s:gmatch(resource.."\\(.*)") do
            if file:find(".lua") then
                table.insert(result, file)
            end
        end
    end

    return result
end

function GetResources()
    local output = {}
    local current = GetCurrentResourceName()

    for i=0, GetNumResources()-1 do 
        if GetResourceByFindIndex(i) ~= current then 
            if GetResourceByFindIndex(i) ~= "_cfx_internal" then 
                table.insert(output, GetResourceByFindIndex(i))
            end 
        end 
    end

    return output
end

function ConvertFramework(template, resource, path)
    local output = ""
    local input = LoadResourceFile(resource, path)


    local linenumber = 1
    for line in string.gmatch(input,'[^\r\n]+') do 
        linenumber = linenumber + 1

        for k,v in pairs(template) do
            if v[1] == "function" then
                local params = line:match(k.."%((.-)%)")

                if params then -- If something as been founded
                    if v[3] then
                        line = line:gsub(k, v[2])
                        line, needmanual = v[3](line, UnpackParameters(params))

                        if needmanual then
                            print("^1"..resource.."/"..path..":"..linenumber.." has a function that requires manual adjustment! [Pattern: "..k.."]^0")
                        end
                    else
                        line = line:gsub(k, v[2])
                    end
                end
            elseif v[1] == "string" then
                local string = line:match(k)
                if string then
                    if v[3] then
                        line = v[3](line, UnpackParameters(params))
                    else
                        line = line:gsub(k, v[2])
                    end
                end
            end
        end

        output = output.."\n"..line
    end

    for k,v in pairs(defaultaddons) do
        if output:find(k.."%.") then
            output = 'local '..k..' = addon("'..v..'")\n'..output
        end
    end

    return output
end

function lbl(string)
    local linecount = 0
    for line in string.gmatch(string,"[^\r\n]*") do
        linecount = linecount + 1
        return linecount, line
    end 
end