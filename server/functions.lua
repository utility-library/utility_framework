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
            print(string.format("[^5%s^0] [^3%s^0] - %s", os.date("%X"), type, msg))

        elseif Config.Logs.AdvancedLog.type == "file" then
            local log = io.open(GetResourcePath("utility_framework").."/logs/Utility_log_"..currentDate..";"..logId..".txt", "a")
            log:write(string.format("[%8s] [%6d] [%10s] | %s", os.date("%X"), math.floor(os.clock()), type, msg).."\n")
            log:close()

        elseif Config.Logs.AdvancedLog.type == "both" then
            print(string.format("[^5%s^0] [^3%s^0] - %s", os.date("%X"), type, msg))
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

SetItemUsable = function(name, id)
    if id then
        GlobalState["item_"..name..":"..id] = true
    else
        GlobalState["item_"..name] = true
    end
end

RegisterSharedFunction = function(name)
    local sf = GlobalState.SharedFunction
    table.insert(sf, name)
    GlobalState.SharedFunction = sf
end

-- ServerCallback
RegisterServerCallback = function(name, _function)
    local b64nameC = "Utility:External:"..enc.Utf8ToB64("Utility_Callback:"..name.."_l")
    local b64nameS = "Utility:External:"..enc.Utf8ToB64("Utility_Callback:"..name)    

    RegisterServerEvent(b64nameS)
    AddEventHandler(b64nameS, function(...)
        local source = source
        source = source
        
        -- For make the return of lua works
        local _cb = table.pack(_function(...))

        TriggerClientEvent(b64nameC, source, table.unpack(_cb))
    end)
end


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