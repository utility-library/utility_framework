Config.Logs = {
    Connection = {
        NewUser = true, -- Print "[NEW] User <PLAYER_NAME> connected!" if the player is new
        OldUser = true  -- Print "[OLD] User <PLAYER_NAME> connected!" if the player already exist in the database
    },
    Trigger = {
        Registered = true, -- Print any trigger registered from external resource with the loader and the relative encrypted trigger name
        Called     = false  -- Print any trigger call with the relative player id that called that trigger
    },

    AdvancedLog = {
        type = "both", -- Where to log the AdvancedLog, available type: file/console/both/disabled
        actived = {
            TBP = true, -- Trigger Basic Protection (the anti trigger)
            Startup = true, -- Startup info
            Building = true, -- Log the build/demolish for any player
            First_Time = true, -- First time log (example the db creation)
            Loaded = true, -- Any loading of the framework, where and who have started/loaded the framework server/client side
            Connection = true, -- Any connection to the server
            Save = true, -- Any saving (society/player/manual)
            Salary = true, 
            Explosion = true, -- Any explosion eliminated (only with DisableExplosion turned on)
            NoSteam = true, -- Any connection to the server without steam
            
            Money = true, -- Log any money transition
            Item = true, -- Log any item transition
            Jobs = true, -- Log any jobs change
            Weapon = true, -- Log any weapon transition
            License = true, -- Log any license transition
            Bills = true, -- Log any bill transition
            Vehicle = true, -- Log any vehicle action (for uPlayer)
            Trunk = true, -- Log any trunk transition
            Development = false, -- Log any development info (not for normal users)
        }
    }
}