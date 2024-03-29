Config.Addons = {
    DisableExplosion = true,  -- Disable all explosion, only the client that created that explosion can see it (can prevent nuke of the server)
        
    -- Basic RP animation (control can be modified in client/internal_addons/basic_animation.lua at the bottom line)
    Animation = {
        crouch  = true, -- Default Key: Left Ctrl
        handsup = true, -- Default Key: X
        faint   = true, -- Default Key: ,
    },
    
    -- Automatically manage the status (hunger, thirst)
    Status = {
        active = false,
        every  = "1m", -- Every time this time passes a quantity of percentage is removed from the state, you can use: "s", "m" or "ms"
        remove = 0.5, -- This is the quantity that will be removed (percentage)

        -- Here you can setup the default value (percentage) for any status (you can add status)
        default = {
            ["hunger"] = 50,
            ["thirst"] = 50,
        }
    },

    Weather = {
        active = true,
        realtime = true, -- Sync the hoster machine time with the server time
    },

    DiscordRPC = {
        AppId = 913883145198243890,
        Description = "Playing in a server with the Utility Framework",

        BigPicture = {
            Key = "utility_logo",
            Text = "Utility Framework"
        },
        SmallPicture = {
            Key = "discord",
            Text = "https://discord.gg/gPcbnCfk2x"
        },

        Buttons = {
            ["Connect"] = "fivem://connect/localhost",
            ["Discord"] = "https://discord.gg/gPcbnCfk2x",
        }
    }
}