local currentDate = os.date("%y-%m-%d")
local logId = math.random(0, 999)
-- On framework start if the log type is file, create the log file with reading instructions
if Config.Logs.AdvancedLog.type == "file" or Config.Logs.AdvancedLog.type == "both" then
    local log = io.open(GetResourcePath("utility_framework").."/logs/Utility_log_"..os.date("%y-%m-%d")..";"..logId..".txt", "a")
    log:write("[    Time] [CPUsec] [  Position] | [Message]\n--------------------------------------------\n")
    log:close()
end

Log = function(type, msg)
    if Config.Logs.AdvancedLog.type ~= "disabled" and (type == "DebugInfo" or (Config.Logs.AdvancedLog.actived[type] or false)) then
        if Config.Logs.AdvancedLog.type == "console" then
            print(string.format("[^3%s^0] %s", type, msg))

        elseif Config.Logs.AdvancedLog.type == "file" then
            local log = io.open(GetResourcePath("utility_framework").."/logs/Utility_log_"..currentDate..";"..logId..".txt", "a")
            log:write(string.format("[%8s] [%6d] [%10s] | %s", os.date("%X"), math.floor(os.clock()), type, msg).."\n")
            log:close()

        elseif Config.Logs.AdvancedLog.type == "both" then
            print(string.format("[^3%s^0] %s", type, msg))
            
            local log = io.open(GetResourcePath("utility_framework").."/logs/Utility_log_"..currentDate..";"..logId..".txt", "a")
            log:write(string.format("[%8s] [%6d] [%10s] | %s", os.date("%X"), math.floor(os.clock()), type, msg).."\n")
            log:close()
            
        end
    end
end

exports("Log", Log)

GetConfig = function(field)
    return field and Config[field] or Config
end

SetItemUsable = function(name)
    GlobalState["item_"..name] = true
end

RegisterSharedFunction = function(name)
    local sf = GlobalState.SharedFunction

    for i=1, #sf do
        if sf[i] == name then
            goto _return
        end
    end

    table.insert(sf, name)
    GlobalState.SharedFunction = sf

    ::_return::
    return nil
end
exports("RegisterSharedFunction", RegisterSharedFunction)

GetPreuPlayer = function(source)
    return setmetatable({}, {
        __index = function(_,k)
            local _uPlayer = GetPlayer(source)
            uPlayer = _uPlayer

            return _uPlayer[k]
        end
    })
end

-- ServerCallback
RegisterServerCallback = function(name, cb)
    local b64nameC = enc.Utf8ToB64(name)
    
    RegisterServerEvent(name)
    AddEventHandler(name, function(...)
        local source = source
        uPlayer = GetPreuPlayer(source)
        
        -- For make the return of lua works
        local _cb = table.pack(cb(...))
            
        if _cb ~= nil then -- If the callback is not nil
            TriggerClientEvent(b64nameC, source, _cb) -- Trigger the client event
        end
    end)
end


addon = function(name)
    local module = LoadResourceFile("utility_framework", "server/addons/"..name..".lua")
    
    if module then
        return load(module)()
    end
end

-- Other
table.copy = function(t)
    local copy = {}
    for k, v in pairs(t) do copy[k] = v end
    return copy
end

GetLabel = function(header, language, key)
    if language then
        if labels[header or "framework"] and labels[header or "framework"][language or defaultLanguage] then
            return labels[header or "framework"][language or defaultLanguage][key] or nil
        else
            return nil, "Header or language dont exist [Header = '"..header.."' Language = '"..(language or defaultLanguage).."']"
        end
    else
        if labels[header] then
            return labels[header][key] or nil
        else
            return nil
        end
    end
end

CompressWeapon = function(name)
    name = name:gsub("weapon_", "w")
    
    return name:lower()
end

DecompressWeapon = function(name)
    if name:sub(1, 1) == "w" then
        name = name:gsub("w"..name:sub(2, 2), "weapon_"..name:sub(2, 2))
    end
    
    return name:lower()
