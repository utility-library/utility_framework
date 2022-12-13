local server_identifier = LoadResourceFile("utility_framework", "files/server-identifier.utility") 
local currentDate = os.date("%y-%m-%d")
local logId = math.random(0, 999)

-- Log
    -- On framework start if the log type is file, create the log file with reading instructions
    if Config.Logs.AdvancedLog.type == "file" or Config.Logs.AdvancedLog.type == "both" then
        local log = io.open(GetResourcePath("utility_framework").."/logs/Utility_log_"..os.date("%y-%m-%d")..";"..logId..".txt", "a")
        log:write("[    Time] [CPUsec] [  Position] | [Message]\n--------------------------------------------\n")
        log:close()
    end

    Log = function(type, msg)
        local info = debug.getinfo(2,'S');
        local fileName = info.source:match("[^/]*.lua$")
        msg = "["..fileName:sub(0, #fileName - 4).."] "..msg

        if Config.Logs.AdvancedLog.type ~= "disabled" and (type == "DebugInfo" or (Config.Logs.AdvancedLog.actived[type])) then
            if Config.Logs.AdvancedLog.type == "console" or Config.Logs.AdvancedLog.type == "both" then
                print(string.format("[^3%s^0] %s", type, msg))
            end
            
            if Config.Logs.AdvancedLog.type == "file" or Config.Logs.AdvancedLog.type == "both" then
                local log = io.open(GetResourcePath("utility_framework").."/logs/Utility_log_"..currentDate..";"..logId..".txt", "a")
                log:write(string.format("[%8s] [%6d] [%10s] | %s", os.date("%X"), math.floor(os.clock()), type, msg).."\n")
                log:close()
            end
        end
    end

    exports("Log", Log)

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

    RegisterSharedFunction = function(name)
        local sf = GlobalState.SharedFunction
    
        for i=1, #sf do
            if sf[i] == name then
                return
            end
        end
    
        table.insert(sf, name)
        GlobalState.SharedFunction = sf
    end
    exports("RegisterSharedFunction", RegisterSharedFunction)

-- Weapon compression
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

-- Table extensions
    clone = function(tab)
        local new = {}
        for k, v in pairs(tab) do
            new[k] = v
        end
        return new
    end

    merge = function(...)
        local args = ({...})
        local merged = {}

        for i = 1, #args do
            for k,v in pairs(args[i]) do
                merged[k] = v
            end
        end
        return merged
    end

-- Hooks
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

    ExecuteHooks = function(uEntity, method, ...)
        if Utility.Hooks[uEntity] and Utility.Hooks[uEntity][method] then
            for i=1, #Utility.Hooks[uEntity][method] do
                local hook = Utility.Hooks[uEntity][method][i] -- [res: string, hook: function]

                local _return = hook[2](...)
                if _return then return _return end
            end
        end
    end

-- Internal functions for working with inventories
    CalculateItemWeight = function(name, quantity)
        local weight = (Config.Inventory.ItemWeight[name] or Config.Inventory.DefaultItemWeight)
        weight = (weight * quantity) -- Calculate the weight

        return weight
    end

    IdentifyType = function(self)    
        if self.deposit then
            return "deposit"
        elseif self.trunk then
            return "trunk"
        elseif self.inventory then
            return "inventory"
        elseif self.datas.items then
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
        
        return filterkeys == foundkeys
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

    GetName = function(self, type)
        if type == "inventory" then
            return self.name.." ("..self.source..")"
        elseif type == "trunk" then
            return self.plate
        elseif type == "deposit" then
            return self.name
        elseif type == "items" then
            return self.identifier
        end
    end


    AddItemInternal = function(name, quantity, data, self)
        check({name = "string", quantity = "number"})

        local type = IdentifyType(self)
        local inv = self[type]

        if type == "items" then
            inv = self.datas[type]
        end

        local item = FindItem(name, inv, data)

        if not item then -- If dont exist
            table.insert(inv, {name, quantity, data})

            Log("Item", " [Internal] Added "..quantity.." of '"..name.."' to "..GetName(self, type)..""..(data and " with data "..json.encode(data) or "").." [Dont exist, created]")
        else -- Already exist
            item[2] = item[2] + quantity

            Log("Item", " [Internal] Added "..quantity.." of '"..name.."' to "..GetName(self, type)..""..(data and " with data "..json.encode(data) or "").." [Already exist, added]")
        end
        
        -- Weight calculation
        if Config.Inventory.Type == "weight" then
            local _weight = (Config.Inventory.ItemWeight[name] or Config.Inventory.DefaultItemWeight)
            self.weight = self.weight + (_weight * quantity)
        end
    end

    RemoveItemInternal = function(name, quantity, data, self)
        check({name = "string", quantity = "number"})

        if quantity < 1 then
            error("RemoveItem: Tried to remove a negative number (result: AddItem)")
            return
        end

        local type = IdentifyType(self)
        local inv = self[type]
        
        if type == "items" then
            inv = self.datas[type]
        end

        local item, index = FindItem(name, inv, data)
        
        if not item then
            error("RemoveItem: The inventory \""..type.."\" dont have the item "..name)
            return
        end

        item[2] = item[2] - quantity

        if item[2] <= 0 then 
            table.remove(inv, index)
        end

        Log("Item", " [Internal] Removed "..quantity.." of '"..name.."'"..(data and " with data "..json.encode(data) or "").." from "..GetName(self, type))

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
            usable = GlobalState["item_"..name],
            
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

            if type == "items" then
                inv = self.datas[type]
            end

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

-- Others
    addon = function(name)
        local module = LoadResourceFile("utility_framework", "server/addons/"..name..".lua")
        
        if module then
            return load(module)()
        end
    end

    table.copy = function(t)
        local copy = {}
        for k, v in pairs(t) do copy[k] = v end
        return copy
    end

    GetPreuPlayer = function(source)
        return setmetatable({}, {
            __index = function(_,k)
                local _uPlayer = GetPlayer(source)
                uPlayer = _uPlayer
    
                return _uPlayer[k]
            end
        })
    end

    GetConfig = function(field)
        return field and Config[field] or Config
    end
    
    SetItemUsable = function(name)
        GlobalState["item_"..name] = true
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

    CreateFile = function(path, data)
        local file = io.open(path, "a")
        file:write(data)
        file:close()
    end

    check = function(requested)
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

    DecodeJsonTables = function(tab)
        for k,v in pairs(tab) do
            if type(v) == "string" then
                if v:find("{") or v:find("%[") then
                    tab[k] = Config.TableCompression == "msgpack" and msgpack.unpack(v) or json.decode(v)
                end
            end
        end
    end

    EmitEvent = function(name, source, ...)
        TriggerClientEvent("Utility:Emitter:"..name, source, ...)
        TriggerEvent("Utility:Emitter:"..name, source, ...)
    end

    GetuPlayerIdentifier = function(source)
        for k,v in pairs(GetPlayerIdentifiers(source))do                            
            if v:find(Config.Database.Identifier..":") then
                return v
            end
        end
    end

    GetServerIdentifier = function()
        return server_identifier
    end
    exports("GetServerIdentifier", GetServerIdentifier)