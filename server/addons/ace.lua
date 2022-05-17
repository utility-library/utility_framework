local old_type = type
type = function(var)
    if old_type(var) == "table" then
        if var.UtilityGroup then
            return "ut_group"
        end
    end

    return old_type(var)
end

--[[
local old_ExecuteCommand = ExecuteCommand

ExecuteCommand = function(command)
    print("[^4ACE^0] Executing command: "..command)
    old_ExecuteCommand(command)
end
]]

local self = {
    CreateGroup = function(name, permission)
        local group = {
            UtilityGroup = true,
            name = name,
            permission = permission,

            add = function(self, child)
                ExecuteCommand("add_principal "..child.." ut_group."..name)
            end,
            remove = function(self, child)
                ExecuteCommand("remove_principal "..child.." ut_group."..name)
            end,
        }

        for k,v in pairs(permission) do
            ExecuteCommand("add_ace ut_group."..name.." "..k.." "..(v and "allow" or "deny"))
        end

        return group
    end,
    SetGroupPermission = function(group, permission)
        for k,v in pairs(permission) do
            ExecuteCommand("add_ace ut.group"..group.name.." "..k.." "..(v and "allow" or "deny"))
            group.permission[k] = v
        end
    end,
    SetChildPermission = function(child, permission)
        for k, v in pairs(permission) do
            ExecuteCommand("add_ace "..child.." "..k.." "..(v and "allow" or "deny"))
        end
    end,
    SetPlayerPermission = function(identifier, permission)
        if type(identifier) == "string" then
            for k,v in pairs(permission) do
                ExecuteCommand("add_ace identifier."..identifier.." "..k.." "..(v and "allow" or "deny"))
            end
        else
            identifier = GetPlayerIdentifier(identifier, 1)

            for k,v in pairs(permission) do
                ExecuteCommand("add_ace identifier."..identifier.." "..k.." "..(v and "allow" or "deny"))
            end
        end
    end
}

return self