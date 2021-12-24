Config = {}

--// Basic
    Config.DefaultLanguage = "en" -- List of languages (https://developers.google.com/admin-sdk/directory/v1/languages)
    Config.Maintenance = false    -- Allow only player without the user group to join (so only admin or plus)

    -- Here you can setup and enable the autorestart of the server (if you dont have txadmin)
    Config.AutoRestart = {
        program = "FXServer.exe",   -- If you use a start.bat insert the name of the start file here
        times = {},                 -- 24h format (leave {} to disable the autorestart feature)
        timeout = 10,               -- This is the timeout after the server will restart after its turned off
        deletecache = false,        -- Clean the cache during an autorestart (delete the cache folder from the main directory, can make damage!)
        databasebackup = "utility"  -- Create a database backup in the DatabaseBackup folder in the desktop, insert your database name, works ONLY WITH XAMPP why it use the default xampp directory to connect with MySQL, leave "" to disable it
    }

    Config.Database = {
        CreateOnFirstStartup = true,    -- Create the database on the first startup of the server
        SaveNameInDb         = true,    -- Save the name of the player in the database
        --IfNewInstantSave    = true    -- If the player is new, save the data instantly (not recommended)
                                        -- (if it is true or false for the framework it doesn't change anything, so it is your choice)
    }

    Config.Start = {
        Position = vector4(-1037.66, -2737.75, 20.17, -29.65), -- x, y, z, heading
        Accounts = {
            ["cash"]  = 500,
            ["bank"]  = 10000,
            ["black"] = 0
        },
        Job = {
            [1] = {"unemployed", 1}
        },
        Items = { -- Starting items/inventory
            ["example"] = {
                nodata = {[1] = 100}
            }


            -- If you have item data disabled comment the line 68 and uncomment the 74
            --["example"] = 1
        }
    }

    Config.Group = {
        ["steam:11000011525c3cc"] = "admin", -- Example
    }
--// Other


    Config.TriggerBasicProtection = {
        AutoBan = true -- If someone try to exploit our protection instantly ban it
    } 

    Config.Actived = {
        -- PlayerData/Database
        VehiclesData = true, -- Active or no the uVehicle and the auto managment of vehicle trunk and other thing releated to the vehicles
        License = true,
        Jobs = true,
        Salaries = true,
        Accounts = true,
        Inventory = true,
        Identity = true,
        Other_info = {
            Position = true,
            Weapon = true,
            Death = true -- Save the death status and call the Utility:OnDeath trigger when the player death
        },
        No_Rp = {
            KillDeath = false -- Save the death and the kill of the player
        },

        -- Other thing
        ItemData = true, -- You can set data for any item (aka item metadata) [UNDER DEVELOPING, SOCIETY DEPOSIT AND TRUNK DONT SAVE ITEMDATA]
        NoWeaponDrop = false, -- Disable the ped weapon drop
        DisableVehicleRewards = false, -- Disable the reward from the vehicle (+0.04 ms)
        Pvp = true, -- Enable or disable the pvp system
        SaveArmour = true,
    }

    Config.Accounts = {
        [1] = "cash",
        [2] = "bank",
        [3] = "black",
    }
    
    -- this is all the identity data, DONT TOUCH IF YOU DONT KNOW WHAT YOU ARE DOING --
    Config.Identity = { -- The assignment is asigned by the index, so dont remove anything if the server is already started
        [1] = "firstname",
        [2] = "lastname",
        [3] = "dateofbirth",
        [4] = "sex",
        [5] = "height"
    }

    Config.PrintType = {
        ["attention"] = "[^3ATTENTION^0] ",
        ["startup"]   = "[^4STARTUP^0] ",
        ["new"]       = "[^2NEW^0] ",
        ["old"]       = "[^3OLD^0] ",
    }