local QBCore = exports['qb-core']:GetCoreObject()


-- Still Site
exports['qb-target']:AddTargetModel("prop_still", {
    options = {
        { 
            event = "doj:client:moonshineStill",
            icon = "fas fa-moon",
            label = "Pot Still", 
        },
    },
    distance = 1.5
})

RegisterNetEvent('doj:client:moonshineStill', function()
    exports['qb-menu']:openMenu({
        {
            header = "Moonshine Distillation",
            txt = "Status: Inactive",
            isMenuHeader = true
        },
        {
            header = "Insert Mash",
            txt = "",
            params = {
                event = "",
            }
        },
        {
            header = "Dismantle",
            txt = "",
            params = {
                event = "doj:client:removeMoonshineStill",
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

RegisterNetEvent('doj:client:removeMoonshineStill', function()
    exports['qb-menu']:openMenu({
        {
            header = "Moonshine Distillation",
            txt = "Status: Pending removal",
            isMenuHeader = true
        },
        {
            header = "pack up",
            txt = "",
            params = {
                event = "doj:client:dismantleMoonshineStill",
            }
        },
        {
            header = "destroy",
            txt = "",
            params = {
                event = "doj:client:destroyMoonshineStill",
            }
        },
        {
            header = "< Return",
            txt = "main menu",
            params = {
                event = "doj:client:moonshineStill",
            }
        },
    })
end)

RegisterNetEvent("doj:client:destroyMoonshineStill", function()
    local ped = PlayerPedId()
    local playerCoords = GetEntityCoords(ped)
    local prop = GetHashKey("prop_still")
    local distillationSite = GetClosestObjectOfType(playerCoords.x,playerCoords.y,playerCoords.z,2.0,prop,0,0,0)
    if DoesEntityExist(distillationSite) then
        QBCore.Functions.Progressbar("destroying_still", "Destroying Still", (math.random(7000, 12000)), false, true, {
            disableMovement = false,
            disableCarMovement = false,
            disableMouse = false,
            disableCombat = true,
        }, {
            animDict = "mini@repair",
            anim = "fixing_a_player",
            flags = 16,
        }, {}, {}, function() -- Done
            ClearPedTasks(ped)
            DeleteEntity(distillationSite)
            QBCore.Functions.Notify("Pot still destroyed", "error")
        end, function() -- Cancel
            ClearPedTasks(ped)
            QBCore.Functions.Notify("Canceled!", "error")
        end)
    else
        QBCore.Functions.Notify("Move closer", "error")   
    end
end)

RegisterNetEvent("doj:client:dismantleMoonshineStill", function()
    local ped = PlayerPedId()
    local playerCoords = GetEntityCoords(ped)
    local prop = GetHashKey("prop_still")
    local distillationSite = GetClosestObjectOfType(playerCoords.x,playerCoords.y,playerCoords.z,2.0,prop,0,0,0)
    if DoesEntityExist(distillationSite) then
        QBCore.Functions.Progressbar("dismantle_still", "Dismantling Still", (math.random(10000, 15000)), false, true, {
            disableMovement = false,
            disableCarMovement = false,
            disableMouse = false,
            disableCombat = true,
        }, {
            animDict = "mini@repair",
            anim = "fixing_a_player",
            flags = 16,
        }, {}, {}, function() -- Done
            ClearPedTasks(ped)
            DeleteEntity(distillationSite)
            TriggerServerEvent('QBCore:Server:AddItem', "moonshine_still", 1)
            TriggerEvent('inventory:client:ItemBox', QBCore.Shared.Items["moonshine_still"], "add", 1)
            QBCore.Functions.Notify("Pot still dismantled")
        end, function() -- Cancel
            ClearPedTasks(ped)
            QBCore.Functions.Notify("Canceled!", "error")
        end)
    else
        QBCore.Functions.Notify("Move closer", "error")   
    end
end)

RegisterNetEvent("doj:client:spawnMoonshineStill", function()
    local ped = PlayerPedId()
    local prop = GetHashKey("prop_still")
    local heading = GetEntityHeading(ped)
    local playerCoords = GetEntityCoords(ped)
    local forward = GetEntityForwardVector(ped)
    local x, y, z = table.unpack(playerCoords + forward * 1.5)
    local distillationSite = GetClosestObjectOfType(playerCoords.x,playerCoords.y,playerCoords.z,2.0,prop,0,0,0)
    if DoesEntityExist(distillationSite) then
        QBCore.Functions.Notify("Pot still nearby", "error") 
    else
        QBCore.Functions.Progressbar("dismantle_still", "Placing still site", (math.random(10000, 15000)), false, true, {
            disableMovement = false,
            disableCarMovement = false,
            disableMouse = false,
            disableCombat = true,
        }, {
            animDict = "mini@repair",
            anim = "fixing_a_player",
            flags = 16,
        }, {}, {}, function() -- Done
            ClearPedTasks(ped)
            TriggerServerEvent('QBCore:Server:RemoveItem', "moonshine_still", 1)
            TriggerEvent('inventory:client:ItemBox', QBCore.Shared.Items["moonshine_still"], "remove", 1)
            local spawnedObj = CreateObject("prop_still", x, y, z, true, false, false)
            PlaceObjectOnGroundProperly(spawnedObj)
            SetEntityHeading(spawnedObj, heading)
            FreezeEntityPosition(spawnedObj, true)
        end, function() -- Cancel
            ClearPedTasks(ped)
            QBCore.Functions.Notify("Canceled!", "error")
        end)   
    end
end)