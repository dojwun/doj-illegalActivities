
local QBCore = exports['qb-core']:GetCoreObject()

exports['qb-target']:AddTargetModel("prop_barrel_02a", {
    options = {
        { 
            event = "doj:client:mashBarrelMenu",
            icon = "fas fa-trash-restore-alt",
            label = "Mash barrel", 
        },
    },
    distance = 1.5
})

RegisterNetEvent('doj:client:mashBarrelMenu', function()
    exports['qb-menu']:openMenu({
        {
            header = "Mash barrel",
            txt = "Status: %",
            isMenuHeader = true
        },
        {
            header = "Insert Ingredience",
            txt = "",
            params = {
                event = "doj:client:mashBarrelIngredience",
            }
        },
        {
            header = "Dismantle",
            txt = "",
            params = {
                event = "doj:client:removeMashBarrel",
            }
        },
        {
            header = "< Exit",
            params = {
                event = ""
            }
        },
    })
end)

RegisterNetEvent('doj:client:removeMashBarrel', function()
    exports['qb-menu']:openMenu({
        {
            header = "Mash barrel",
            txt = "Status: Pending removal",
            isMenuHeader = true
        },
        {
            header = "pack up",
            txt = "",
            params = {
                event = "doj:client:dismantleMashBarrel",
            }
        },
        {
            header = "destroy",
            txt = "",
            params = {
                event = "doj:client:destroyMashBarrel",
            }
        },
        {
            header = "< Return",
            txt = "main menu",
            params = {
                event = "doj:client:mashBarrelMenu"
            }
        },
    })
end)

RegisterNetEvent('doj:client:mashBarrelIngredience', function()
    exports['qb-menu']:openMenu({
        {
            header = "Mash barrel",
            txt = "Status: Adding ingredience",
            isMenuHeader = true
        },
        {
            header = "Water",
            txt = "",
            params = {
                event = "doj:client:add5galWater",
            }
        },
        {
            header = "Grains",
            txt = "",
            params = {
                event = "doj:client:addGrains",
            }
        },
        {
            header = "Yeast",
            txt = "",
            params = {
                event = "doj:client:addYeast",
            }
        },
        {
            header = "Fruit",
            txt = "",
            params = {
                event = "doj:client:addFruit",
            }
        },
        {
            header = "< Return",
            txt = "main menu",
            params = {
                event = "doj:client:mashBarrelMenu"
            }
        },
    })
end)

RegisterNetEvent("doj:client:startMashBarrelPlacement", function()
    local ped = PlayerPedId()
    local playerCoords = GetEntityCoords(ped)
    local MashBarrel = GetClosestObjectOfType(playerCoords.x,playerCoords.y,playerCoords.z,2.0,GetHashKey("prop_barrel_02a"),0,0,0)
    if DoesEntityExist(MashBarrel) then
        QBCore.Functions.Notify("Mash barrel nearby", "error") 
    else
        TriggerServerEvent("doj:server:readyToPlaceBarrel", playerCoords)
    end
end)

RegisterNetEvent("doj:client:spawnMashBarrel", function(coords, id)
    local ped = PlayerPedId()
    local heading = GetEntityHeading(ped)
    local playerCoords = GetEntityCoords(ped)
    local forward = GetEntityForwardVector(ped)
    local x, y, z = table.unpack(playerCoords + forward * 1.5)
    local spawnedObj = CreateObject("prop_barrel_02a", x, y, z, true, false, false)
    PlaceObjectOnGroundProperly(spawnedObj)
    SetEntityHeading(spawnedObj, heading)
    FreezeEntityPosition(spawnedObj, true)
end)


RegisterNetEvent("doj:client:useMoonshineBucket", function()
    local playerPed = PlayerPedId()
    if IsEntityInWater(playerPed)  then
        TriggerServerEvent("doj:client:fillWaterBucket")
        QBCore.Functions.Progressbar("collect_water", "Collecting water..", Config.collectWaterTime, false, true, {
            disableMovement = true,
            disableCarMovement = false,
            disableMouse = false,
            disableCombat = true,
        }, {
            animDict = "amb@prop_human_bbq@male@base",
            anim = "base",
            flags = 16,
        }, {
            model = "prop_bucket_01b",
            bone = 28422,
            coords = { x = -0.005, y = -0.20, z = -0.45},
            rotation = { x = 360.0, y = 360.0, z = 0.0},
        }, {}, function() -- Done
            ClearPedTasks(playerPed)
        end, function()
            QBCore.Functions.Notify("Cancelled..", "error")
            ClearPedTasks(playerPed)
        end)
    else
        QBCore.Functions.Notify("Need to be in water", "error") 
    end
end)



RegisterNetEvent("doj:client:add5galWater", function(coords, id)
    QBCore.Functions.TriggerCallback('QBCore:HasItem', function(HasItem)
        TriggerEvent('doj:client:mashBarrelIngredience')
        if HasItem then
            QBCore.Functions.Notify("added moonshine_bucket_full 'TESTING' ")
        else
            QBCore.Functions.Notify("You are missing a moonshine_bucket_full..", "error")
        end
    end, 'moonshine_bucket_full')
end)

RegisterNetEvent("doj:client:addGrains", function(coords, id)
    QBCore.Functions.TriggerCallback('QBCore:HasItem', function(HasItem)
        TriggerEvent('doj:client:mashBarrelIngredience')
        if HasItem then
            QBCore.Functions.Notify("added moonshine_grains 'TESTING' ")
        else
            QBCore.Functions.Notify("You are missing a moonshine_grains..", "error")
        end
    end, 'moonshine_grains')
end)

RegisterNetEvent("doj:client:addYeast", function(coords, id)
    QBCore.Functions.TriggerCallback('QBCore:HasItem', function(HasItem)
        TriggerEvent('doj:client:mashBarrelIngredience')
        if HasItem then
            QBCore.Functions.Notify("added moonshine_yeast 'TESTING' ")
        else
            QBCore.Functions.Notify("You are missing a moonshine_yeast..", "error")
        end
    end, 'moonshine_yeast')
end)

RegisterNetEvent("doj:client:addFruit", function(coords, id)
    QBCore.Functions.TriggerCallback('QBCore:HasItem', function(HasItem)
        TriggerEvent('doj:client:mashBarrelIngredience')
        if HasItem then
            QBCore.Functions.Notify("added moonshine_fruit 'TESTING' ")
        else
            QBCore.Functions.Notify("You are missing a moonshine_fruit..", "error")
        end
    end, 'moonshine_fruit')
end)