-- Addons
oxmysql  = exports['oxmysql']      -- MySQL
analizer = addon("analizer")       -- Addon to analyze runtime
mathm    = addon("math")           -- Addon to perform some long things like rounding of numbers
ts       = addon("translate")      -- Addon that allow you to auto translate strings
enc      = addon("encrypting")

-- GlobalState creation

--UsableItem      = BuildFakeProxyTable("UsableItem")
--SharedFunction  = BuildFakeProxyTable("SharedFunction")


Utility = {
    DatabaseLoaded = false,
    SocietyAlreadySaved = false,
    
    PlayersData     = {},
    VehiclesData    = {},
    SocietyData     = {},
    Stashes         = {},

    JobWorker       = {},
    Hooks           = {},

    Bans = {},        
    
    -- TBP Token (Trigger Basic Protection)
    Token = mathm.randoms(20, true)
}

-- For function _ auto translation in the server loader
GlobalState.TranslationCache = {}
GlobalState.SharedFunction = {}