Config = {}

--// Basic
    Config.DefaultLanguage = "en" -- List of languages (https://developers.google.com/admin-sdk/directory/v1/languages)
    Config.Maintenance = false    -- Allow only player without the user group to join
    
    -- 24h format, set it to {} to disable it
    Config.AutoRestart = {
        program = "FXServer.exe", -- If you use a start.bat insert the name of the start file here
        times = {},
        timeout = 10,
        deletecache = false,
        databasebackup = "utility" -- ONLY XAMPP, leave "" to disable it
    }

    Config.Logs = {
        Connection = {
            NewUser = true, -- Print "[NEW] User <PLAYER_NAME> connected!" if the player is new
            OldUser = true  -- Print "[OLD] User <PLAYER_NAME> connected!" if the player already exist in the database
        },
        Trigger = {
            Registered = false, -- Print any trigger registered from external resource with the loader and the relative encrypted trigger name
            Called     = false  -- Log any trigger call with the relative id that call that trigger
        },

        AdvancedInfo = "file" -- file/console/both/disabled
    }

    Config.Database = {
        AutoTurnOnXampp = true,     -- If you have xampp the framework can automatically turn it on if is offline (with mysql service started)
        CheckIfExistOnStart = true,
        SaveNameInDb = false,
        IfNewInstantSave = false    -- [TRUE]  When a new player connects it is immediately inserted in the table in the database (it makes 1 more query) 
                                    -- [FALSE] The player will be saved in the database only when it quits
                                    -- (if it is true or false for the framework it doesn't change anything, so it is your choice if you want it to save instantly or not)
    }

    Config.Start = {
        Position = vector4(0.0, 0.0, 50.0, 0.0),
        Accounts = {
            ["cash"]  = 0,
            ["bank"]  = 0,
            ["black"] = 0
        },
    }

--// Other
    Config.Group = {
        ["steam:11000011525c3cc"] = "admin", -- Example
    }

    Config.Addons = {
        DisableExplosion             = true,  -- Disable explosion, only the client that created that explosion can see it (can prevent nuke of the server)
        PermanentObject              = true,  -- Since the "permanent_obj" addon also requires code that works on the framework to make it work you have to enable this setting
        Animation                    = {
            crouch = true,
            handsup = true,
            faint = true,
        }
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
        ItemData = true, -- You can set data for any item (aka item metadata)
        NoWeaponDrop = true, -- Disable the ped weapon drop
        DisableVehicleRewards = true, -- Disable the reward from the vehicle
        Pvp = true, -- Pvp between players
        SaveArmour = true,
    }

    Config.Jobs = {
        -- This is the default primary job, if you want you can add every job you want like the second job or the third
        -- ISNT EQUAL TO JOBS TABLE OF ESX (the jobs are all dynamical so dont need to be defined, this is like the gang or the org/job_2)
        Quantity = {
            [1] = {
                name   = "unemployed", 
                grade  = 1
            }
        },
        Configuration = {
            ["unemployed"] = {
                name = "Unemployed",
                grades = {
                    [1] = {
                        label  = "",
                        salary = 0,
                        boss   = false
                    },
                }
            }
        },
   
        SalariesInterval = "5m", -- you can use: "s", "m" or "ms"
    }

    Config.Identity = {
        "firstname",
        "lastname",
        "dateofbirth",
        "sex",
        "height"
    }

    Config.Inventory = {
        type        = "weight", -- Can be changed even if the server is already started (in the sense that there are already players playing on it)
                                -- available type: weight, limit

        max         = 300,      -- The maximum weight a player can carry (only weight)
        defaultitem = 5,        -- If the item does not exist in the list below it will have this weight/limit (weight/limit)
        itemdata    = {         -- The list of the limit for any item or the weight of any item (weight/limit)
            ["example"] = 10
        }
    }

    -- Translations
    Config.PrintType = {
        ["attention"] = "[^3ATTENTION^0] ",
        ["startup"]   = "[^4STARTUP^0] ",
        ["new"]       = "[^2NEW^0] ",
        ["old"]       = "[^3OLD^0] ",
    }

    Config.Labels = {
        ["weapon"] = {
            ['weapon_knife'] = 'Coltello',
            ['weapon_nightstick'] = 'Manganello',
            ['weapon_hammer'] = 'Martello',
            ['weapon_bat'] = 'Katana',
            ['weapon_golfclub'] = 'Ariete',
            ['weapon_crowbar'] = 'Piede di porco',
            ['weapon_pistol'] = 'Pistola',
            ['weapon_combatpistol'] = 'Pistola da combattimento',
            ['weapon_appistol'] = 'Pistola AP',
            ['weapon_pistol50'] = 'Pistola calibro .50',
            ['weapon_microsmg'] = 'micro SMG',
            ['weapon_smg'] = 'MP5',
            ['weapon_assaultsmg'] = 'SMG D\'assalto',
            ['weapon_assaultrifle'] = 'Fucile d\'assalto',
            ['weapon_carbinerifle'] = 'Carabina',
            ['weapon_advancedrifle'] = 'Fucile avanzato',
            ['weapon_mg'] = 'MG',
            ['weapon_combatmg'] = 'MG da combattimento',
            ['weapon_pumpshotgun'] = 'Fucile a pompa',
            ['weapon_sawnoffshotgun'] = 'sawed off shotgun',
            ['weapon_assaultshotgun'] = 'Pompa d\'assalto',
            ['weapon_bullpupshotgun'] = 'Pompa bullpup',
            ['weapon_stungun'] = 'Taser',
            ['weapon_sniperrifle'] = 'Fucile di precisione',
            ['weapon_heavysniper'] = 'Cecchino pesante',
            ['weapon_grenadelauncher'] = 'Lancia granate',
            ['weapon_rpg'] = 'Lanciarazzi',
            ['weapon_stinger'] = 'Stinger',
            ['weapon_minigun'] = 'Minigun',
            ['weapon_grenade'] = 'Granata',
            ['weapon_stickybomb'] = 'Bomba appiccicosa',
            ['weapon_smokegrenade'] = 'Fumogeno',
            ['weapon_bzgas'] = 'Bomba gas',
            ['weapon_molotov'] = 'Molotov',
            ['weapon_fireextinguisher'] = 'Estintore',
            ['weapon_petrolcan'] = 'Tanica di benzina',
            ['weapon_digiscanner'] = 'digi scanner',
            ['weapon_ball'] = 'Palla',
            ['weapon_snspistol'] = 'Pistola sns',
            ['weapon_bottle'] = 'Bottiglia',
            ['weapon_gusenberg'] = 'Gusenberg a tamburo',
            ['weapon_specialcarbine'] = 'Carabina speciale',
            ['weapon_heavypistol'] = 'Pistola pesante',
            ['weapon_bullpuprifle'] = 'Fucile a pompa bullpup',
            ['weapon_dagger'] = 'Pugnale',
            ['weapon_vintagepistol'] = 'Pistola antica',
            ['weapon_firework'] = 'Fuoco d\'artificio',
            ['weapon_musket'] = 'Moschetto',
            ['weapon_heavyshotgun'] = 'Fucile pesante',
            ['weapon_marksmanrifle'] = 'Fucile da tiratore',
            ['weapon_hominglauncher'] = 'Lanciarazzi a ricerca',
            ['weapon_proxmine'] = 'Mina di prossimità',
            ['weapon_snowball'] = 'Palla di neve',
            ['weapon_flaregun'] = 'Pistola lanciarazzi',
            ['weapon_garbagebag'] = 'Busta della spazzatura',
            ['weapon_handcuffs'] = 'Manette',
            ['weapon_combatpdw'] = 'Beretta M12',
            ['weapon_marksmanpistol'] = 'Pistola da tiratore',
            ['weapon_knuckle'] = 'Tirapugni',
            ['weapon_hatchet'] = 'Accetta',
            ['weapon_railgun'] = 'railgun',
            ['weapon_machete'] = 'Macete',
            ['weapon_machinepistol'] = 'Mitragliatrice',
            ['weapon_switchblade'] = 'Coltello a scatto',
            ['weapon_revolver'] = 'Revolver pesante',
            ['weapon_dbshotgun'] = 'Fucile a doppia canna',
            ['weapon_compactrifle'] = 'Fucile compatto',
            ['weapon_autoshotgun'] = 'Fucile automatico',
            ['weapon_battleaxe'] = 'Ascia da battaglia',
            ['weapon_compactlauncher'] = 'Lanciatore compatto',
            ['weapon_minismg'] = 'Mini smg',
            ['weapon_pipebomb'] = 'pipe bomb',
            ['weapon_poolcue'] = 'Stecca da biliardo',
            ['weapon_wrench'] = 'Chiave inglese',
            ['weapon_flashlight'] = 'Torcia',
            ['gadget_nightvision'] = 'Visore notturno',
            ['gadget_parachute'] = 'Paracadute',
            ['weapon_flare'] = 'Pistola lanciarazzi',
            ['weapon_doubleaction'] = 'Revolver a doppia azione',
        },

        ["accounts"] = {
            ["cash"]  = "Cash",
            ["bank"]  = "Bank",
            ["black"] = "Black Money",
        },

        ["items"] = {
            ["example"] = "example"
        },

        ["license"] = {
            ["drivelicense"] = "Driving license"
        },

        ["skin"] = {
            ["export"] = "Export skin",
            ["import"] = "Import skin",
            ['face'] = 'face',
            ['skin'] = 'skin',
            ['wrinkles'] = 'wrinkles',
            ['wrinkle_thickness'] = 'wrinkle thickness',
            ['beard_type'] = 'beard type',
            ['beard_size'] = 'beard size',
            ['beard_color_1'] = 'beard color 1',
            ['beard_color_2'] = 'beard color 2',
            ['hair_1'] = 'hair 1',
            ['hair_2'] = 'hair 2',
            ['hair_color_1'] = 'hair color 1',
            ['hair_color_2'] = 'hair color 2',
            ['eye_color'] = 'eye color',
            ['eyebrow_type'] = 'eyebrow type',
            ['eyebrow_size'] = 'eyebrow size',
            ['eyebrow_color_1'] = 'eyebrow color 1',
            ['eyebrow_color_2'] = 'eyebrow color 2',
            ['makeup_type'] = 'makeup type',
            ['makeup_thickness'] = 'makeup thickness',
            ['makeup_color_1'] = 'makeup color 1',
            ['makeup_color_2'] = 'makeup color 2',
            ['lipstick_type'] = 'lipstick type',
            ['lipstick_thickness'] = 'lipstick thickness',
            ['lipstick_color_1'] = 'lipstick color 1',
            ['lipstick_color_2'] = 'lipstick color 2',
            ['ear_accessories'] = 'ear accessories',
            ['ear_accessories_color'] = 'ear accessories color',
            ['tshirt_1'] = 't-Shirt 1',
            ['tshirt_2'] = 't-Shirt 2',
            ['torso_1'] = 'torso 1',
            ['torso_2'] = 'torso 2',
            ['decals_1'] = 'decals 1',
            ['decals_2'] = 'decals 2',
            ['arms'] = 'arms',
            ['arms_2'] = 'arms 2',
            ['pants_1'] = 'pants 1',
            ['pants_2'] = 'pants 2',
            ['shoes_1'] = 'shoes 1',
            ['shoes_2'] = 'shoes 2',
            ['mask_1'] = 'mask 1',
            ['mask_2'] = 'mask 2',
            ['bproof_1'] = 'bulletproof vest 1',
            ['bproof_2'] = 'bulletproof vest 2',
            ['chain_1'] = 'chain 1',
            ['chain_2'] = 'chain 2',
            ['helmet_1'] = 'helmet 1',
            ['helmet_2'] = 'helmet 2',
            ['watches_1'] = 'watches 1',
            ['watches_2'] = 'watches 2',
            ['bracelets_1'] = 'bracelets 1',
            ['bracelets_2'] = 'bracelets 2',
            ['glasses_1'] = 'glasses 1',
            ['glasses_2'] = 'glasses 2',
            ['bag'] = 'bag',
            ['bag_color'] = 'bag color',
            ['blemishes'] = 'blemishes',
            ['blemishes_size']= 'blemishes thickness',
            ['ageing'] = 'ageing',
            ['ageing_1'] = 'ageing thickness',
            ['blush'] = 'blush',
            ['blush_1'] = 'blush thickness',
            ['blush_color'] = 'blush color',
            ['complexion'] = 'complexion',
            ['complexion_1'] = 'complexion thickness',
            ['sun'] = 'sun',
            ['sun_1'] = 'sun thickness',
            ['freckles'] = 'freckles',
            ['freckles_1'] = 'freckles thickness',
            ['chest_hair'] = 'chest hair',
            ['chest_hair_1'] = 'chest hair thickness',
        },

        -- Framework Translation
        ["framework"] = {
            ['WelcomeMsg']       = "Welcome to the Utility Framework, the framework has already configured the database for you, go take a look at it so that you can get familiar with it!",
            ['DbCheckTurnedOff'] = "The framework had noticed that you had set ^4CheckIfExistOnStart^0 to ^2true^0 but you already had the ^4users table^0 and so it set it to ^1false^0 to save resources ^3automatically for you^0",
            ['LoadedMsg']        = "Loaded ^2%d^0 %s",
            ['StartedIn']        = "Started in: %s ms",
            ['ConnectedUser']    = "User %s connected!",
            ['RecievedSalary']   = "You have recieved %d$ from the salary",
            ['Maintenance']      = "The server is currently under maintenance 👨‍🔧",
            ['MenuCloseLabel']   = "<fa-backspace> Back"
        }
    }
