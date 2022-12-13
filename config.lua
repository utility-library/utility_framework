Config = {}

--// Basic
    Config.DefaultLanguage = "en" -- List of languages (https://developers.google.com/admin-sdk/directory/v1/languages)
    Config.Maintenance = false    -- Allow only player without the user group to join (so only admin or plus)
    Config.AutoUpdateFXVersion = true
    Config.GlobalSharedFunction = false -- Allow to use shared function in all script, not only in the script of the definition
    Config.GlobalSkin = true -- If set to true the skin of the player will be synchronized with ALL servers that have the utility framework, otherwise the skin will be unique for your server, will be used an id that you can find on files/server-identifier.utility that at the first start will be generated automatically, if you want you can share that id with your servers to have the player have the same skin between servers
    Config.TableCompression = "json" -- Compression method for tables, can be "json" or "msgpack" (msgpack its more efficient, ~30%, but its not modificable, it use binary format)
    Config.MissingFilterWarning = true -- If a trigger does not use a filter it will be written to the console, I do not recommend disabling this warning as it could result in basic security problems

    Config.ResourcesUpdater = {
        SyncRemoteRepository = true, -- Creates the .git directory so you can check for updates from github with the "utility update" command
        NeedUserInput = true, -- Requires user input to close the update cmd
    }

    Config.Database = {
        Identifier           = "steam", -- available: steam/license/xbl/discord
        CreateOnFirstStartup = false,    -- Create the database on the first startup of the server
        SaveNameInDb         = true,    -- Save the name of the player in the database
        MaxDaysPlayer        = -1,      -- If a player doesn't login for this amount of days or plus he will be automatically deleted from the database (if you want to disable this function set it to -1)

        --IfNewInstantSave    = true    -- If the player is new, save the data instantly (not recommended)
                                        -- (if it is true or false for the framework it doesn't change anything, so it is your choice)
    }

    Config.Start = {
        Position = vector4(-1037.66, -2737.75, 20.17, -29.65), -- x, y, z, heading
        Accounts = {
            cash  = 500,
            bank  = 10000,
            black = 0
        },
        Job = {
            [1] = {"unemployed", 1}
        },
        Items = { -- Starting items/inventory
            {"example", 2}


            -- If you have item data disabled comment the line 68 and uncomment the 74
            --["example"] = 1
        }
    }

    Config.Group = {
        ["steam:11000011525c3cc"] = "admin", -- XenoS
        ["steam:110000143bdfbd6"] = "admin", -- Starry
    }
--// Other
    Config.Societies = {
        "police"
    }

    -- if some filter fail the framework will run this function
    Config.FilterFail = function(source, eventName, filter, reason)
        if filter.Debug then -- if debugging
            print("[^4Debug^0] ^1filter check for event "..eventName.." called by "..source.." failed, reason: "..reason.."^0")
        else
            GetPlayer(source).Ban("filter returned false in the event "..eventName..", reason: "..reason.." [Auto Ban]")
        end
    end

    Config.Actived = {
        -- PlayerData/Database
        Vehicles = true, -- Active or no the uVehicle and the auto managment of vehicle trunk and other thing releated to the vehicles
        
        Accounts = true,
        Identity = true,
        Jobs = true,
        Inventory = true,
        License = true,
        Weapons = true,
        Coords = true,
        Bills = true,

        Salaries = true,

        Addons = {
            Weapon = true,
            Death = true -- Save the death status and call the Utility:OnDeath trigger when the player death
        },
        No_Rp = {
            KillDeath = false -- Save the death and the kill of the player
        },

        -- Other thing
        NoWeaponDrop = true, -- Disable the ped weapon drop

        DisableSoftVehicleRewards = true, -- Disable rewards from any vehicles (soft mode)
        DisableHardVehicleRewards = false, -- Disable rewards from any vehicles (hard mode, more precise but more weight +0.02ms)

        Pvp = true, -- Enable or disable the pvp system
        SaveArmour = true,
    }

    Config.CustomEmitter = {
        "Interaction",
    }

    Config.PrintType = {
        ["attention"] = "[^3ATTENTION^0] ",
        ["startup"]   = "[^4STARTUP^0] ",
        ["new"]       = "[^2NEW^0] ",
        ["old"]       = "[^3OLD^0] ",
        ["error"]       = "[^1ERROR^0] ", -- (we hope we never see it!)
    }

    Config.BlacklistedDrawable = {
        ["torso_1"] = {
            10
        }
    }