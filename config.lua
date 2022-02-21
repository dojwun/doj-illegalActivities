
Config	= {}

Config.Moneywash = {
    opentime = math.random(5000, 7500),
    washtime = math.random(30000, 40000),
    entrance = vector3(-813.376, -585.879, 30.471), -- change to a money wash location of your choice
    entranceHeading = 352.374,
    exit = vector3(1137.934, -3198.39, -39.666),
    exitHeading = 352.374,
}

Config.rareCargoRewards = {                                  -- Clean cargo rewards (keep price = 0) (small chance to open this crate)
    [1] = { name = "goldchain",     price = 0, amount = math.random(1,4), info = {}, type = "item", slot = 1, },
	[2] = { name = "diamond_ring",  price = 0, amount = math.random(1,4), info = {}, type = "item", slot = 2, },
    [3] = { name = "rolex",         price = 0, amount = math.random(1,4), info = {}, type = "item", slot = 3, },
    [4] = { name = "10kgoldchain",  price = 0, amount = math.random(1,4), info = {}, type = "item", slot = 4, },
    [5] = { name = "laptop",        price = 0, amount = math.random(1,4), info = {}, type = "item", slot = 5, },
}

Config.commonCargoRewards = {                                  -- Dirty cargo rewards (keep price = 0) (crate thats open most commonly )
    [1] = { name = "cargo_briefcase", price = 0, amount = 1, info = {}, type = "item", slot = 1, },
}

Config.DebugZones = { -- Debug PolyZones (green circle)
    startingrange = false,
    neardoor = false,
    cargodrop = false,
    moneywashenter = false,
    moneywashexit = false,
}

Config.minigame = {
    correctBlocks = 3,    -- Number of correct blocks the player needs to click
    incorrectBlocks = 3,  -- Number of incorrect blocks after which the game will fail
    timetoShow = 3,       -- Time in secs for which the right blocks will be shown
    timetoLose = 20,      -- Maximum time after timetoshow expires for player to select the right blocks
} 



--Moonshine
-- [SOURCE: https://github.com/sjpfeiffer/ped_spawner]
Config.PedList = {                                              -- Peds that will be spawned in
	{
		model = "a_m_m_mexlabor_01",                                   
		coords = vector3(1792.532, 4593.911, 36.683),               
		heading = 182.568,
		gender = "male",
        scenario = "WORLD_HUMAN_CLIPBOARD_FACILITY" 
	},
}

Config.farmersMarketAlwaysOpen = false
Config.collectWaterTime = 5000

Config.farmersMarketItems = {
    [1] = { name = "moonshine_fruit",       price = 25, amount = 50, info = {}, type = "item", slot = 1, },
    [2] = { name = "moonshine_yeast",       price = 25, amount = 50, info = {}, type = "item", slot = 2, },
    [3] = { name = "moonshine_grains",      price = 30, amount = 50, info = {}, type = "item", slot = 3, },
    [4] = { name = "moonshine_bucket",      price = 50, amount = 50, info = {}, type = "item", slot = 4, },
    [5] = { name = "moonshine_barrel",      price = 500, amount = 50, info = {}, type = "item", slot = 5, },
    [6] = { name = "moonshine_still",       price = 5000, amount = 50, info = {}, type = "item", slot = 6, },
    [7] = { name = "moonshine_cheesecloth", price = 10, amount = 50, info = {}, type = "item", slot = 7, },
}