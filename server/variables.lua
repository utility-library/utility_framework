-- Addons
oxmysql  = exports['oxmysql']      -- MySQL
analizer = addon("analizer")       -- Addon to analyze runtime
mathm    = addon("math")           -- Addon to perform some long things like rounding of numbers
ts       = addon("translate")      -- Addon that allow you to auto translate strings
enc      = addon("encrypting")

Utility = {
    DatabaseLoaded = false,
    AlreadySaved   = false,
    
    Players     = {},
    Vehicles    = {},
    Societies   = {},
    Stashes     = {},

    JobWorker   = {},
    Hooks       = {},

    Bans = {},        
}

-- For function _ auto translation in the server loader
GlobalState.TranslationCache = {}

GlobalState.SharedFunction = {}