end

exports("CompressWeapon", CompressWeapon)
exports("DecompressWeapon", DecompressWeapon)


function CreateFile(path, data)
    local file = io.open(path, "a")
    file:write(data)
    file:close()
end

function CalculateItemWeight(name, quantity)
    local weight = (Config.Inventory.ItemWeight[name] or Config.Inventory.DefaultItemWeight)
    weight = (weight * quantity) -- Calculate the weight

    return weight
end

function ConvertTables(tab)
    for k,v in pairs(tab) do
        if type(v) == "string" then
            if v:find("{") or v:find("%[") then
                tab[k] = json.decode(v)
            end
        end
    end
end

function check(requested)
    if requested and type(requested) == "table" then
        local i = 0
        while true do
            i=i+1
            local name, value = debug.getlocal(2, i)
            if not name then break end

            if requested[name] then
                if type(value) ~= requested[name] then
                    error(name..": "..requested[name].." expected, got "..type(value))
                end
            end
        end
    
        return true
    end
end

function clone(tab)
    local new = {}
    for k, v in pairs(tab) do
        new[k] = v
    end
    return new
end

function merge(...)
    local args = ({...})
	local merged = {}

	for i = 1, #args do
        for k,v in pairs(args[i]) do
            merged[k] = v
        end
	end
	return merged
end

exports("Hook", function(uEntity, method, hook)
    local res = GetInvokingResource()

    if res then
        if not Utility.Hooks[uEntity] then Utility.Hooks[uEntity] = {} end
        if not Utility.Hooks[uEntity][method] then Utility.Hooks[uEntity][method] = {} end

        table.insert(Utility.Hooks[uEntity][method], {res, hook}) -- [res: string, hook: function]
    end
end)

exports("Unhook", function(uEntity, method)
    local res = GetInvokingResource()

    if res then
        if Utility.Hooks[uEntity] and Utility.Hooks[uEntity][method] then
            for k,v in pairs(Utility.Hooks[uEntity][method]) do
                if v[1] == res then
                    Utility.Hooks[uEntity][method][k] = nil
                end
            end
        end
    end
end)

function ExecuteHooks(uEntity, method, ...)
    if Utility.Hooks[uEntity] and Utility.Hooks[uEntity][method] then
        for i=1, #Utility.Hooks[uEntity][method] do
            local hook = Utility.Hooks[uEntity][method][i] -- [res: string, hook: function]

            local _return = hook[2](...)
            if _return then return _return end
        end
    end
end

-- Builders
IdentifyType = function(self)    
    if self.deposit then
        return "deposit"
    elseif self.trunk then
        return "trunk"
    elseif self.inventory then
        return "inventory"
    elseif self.items then
        return "items"
    end
end

CheckFilter = function(data, filter)
    local filterkeys = 0
    local foundkeys = 0
    
    for k,v in pairs(filter) do
        filterkeys = filterkeys + 1
        
        if data[k] == v or v == "any" then
            foundkeys = foundkeys + 1
        end
    end
    
    if filterkeys == foundkeys then
        return true
    else
        return false
    end
end

FindItem = function(name, inv, data)
    for i=1, #inv do
        if inv[i][1] == name then
            if data then
                if inv[i][3] and CheckFilter(inv[i][3], data) then
                    return inv[i], i
                end
            else
                return inv[i], i
            end
        end
    end

    return false
end

FindItems = function(name, inv, data)
    local items = {}

    for i=1, #inv do
        if inv[i][1] == name then
            if data then
                if inv[i][3] and CheckFilter(inv[i][3], data) then
                    table.insert(items, {inv[i], i})
                end
            else
                table.insert(items, {inv[i], i})
            end
        end
    end

    if next(items) then
        return items
    else 
        return false
    end
end

