Config = {}

--// Basic
    Config.DefaultLanguage = "en" -- List of languages (https://developers.google.com/admin-sdk/directory/v1/languages)
    Config.Maintenance = false    -- Allow only player without the user group to join (so only admin or plus)
    Config.AutoUpdateFXVersion = true
    Config.GlobalSharedFunction = false -- Allow to use shared function in all script, not only in the script of the definition
    Config.SendBetaDebug = true -- Send beta information to the developer to help improve the framework


    Config.Database = {
        CreateOnFirstStartup = false,    -- Create the database on the first startup of the server
        SaveNameInDb         = true,    -- Save the name of the player in the database
        MaxDaysPlayer        = -1,      -- If a player doesn't login for this amount of days or plus he will be automatically deleted from the database (if you want to disable this function set it to -1)

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
            {"example", 2}


            -- If you have item data disabled comment the line 68 and uncomment the 74
            --["example"] = 1
        }
    }

    Config.Group = {
        ["steam:11000011525c3cc"] = "admin", -- xenos
        ["steam:11000011cd5a037"] = "admin", -- markz
        ["steam:11000013e487dbd"] = "admin", -- baffi
        ["steam:110000116af8ccd"] = "admin", -- coliandro
        ["steam:11000014525429a"] = "admin", -- si3mone
        ["steam:110000110784a30"] = "admin", -- freez
        ["steam:11000010b282d87"] = "admin", -- commander
        ["steam:11000010e44d76f"] = "admin"
    }
--// Other


    Config.TriggerBasicProtection = {
        AutoBan = true, -- If someone try to exploit our protection instantly ban it
        Pos = 10 -- DONT TOUCH THIS [utfw_enc_pos]
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
        NoWeaponDrop = true, -- Disable the ped weapon drop

        DisableSoftVehicleRewards = true, -- Disable rewards from any vehicles (soft mode)
        DisableHardVehicleRewards = false, -- Disable rewards from any vehicles (hard mode, more precise but more weight +0.02ms)

        Pvp = true, -- Enable or disable the pvp system
        SaveArmour = true,
    }

    Config.CustomEmitter = {
        "Interaction",
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

    Config.BlacklistedDrawable = {
        ["torso_1"] = {
            10
        }
    }