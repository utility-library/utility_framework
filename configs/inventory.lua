Config.Inventory = {
    Type = "weight", -- This is how the inventory max is calculated, with weight every item have a weight and there is a max weight, with the limit any item have a max limit
                            -- Can be changed even if the server is already started (in the sense that there are already players playing on it)
                            -- available type: weight, limit
                            
    MaxWeight         = 300,      -- The maximum weight a player can carry (only weight)

    DefaultMaxClassWeight = 350, -- if the class isnt founded the framework use this as a weight
    MaxClassWeight = { -- The weight of any vehicle trunk, works with classes id. see https://docs.fivem.net/natives/?_0x29439776AAA00A62 for the classes id (only weight)
        [1] = 200,
    },

    DefaultItemWeight = 5, -- If the item does not exist in the list below it will have this weight/limit (weight/limit)
    ItemWeight    = { -- The list of the limit for any item or the weight of any item (weight/limit)
        ["example"] = 10
    },
}