EmitEvent = function(name, source, ...)
    TriggerClientEvent("Utility:Emitter:"..name, source, ...)
    TriggerEvent("Utility:Emitter:"..name, source, ...)
end

GetName = function(self, type)
    if type == "inventory" then
        return self.name.." ("..self.source..")"
    elseif type == "trunk" then
        return self.plate
    elseif type == "deposit" then
        return self.name
    elseif type == "items" then
        return "stash:"..self.identifier
    end
end

GetuPlayerIdentifier = function(source)
    for k,v in pairs(GetPlayerIdentifiers(source))do                            
        if Config.Database.Identifier == "steam" and v:find("steam:") then
            return v
        elseif Config.Database.Identifier == "license" and v:find("license:") then
            return v
        end
    end
end

AddItemInternal = function(name, quantity, data, self)
    check({name = "string", quantity = "number"})

    local type = IdentifyType(self)
    local inv = self[type]
    local item = FindItem(name, inv, data)

    if not item then -- If dont exist
        table.insert(inv, {name, quantity, data})

        Log("Item", "Added "..quantity.." of '"..name.."' to "..GetName(self, type)..""..(data and " with data "..json.encode(data) or "").." [Dont exist, created]")
    else -- Already exist
        item[2] = item[2] + quantity

        Log("Item", "Added "..quantity.." of '"..name.."' to "..GetName(self, type)..""..(data and " with data "..json.encode(data) or "").." [Already exist, added]")
    end
    
    -- Weight calculation
    if Config.Inventory.Type == "weight" then
        local _weight = (Config.Inventory.ItemWeight[name] or Config.Inventory.DefaultItemWeight)
        self.weight = self.weight + (_weight * quantity)
    end
end

RemoveItemInternal = function(name, quantity, data, self)
    check({name = "string", quantity = "number"})

    local type = IdentifyType(self)
    local inv = self[type]
    local item, index = FindItem(name, inv, data)
    
    if not item then
        error("RemoveItem: The inventory \""..type.."\" dont have the item "..name)
        return
    end

    item[2] = item[2] - quantity

    if item[2] <= 0 then 
        table.remove(inv, index)
    end

    Log("Item", "Removed "..quantity.." of '"..name.."'"..(data and " with data "..json.encode(data) or "").." from "..GetName(self, type))

    -- Weight calculation
    if Config.Inventory.Type == "weight" then
        local _weight = (Config.Inventory.ItemWeight[name] or Config.Inventory.DefaultItemWeight)
        self.weight = self.weight - (_weight * quantity)
    end
end

GetItemInternal = function(name, data, inv)
    check({name = "string", inv = "table"})

    local item = FindItem(name, inv, data)
    return {
        quantity = item[2] or 0, 
        label = Config.Labels["items"][name] or name, 
        [Config.Inventory.Type] = Config.Inventory.ItemWeight[name] or Config.Inventory.DefaultItemWeight, 
        data = item[3] or {}, 
        __type = "item",

        found = item ~= false
    }
end

CanCarryItemInternal = function(item, quantity, self)
    local weight_limit = Config.Inventory.ItemWeight[name] or Config.Inventory.DefaultItemWeight

    if Config.Inventory.Type == "weight" then
        if (self.weight + (weight_limit * quantity)) > self.maxWeight then
            return false
        else
            return true
        end
    elseif Config.Inventory.Type == "limit" then
        local type = IdentifyType(self)
        local inv = self[type]
        local itemq = GetItemInternal(item, nil, inv)

        if (itemq + quantity) <= weight_limit then
            return true
        else
            return false
        end
    end
end

HaveItemQuantityInternal = function(name, quantity, data, inv)
    check({name = "string", quantity = "number", inv = "table"})

    local item = FindItem(name, inv, data)

    if item then
        return (item[2] >= quantity)
    else
        return nil
    end
end

--// Converters
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
                ".TriggerServerCallbackSync", 
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