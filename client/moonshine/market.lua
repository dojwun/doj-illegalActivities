
local QBCore = exports['qb-core']:GetCoreObject()

--Market
exports['qb-target']:AddTargetModel("a_m_m_mexlabor_01", {
    options = {
        { 
            event = "inventory:client:OpenFarmersMarket",
            icon = "fas fa-apple-alt",
            label = "Farmers Market", 
        },
    },
    distance = 2.0
})

RegisterNetEvent('inventory:client:OpenFarmersMarket', function()
    local ShopItems = {}
    local num = math.random(1, 99)
    ShopItems.label = "Farmers Market "..num
    ShopItems.items = Config.farmersMarketItems
    ShopItems.slots = #Config.farmersMarketItems
    if Config.farmersMarketAlwaysOpen then 
        TriggerServerEvent("inventory:server:OpenInventory", "shop", "FarmersMarket_"..num, ShopItems)
    else
        if GetClockHours() >= 6 and GetClockHours() <= 21 then
            TriggerServerEvent("inventory:server:OpenInventory", "shop", "FarmersMarket_"..num, ShopItems)
        else
            QBCore.Functions.Notify('Farmers market is closed! Opened from 6:00am to 21:00pm', 'error')
        end
    end
end)




