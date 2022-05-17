local uPlayer = class {
    identity = {},
    inventory = {},
    jobs = {},
    accounts = {},
    licenses = {},
    weapons = {},
    coords = {},
    external = {},
    bills = {},
    vehicles  = {},
    societyvehicles  = {},
    group = "user",
    identifier = "",
    ToSave = false,



    _Init = function(self)
        if Config.Database.Identifier == "steam" then
            if not self.identifier:find(":") then
                self.identifier = "steam:110000"..self.identifier
            end

            self.uidentifier = self.identifier:gsub("steam:110000", "")
        else
            if not self.identifier:find(":") then
                self.identifier = "license:"..self.identifier
            end

            self.uidentifier = self.identifier:gsub("license:", "")
        end
        
        ConvertTables(self)
        
        if not self.coords then
            self.coords = {Config.Start.Position.x, Config.Start.Position.y, Config.Start.Position.z}
        end
        self.group = uPlayerExistInAGroup(self.identifier)
        -- Set isdead to false (if not set)
        if self.external.isdead == nil then self.external.isdead = false end

        -- Decompress weapons
        for k,v in pairs(self.weapons) do    
            if k:find("weapon_") or k:find("gadget_") then
                self.weapons[CompressWeapon(k)] = v
                self.weapons[k] = nil
            end
        end

        --self:PreBuild(self)
        Utility.PlayersData[self.identifier] = self
    end,

    PreBuild = function(self)
        local start = os.clock()

        self.__type = "preuPlayer"
        self = uPlayerCreateMethods(self)
        
        Log("Building", "Server uPlayer builded for "..self.identifier.." in "..((os.clock() - start)*1000).." ms")

        Utility.PlayersData[self.identifier] = self
    end,

    Build = function(self, id)
        local start = os.clock()

        self.__type = "uPlayer"
        self.source = id
        self = uPlayerBuildJobs(self)
        self = uPlayerBuildInventory(self)

        ---

        -- Build owned vehicles
        for k,v in pairs(Utility.VehiclesData) do
            if v.owner == self.identifier then
                table.insert(self.vehicles, v)
            end
        end

        -- Build owned society vehicles
        for k,v in pairs(Utility.VehiclesData) do
            for i=1, #self.jobs do
                if v.owner == "society:"..self.jobs[i].name then
                    table.insert(self.societyvehicles, v)
                end
            end
        end

        ---


        Log("Building", "Client uPlayer builded for "..self.identifier.." in "..((os.clock() - start)*1000).." ms")

        Utility.PlayersData[self.identifier] = self
    end,

    Client = function(self)
        return GetClientPlayer(self.source)
    end,
        
    Demolish = function(self)
        Log("Building", "uPlayer "..self.identifier.." has been demolished")

        for i=1, #self.jobs do
            RemoveFromJob(self.jobs[i].name, self.source)
        end

        Utility.PlayersData[self.identifier] = {
            name            = self.name,
            identifier      = self.identifier,
            uidentifier     = self.uidentifier,
            identity        = self.identity,
            inventory       = self.inventory,
            jobs            = self.jobs,
            accounts        = self.accounts,
            bills           = self.bills,
            vehicles        = self.vehicles,
            societyvehicles = self.societyvehicles,
            group           = self.group,

            licenses        = self.licenses,
            weapons         = self.weapons,
            coords          = self.coords,
            external        = self.external,

            -- Methods  
            Client          = self.Client,
            Build           = self.Build,
            PreBuild        = self.PreBuild,
            Demolish        = self.Demolish,
            IsBuilded       = self.IsBuilded,

            ToSave = true
        }
    end,

    IsBuilded = function(self)
        return self.__type == "uPlayer"
    end,
}

local steamCache = {}
GetPlayer = function(identifier)
    if type(identifier) == "string" then
        return Utility.PlayersData[identifier]
    else
        if identifier == 0 then
            return nil
        end

        if not steamCache[identifier] then
            steamCache[identifier] = GetuPlayerIdentifier(identifier)
        end

        return Utility.PlayersData[steamCache[identifier]]
    end
