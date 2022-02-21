
local QBCore = exports['qb-core']:GetCoreObject()

QBCore.Functions.CreateUseableItem("cargo_briefcase", function(source, item)
    local src = source
	local Player = QBCore.Functions.GetPlayer(src)
    local cashReward = math.random(10000, 15000)
	if Player.Functions.GetItemByName(item.name) ~= nil then
        if math.random(1, 5) <= 4 then
            local info = {worth = cashReward}
            if Player.Functions.AddItem('markedbills', 1, false, info) then
                TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items['markedbills'], "add", 1)
                Player.Functions.RemoveItem("cargo_briefcase", 1)
                TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items['cargo_briefcase'], "remove", 1)
            else
                TriggerClientEvent('QBCore:Notify', src, 'You have to much in your pockets', 'error')
            end 
        else
			Player.Functions.AddMoney('cash', cashReward)
            TriggerClientEvent('QBCore:Notify', src, '+$'..cashReward, 'success')
        end
	end
end)

RegisterNetEvent('doj:server:washMarkedBills', function(args)  
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local amount = 0
    local args = tonumber(args)
    if args == 1 then
        for itemData, item in pairs(Player.PlayerData.items) do
            if item.name == 'markedbills' then
                if type(item.info) ~= 'string' and tonumber(item.info.worth) then
                    amount = amount + tonumber(item.info.worth)
                    Player.Functions.AddMoney('bank', amount)
                    Player.Functions.RemoveItem(item.name, 1)
                    TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[item.name], "remove", 1)
                end
            end
        end
    else
        for itemData, item in pairs(Player.PlayerData.items) do
            if item.name == 'markedbills' then
                if type(item.info) ~= 'string' and tonumber(item.info.worth) then
                    amount = amount + tonumber(item.info.worth)
                    cryptoAmount = math.random(1,3)
                    Player.Functions.RemoveItem(item.name, 1)
                    Player.Functions.AddMoney('crypto', cryptoAmount)
                    TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[item.name], "remove", 1)
                end
            end
        end
    end
end)



-- Moonshine

QBCore.Functions.CreateUseableItem("moonshine_still", function(source, item)
    local Player = QBCore.Functions.GetPlayer(source)
	if Player.Functions.GetItemBySlot(item.slot) ~= nil then
        TriggerClientEvent("doj:client:spawnMoonshineStill", source)
    end
end) 











QBCore.Functions.CreateUseableItem("moonshine_barrel", function(source, item)
    local Player = QBCore.Functions.GetPlayer(source)
	if Player.Functions.GetItemBySlot(item.slot) ~= nil then
        TriggerClientEvent("doj:client:startMashBarrelPlacement", source)
    end
end) 



-- function insertBarrelToDb(coords, id)
--     local src = source
--     local Player = QBCore.Functions.GetPlayer(src)
--     -- exports.oxmysql:insert('INSERT INTO player_mashbarrel (coords) VALUES (?)',{
--     --     json.encode({x = coords[1], y = coords[2], z = coords[3]}),
--     -- },function(id)
--         TriggerClientEvent("doj:client:spawnMashBarrel", src, coords, id)
--     -- end)
-- end 

RegisterNetEvent("doj:server:readyToPlaceBarrel",function(coords)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local barrel = Player.Functions.GetItemByName("moonshine_barrel")
    if barrel ~= nil then
        -- insertBarrelToDb(coords, src)
        
        Player.Functions.RemoveItem("moonshine_barrel", 1)
        TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items["moonshine_barrel"], "remove", 1)
        TriggerClientEvent("doj:client:spawnMashBarrel", src, coords, id)
    else
        TriggerClientEvent('QBCore:Notify', src, "error placing barrel", 'error')
    end
end) 




QBCore.Functions.CreateUseableItem("moonshine_bucket", function(source, item)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
	if Player.Functions.GetItemBySlot(item.slot) ~= nil then
        TriggerClientEvent("doj:client:useMoonshineBucket", src)
    end
end) 

RegisterNetEvent("doj:client:fillWaterBucket",function(coords)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local barrel = Player.Functions.GetItemByName("moonshine_bucket")
    if barrel ~= nil then
        SetTimeout(Config.collectWaterTime, function()
            TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items["moonshine_bucket_full"], "add", 1)
            Player.Functions.AddItem("moonshine_bucket_full", 1)
		end)
        Player.Functions.RemoveItem("moonshine_bucket", 1)
        TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items["moonshine_bucket"], "remove", 1)
    else
        TriggerClientEvent('QBCore:Notify', src, "error filling bucket", 'error')
    end
end) 

