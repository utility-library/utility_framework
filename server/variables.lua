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
    JobWorker       = {},

    Bans = {},        
    
    -- TBP Token (Trigger Basic Protection)
    Token = math.random(0, 999999999999999999)
}