end

GetUtilityPlayers = function()
    local players = {}
    
    for k,v in pairs(Utility.PlayersData) do
        if v:IsBuilded() then -- Only return builded players (online)
            local v2 = {}

            -- Clone table
            for k,v in pairs(v) do v2[k] = v end

            -- Remove methods to improve performance
            for k,v in pairs(v2) do
                if type(v) == "function" then v2[k] = nil end
            end

            table.insert(players, v2)
        end
    end

    return players
end

GetClientPlayer = function(id)
    local player = Player(id).state
    
    local metatable = {
        state = player,
        __newindex = function(self, index, new)
            player[index] = new
            Utility.PlayersData[player.identifier][index] = new

            --print("Setting \""..tostring(index).."\" to \""..tostring(new).."\" for "..id)
        end,
        setexternal = function(k, v)
            local oi = player.external
            oi[k] = v

            player.external = oi
            Utility.PlayersData[player.identifier].external[k] = v
            --print("Setting external \""..tostring(k).."\" to \""..tostring(v).."\" for "..id)
        end
    }

    return setmetatable({}, metatable)
end


LoadPlayers = function()
    local users = MySQL.Sync.fetchAll("SELECT identifier, name, accounts, identity, jobs, inventory, licenses, weapons, coords, last_quit, external FROM users", {})
    if users == nil then error("Unable to connect with the table `users`, try to check the MySQL status!") return end

    for i=1, #users do
        local skip = false

        if users[i].last_quit then
            local lastq_year, lastq_month, lastq_day = users[i].last_quit:sub(0, 4), users[i].last_quit:sub(6, 7), users[i].last_quit:sub(9, 10)
            local last_quit = os.time{year = lastq_year, month = lastq_month, day = lastq_day}
            local daysfrom = os.difftime(os.time(), last_quit) / (24 * 60 * 60)
            daysfrom = math.floor(daysfrom)
    
            if Config.Database.MaxDaysPlayer > 0 and daysfrom >= Config.Database.MaxDaysPlayer then
                local file = io.open(GetResourcePath(GetCurrentResourceName()).."/files/PlayersFrozen.json", "a")
                file:write(json.encode(users[i]))
                file:close()
    
                skip = true
                MySQL.Async.execute("DELETE FROM users WHERE identifier = :identifier", {identifier = users[i].identifier})
            end
        end

        if not skip then
            uPlayer({
                identifier = users[i].identifier,
                name = users[i].name,
                accounts = users[i].accounts,
                identity = users[i].identity,
                jobs = users[i].jobs,
                inventory = users[i].inventory,
                licenses = users[i].licenses,
                weapons = users[i].weapons,
                coords = users[i].coords,
                external = users[i].external,
                bills = users[i].bills
            })
        end
    end

    return #users
end


GeneratePlayer = function(id, identifier)
    -- Convert the generated data like a player loaded from the database
    local options = {
        identifier = identifier,
        coords     = {Config.Start.Position.x, Config.Start.Position.y, Config.Start.Position.z},
        name       = GetPlayerName(id),
        inventory  = Config.Start.Items or {},
        accounts   = {},
        jobs       = {},
        inventory  = {},
        identity   = {},
        isNew      = true,
    }

    -- Create the player datas
    -- Accounts
    if Config.Actived.Accounts then
        for i=1, #Config.Accounts do
            options.accounts[i] = Config.Start.Accounts[Config.Accounts[i]]
        end
    end

    -- Jobs
    if Config.Actived.Jobs then
        for i=1, #Config.Start.Job do
            options.jobs[i] = {
                [1] = Config.Start.Job[i][1],
                [2] = Config.Start.Job[i][2],
                [3] = true,
            }
        end
    end

    -- Identity
    if Config.Actived.Identity then
        for i=1, #Config.Identity do
            options.identity[i] = ""
        end
    end
    
    return uPlayer(options)
end