
local QBCore = exports['qb-core']:GetCoreObject()

-- Exports

exports['qb-target']:AddTargetModel(769275872, {
    options = {
        { 
            event = "doj:client:useMachine",
            icon = "fas fa-circle",
            label = "Use", 
        },
    },
    distance = 2.0
})

-- Threads

CreateThread(function()
    local MoneyWashEnterZone = CircleZone:Create(Config.Moneywash.entrance, 1.0, {
        name="MoneyWashEnter",
        heading=328.0,
        debugPoly=Config.DebugZones.moneywashenter,
        useZ=true,
    })
    MoneyWashEnterZone:onPlayerInOut(function(isPointInside)
        if isPointInside then
            text = 'This area seems interesting'
            exports['textUi']:DrawTextUi('show', text)
            TriggerEvent("doj:MoneyWashTeleportMenu", 1)
        else
            exports['qb-menu']:closeMenu()
            exports['textUi']:HideTextUi('hide')
        end
    end)
end)

CreateThread(function()
    local MoneyWashExitZone = CircleZone:Create(Config.Moneywash.exit, 1.5, {
        name="MoneyWashExit",
        heading=328.0,
        debugPoly=Config.DebugZones.moneywashexit,
        useZ=true,
    })
    MoneyWashExitZone:onPlayerInOut(function(isPointInside)
        if isPointInside then
            TriggerEvent("doj:MoneyWashTeleportMenu", 2)
        else
            exports['qb-menu']:closeMenu()
            exports['textUi']:HideTextUi('hide')
        end
    end)
end)

-- Events

RegisterNetEvent('doj:MoneyWashTeleports', function(args)
    local args = tonumber(args)
    local ped = PlayerPedId()
    if args == 1 then 
        QBCore.Functions.TriggerCallback('QBCore:HasItem', function(HasItem)
            if HasItem then
                QBCore.Functions.Progressbar("key", "Inserting key..", 500, false, true, {
                    disableMovement = true,
                    disableCarMovement = true,
                    disableMouse = false,
                    disableCombat = true,
                }, {
                    animDict = "anim@heists@keycard@",
                    anim = "exit",
                    flags = 16,
                }, {}, {}, function() -- Done
                    SetEntityCoords(ped, Config.Moneywash.exit, false, false, false, true)
                    SetEntityHeading(ped, Config.Moneywash.exitHeading)
                    ClearPedTasks(ped)       
                end, function()
                    ClearPedTasks(ped)
                end)
            else
                QBCore.Functions.Notify("You are missing something!!", "error" , 5000)
            end
        end, 'wash_key') 
    else
        SetEntityCoords(ped, Config.Moneywash.entrance, false, false, false, true)
        SetEntityHeading(ped, Config.Moneywash.entranceHeading)
    end
end)

RegisterNetEvent('doj:MoneyWashTeleportMenu', function(args)
    local args = tonumber(args)
    local ped = PlayerPedId()
    if args == 1 then 
        exports['qb-menu']:showHeader({
            {
                header = "Unmarked door",
                txt = "",
                isMenuHeader = true,
            },
            {
                header = "Enter", 
                txt = "",
                params = {
                    event = "doj:MoneyWashTeleports",
                    args = 1
                }
            }
        })
    else
        exports['qb-menu']:showHeader({
            {
                header = "Unmarked door",
                txt = "",
                isMenuHeader = true,
            },
            {
                header = "Exit", 
                txt = "",
                params = {
                    event = "doj:MoneyWashTeleports",
                    args = 2
                }
            }
        })
    end
end)

RegisterNetEvent('doj:client:useMachine', function()
    QBCore.Functions.TriggerCallback('QBCore:HasItem', function(HasItem)
        if HasItem then
            QBCore.Functions.Progressbar("key", "Inserting Bills", Config.Moneywash.opentime, false, true, {
                disableMovement = true,
                disableCarMovement = true,
                disableMouse = false,
                disableCombat = true,
            }, {}, {}, {}, function() -- Done
                TriggerEvent('doj:client:cargoMoneyLaunderingMenu')
            end, function()
                QBCore.Functions.Notify("Cancled!", "error" , 5000)
            end)
        else
            QBCore.Functions.Notify("You are missing something!", "error" , 5000)
        end
    end, 'markedbills') 
end)

RegisterNetEvent('doj:client:LaunderingCurrencyOptions', function(args)  
    local args = tonumber(args)
    if args == 1 then
        QBCore.Functions.TriggerCallback('QBCore:HasItem', function(HasItem)
            if HasItem then
                TriggerServerEvent('qb-phone:server:sendNewMail', {
                    sender = "Cargo Supplier",
                    subject = "System Activity",
                    message = "Our systems indicate that you are trying to wash your markedbills for cash, Your bills will be washed shortly and the money will be deposited in to your bank account shortly"
                })
                Wait(Config.Moneywash.washtime)
                TriggerServerEvent("doj:server:washMarkedBills", 1)
                TriggerServerEvent('qb-phone:server:sendNewMail', {
                    sender = "Cargo Supplier",
                    subject = "System Activity",
                    message = "Money has been deposited in to your bank"
                })
            else
                QBCore.Functions.Notify("Mail was sent to your phone but you dont have one!", "error")
            end
        end, 'phone')
    else
        QBCore.Functions.TriggerCallback('QBCore:HasItem', function(HasItem)
            if HasItem then
                TriggerServerEvent('qb-phone:server:sendNewMail', {
                    sender = "Cargo Supplier",
                    subject = "System Activity",
                    message = "Our systems indicate that you are trying to wash your markedbills for crypto, Your bills will be washed shortly and crypto will be deposited in to your wallet shortly"
                })
                Wait(Config.Moneywash.washtime)
                TriggerServerEvent("doj:server:washMarkedBills", 2)
                TriggerServerEvent('qb-phone:server:sendNewMail', {
                    sender = "Cargo Supplier",
                    subject = "System Activity",
                    message = "Crypto has been deposited in to your wallet"
                })
            else
                QBCore.Functions.Notify("Mail was sent to your phone but you dont have one!", "error")
            end
        end, 'phone')
    end
end)

RegisterNetEvent('doj:client:cargoMoneyLaunderingMenu', function()
    exports['qb-menu']:openMenu({
        {
            header = "Cargo Supplier: Laundering",
            txt = "Select a currency",
            isMenuHeader = true,
        },
        {
            header = "Bank", 
            txt = "Fee: %",
            params = {
                event = "doj:client:LaunderingCurrencyOptions",
                args = 1
            }
        },
        {
            header = "Crypto", 
            txt = "Fee: %",
            params = {
                event = "doj:client:LaunderingCurrencyOptions",
                args = 2
            }
        },
    })
end)

