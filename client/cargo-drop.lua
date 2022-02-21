
local QBCore = exports['qb-core']:GetCoreObject()

local requiredModels = {}
local pilot, aircraft, parachute, crate, pickup, blip, soundID
local cargodrop,lookingForDoor,cargoDropStarted,cargoPlaneReady = false

-- Exports

local payphoneModels = {
    `hei_prop_carrier_phone_02`,
    `p_phonebox_01b_s`,
    `p_phonebox_02_s`,
    `prop_phonebox_01a`,
    `prop_phonebox_01b`,
    `prop_phonebox_01c`,
    `prop_phonebox_02`,
    `prop_phonebox_03`,
    `prop_phonebox_04`,
}
exports['qb-target']:AddTargetModel(payphoneModels, {
    options = {
        { 
            event = "doj:client:startCargoDrop",
            icon = "fas fa-circle",
            label = "Use payphone", 
            item = 'cargo_phonenumber',
        },
    },
    distance = 1.0
})

exports['qb-target']:AddTargetModel('a_m_m_hillbilly_02', {
    options = {
        { 
            event = "doj:client:requestCargoPlane",
            icon = "fas fa-circle",
            label = "Speak with Supplier Assistance", 
        },
    },
    distance = 1.5
})

exports['qb-target']:AddTargetModel("ex_prop_adv_case_sm", {
    options = {
        { 
            event = "doj:client:attemptToOpenCrate",
            icon = "fas fa-circle",
            label = "Open Crate", 
        },
    },
    distance = 1.5
})

-- Events

RegisterNetEvent("doj:client:startCargoDrop", function()
    local ped = PlayerPedId()
    if not cargodrop == true then 
        QBCore.Functions.TriggerCallback('QBCore:HasItem', function(HasItem)
            if HasItem then
                print("cargo drop started")
                TriggerServerEvent("InteractSound_SV:PlayOnSource", "cargo_call", 0.1)
                TriggerServerEvent('QBCore:Server:RemoveItem', "cargo_phonenumber", 1)
                TriggerEvent('inventory:client:ItemBox', QBCore.Shared.Items["cargo_phonenumber"], "remove", 1)
                QBCore.Functions.Progressbar("phone-call", "Calling supplier", 10000, false, true, {
                    disableMovement = false,
                    disableCarMovement = false,
                    disableMouse = false,
                    disableCombat = true,
                }, {
                    animDict = "amb@world_human_stand_mobile@male@standing@call@base",
                    anim = "base",
                    flags = 49,
                }, {}, {}, function() -- Done
                    ClearPedTasks(ped)
                    setWaypointToDoor()
                end, function() -- Cancel
                    ClearPedTasks(ped)
                end)
            else
                print("Missing cargo_phonenumber item!")
                QBCore.Functions.Notify("You are missing something!!", "error" , 5000)
            end
        end, 'cargo_phonenumber') 
    else
        print("cargo drop in progress")
        QBCore.Functions.Notify("Cargo already in progress!", "error" , 5000)
    end
end)

RegisterNetEvent("doj:client:taskWalkToDoor", function()
    local ped = PlayerPedId()
    local timeToWait = 3000
    print("Door started, Walking up to door")
    TaskGoStraightToCoord(ped,  vector3(-1102.066, 2721.873, 18.8),  1.0,  timeToWait,  151.466,  0.0)
    Wait(timeToWait)
    print("Knocking on door")
    QBCore.Functions.Progressbar("knocking", "Knocking..", (math.random(3700, 5000)), false, true, {
		disableMovement = true,
		disableCarMovement = true,
		disableMouse = false,
		disableCombat = true,
	}, {
		animDict = "timetable@jimmy@doorknock@",
		anim = "knockdoor_idle",
		flags = 16,
	}, {}, {}, function() -- Done
        ClearPedTasks(ped)
        spawnCargoAssistPed()
	end, function()
        ClearPedTasks(ped)
	end)
end)

RegisterNetEvent("doj:client:requestCargoPlane", function()
    local ped = PlayerPedId()
    print("qb-target response accepted.. staring task")
    QBCore.Functions.Notify("Your map will be updated soon with a GPS location for a drop off", "primary" , 5000)
    PlayPedAmbientSpeechNative(CargoPed, "Chat_State", "Speech_Params_Force")
    loadAnimDict( "random@mugging4" ) 
    TaskPlayAnim(CargoPed, "random@mugging4", "agitated_loop_a", 8.0, 1.0, -1, 16, 0, 0, 0, 0 )
    Wait(1000)
    loadAnimDict( "mp_safehouselost@" )
    TaskPlayAnim(CargoPed, "mp_safehouselost@", "package_dropoff", 8.0, 1.0, -1, 16, 0, 0, 0, 0 )
    Wait(3000)
    FreezeEntityPosition(CargoPed, false)
    TaskGoStraightToCoord(CargoPed,  vector3(-1102.077, 2721.825, 17.8),  1.0,  3000,  134.522,  0.0)
    Wait(3000)
    DeletePed(CargoPed)
    print("removing ped")
    setWaypointToAirDrop()
end)

RegisterNetEvent('doj:client:attemptToOpenCrate', function()
    print("Attempt To Open Crate")
	local ped = PlayerPedId()
	local animDict = "veh@break_in@0h@p_m_one@"
	local animName = "low_force_entry_ds"
	RequestAnimDict(animDict)
	while not HasAnimDictLoaded(animDict) do
		Wait(100)
	end
	TaskPlayAnim(ped, animDict, animName, 1.0, 1.0, 1.0, 1, 0.0, 0, 0, 0)
	RemoveAnimDict(animDict)
	QBCore.Functions.Notify('Attempting to open cargo drop', 'primary', 1500)
	Wait(1500)
	ClearPedTasks(ped)
    QBCore.Functions.Notify('Password is Required!', "primary", 1000)
    Wait(1000)
    skillCheckCargoDrop()
end)

-- Threads

CreateThread(function()
    local assistanceCloseZone = CircleZone:Create(vector3(-1102.066, 2721.873, 18.8), 50.0, {
        name="cargo-assistance-close",
        heading=0.0,
        debugPoly=Config.DebugZones.startingrange,
        useZ=true,
    })
    assistanceCloseZone:onPlayerInOut(function(isPointInside)
        if isPointInside and cargoDropStarted then
            lookingForDoor = true
            print("In starting range, Looking for Door")
            text = 'This seems like the right area'
            exports['textUi']:DrawTextUi('show', text)
        else
            exports['textUi']:HideTextUi('hide')
        end
    end)
end)

CreateThread(function()
    local assistanceDoorZone = CircleZone:Create(vector3(-1102.066, 2721.873, 18.8), 3.0, {
        name="cargo-assistance-door",
        heading=0.0,
        debugPoly=Config.DebugZones.neardoor,
        useZ=true,
    })
    assistanceDoorZone:onPlayerInOut(function(isPointInside)
        if isPointInside and cargoDropStarted and lookingForDoor then
            print("Door found!")
            exports['textUi']:HideTextUi('hide')
            cargoAssistanceMenu()
        else
            exports['qb-menu']:closeMenu()
        end
    end)
end)

CreateThread(function()
    local CargoDropZone = CircleZone:Create(vector3(3384.559, 5624.293, 1.867), 650.0, {
        name="cargo-drop-zone",
        heading=0.0,
        debugPoly=Config.DebugZones.cargodrop,
        useZ=true,
    })
    CargoDropZone:onPlayerInOut(function(isPointInside)
        if isPointInside and cargoDropStarted and cargoPlaneReady then
            print("Player entered CargoDropZone!")
            StartCargoDrop()
        else
            exports['textUi']:HideTextUi('hide')
        end
    end)
end)

-- Functions

function setWaypointToDoor()
    local time = math.random(10000,15000)
    cargodrop = true
    print("No awnser recieving mail in "..time.."ms")
    QBCore.Functions.Notify("No answer", "error" , 2000)
    Wait(time)
    QBCore.Functions.TriggerCallback('QBCore:HasItem', function(HasItem)
        if HasItem then
            TriggerServerEvent('qb-phone:server:sendNewMail', {
                sender = "Cargo Supplier",
                subject = "Missed call",
                message = "Hi, sorry i missed your phone call, your map will be updated soon with a GPS location, head over to the location asap and someone can further assist you",
            })
            print("Mail recieved, setting waypoint in "..time.."ms")
        else
          QBCore.Functions.Notify("Instructions were sent to your phone but you dont have one!", "error" , 5000)
        end
    end, 'phone')
    Wait(time)
    cargoDropStarted = true
    QBCore.Functions.Notify("Map updated with gps coordinates")
    PlaySoundFrontend(-1, "WAYPOINT_SET", "HUD_FRONTEND_DEFAULT_SOUNDSET", 1)
    SetNewWaypoint(-1141.948, 2679.802)
    print("Waypoint set at -1141.948, 2679.802")
end

function cargoAssistanceMenu()
    exports['qb-menu']:showHeader({
        {
            header = "Cargo Supplier Assistance",
            txt = "",
            isMenuHeader = true,
        },
        {
            header = "Knock on door", 
            txt = "",
            params = {
                event = "doj:client:taskWalkToDoor",
            }
        }
    })
end

function RequestTheModel(model)
	RequestModel(model)
    print("Requesting ped")
	while not HasModelLoaded(model) do
		Wait(0)
	end
end

function loadAnimDict(dict)
    while (not HasAnimDictLoaded(dict)) do
        RequestAnimDict(dict)
        Wait(5)
    end
end

function spawnCargoAssistPed()
    RequestTheModel('a_m_m_hillbilly_02')
    local ped = PlayerPedId()
    print("walking away from door.. making room for ped")
    TaskGoStraightToCoord(ped,  vector3(-1100.339, 2723.371, 18.8),  1.0,  3000,  131.65,  0.0)
    Wait(3000)
    CargoPed = CreatePed(30, `a_m_m_hillbilly_02`, -1101.57, 2722.333, 17.8, 313.667, true, false)
    print("Ped spawned.. waiting for qb-target response")
    FreezeEntityPosition(CargoPed, true)
	SetEntityInvincible(CargoPed, true)
	SetBlockingOfNonTemporaryEvents(CargoPed, true)
    PlayPedAmbientSpeechNative(CargoPed, "Generic_Hows_It_Going", "Speech_Params_Force")
    QBCore.Functions.Notify("Yo whats up")
end

function setWaypointToAirDrop()
    local time = math.random(10000,15000)
    local alertTime = math.random(45000,60000)
    local finalTime = math.random(15000,20000)
    print("starting waypoint to fake coords in "..time.."ms")
    Wait(time)
    SetNewWaypoint(3732.921,3817.604)
    QBCore.Functions.Notify("Map updated with gps coordinates")
    PlaySoundFrontend(-1, "WAYPOINT_SET", "HUD_FRONTEND_DEFAULT_SOUNDSET", 1)
    print("fake waypoint set to 3732.921, 3817.604, Sending Alert in "..alertTime.."ms")
    Wait(alertTime)
    sendPlayerAlert()
    print("Starting final location in "..finalTime.."ms")
    Wait(finalTime)
    QBCore.Functions.Notify("Map updated but the gps coordinates were corrupted", "error")
    PlaySoundFrontend(-1, "5_Second_Timer", "DLC_HEISTS_GENERAL_FRONTEND_SOUNDS", 1)
    blip = AddBlipForCoord(3384.559,5624.293, 1.867)
    SetBlipSprite(blip, 161)
    SetBlipScale(blip, 0.7)
    SetBlipColour(blip, 0)
    SetBlipAlpha(blip, 120)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentSubstringPlayerName("Crate Drop")
    EndTextCommandSetBlipName(blip)
    cargoPlaneReady = true
    print("final stage ready, Setting blip location 3384.559, 5624.293, 1.867.. Wating for player to enter CargoDropZone")
end

function sendPlayerAlert()
    DeleteWaypoint()
    print("Sending player alert & removing old waypoint")
    QBCore.Functions.Notify("Urgent Message!", "error")
    PlaySoundFrontend(-1, "WAYPOINT_SET", "HUD_FRONTEND_DEFAULT_SOUNDSET", 1)
    QBCore.Functions.TriggerCallback('QBCore:HasItem', function(HasItem)
        if HasItem then
            TriggerServerEvent('qb-phone:server:sendNewMail', {
                sender = "Cargo Supplier",
                subject = "Problem with Location",
                message = "Yo man there was a problem with that location, We are going to update you with a new location for the drop off",
            })
        else
          QBCore.Functions.Notify("Instructions were sent to your phone but you dont have one!", "error" , 5000)
        end
    end, 'phone')
end

function StartCargoDrop()
    print("plane started")
    CreateThread(function()
        requiredModels = {"p_cargo_chute_s", "ex_prop_adv_case_sm", "cuban800", "s_m_m_pilot_02", "prop_box_wood02a_pu"}
        for i = 1, #requiredModels do
            RequestModel(GetHashKey(requiredModels[i]))
            while not HasModelLoaded(GetHashKey(requiredModels[i])) do
                Wait(0)
            end
        end
        RequestWeaponAsset(GetHashKey("weapon_flare"))
        while not HasWeaponAssetLoaded(GetHashKey("weapon_flare")) do
            Wait(0)
        end
        local rHeading = math.random(0, 360) + 0.0
        local planeSpawnDistance = (planeSpawnDistance and tonumber(planeSpawnDistance) + 0.0) or 400.0
        local theta = (rHeading / 180.0) * 3.14
        local rPlaneSpawn = vector3(3384.559, 5624.293, 1.867) - vector3(math.cos(theta) * planeSpawnDistance, math.sin(theta) * planeSpawnDistance, -500.0)
        local dx = 3384.559 - rPlaneSpawn.x
        local dy = 5624.293 - rPlaneSpawn.y
        local heading = GetHeadingFromVector_2d(dx, dy)
        aircraft = CreateVehicle(GetHashKey("cuban800"), rPlaneSpawn, heading, true, true)
        SetEntityHeading(aircraft, heading)
        SetVehicleDoorsLocked(aircraft, 2)
        SetEntityDynamic(aircraft, true)
        ActivatePhysics(aircraft)
        SetVehicleForwardSpeed(aircraft, 60.0)
        SetHeliBladesFullSpeed(aircraft)
        SetVehicleEngineOn(aircraft, true, true, false)
        ControlLandingGear(aircraft, 3)
        OpenBombBayDoors(aircraft)
        SetEntityProofs(aircraft, true, false, true, false, false, false, false, false)
        pilot = CreatePedInsideVehicle(aircraft, 1, GetHashKey("s_m_m_pilot_02"), -1, true, true)
        SetBlockingOfNonTemporaryEvents(pilot, true)
        SetPedRandomComponentVariation(pilot, false)
        SetPedKeepTask(pilot, true)
        SetPlaneMinHeightAboveTerrain(aircraft, 50)
        TaskVehicleDriveToCoord(pilot, aircraft, vector3(3384.559, 5624.293, 1.867) + vector3(0.0, 0.0, 500.0), 60.0, 0, GetHashKey("cuban800"), 262144, 15.0, -1.0)
        local droparea = vector2(3384.559, 5624.293)
        local planeLocation = vector2(GetEntityCoords(aircraft).x, GetEntityCoords(aircraft).y)
        while not IsEntityDead(pilot) and #(planeLocation - droparea) > 5.0 do
            Wait(100)
            planeLocation = vector2(GetEntityCoords(aircraft).x, GetEntityCoords(aircraft).y)
        end
        TaskVehicleDriveToCoord(pilot, aircraft, 0.0, 0.0, 500.0, 60.0, 0, GetHashKey("cuban800"), 262144, -1.0, -1.0)
        SetEntityAsNoLongerNeeded(pilot)
        SetEntityAsNoLongerNeeded(aircraft)
        local crateSpawn = vector3(3384.559, 5624.293, GetEntityCoords(aircraft).z - 5.0)
        print("plane dropped cargo, wait for cargo to descend")
        crate = CreateObject(GetHashKey("prop_box_wood02a_pu"), crateSpawn, true, true, true)
        SetEntityLodDist(crate, 1000)
        ActivatePhysics(crate)
        SetDamping(crate, 2, 0.1)
        SetEntityVelocity(crate, 0.0, 0.0, -0.2)
        parachute = CreateObject(GetHashKey("p_cargo_chute_s"), crateSpawn, true, true, true)
        SetEntityLodDist(parachute, 1000)
        SetEntityVelocity(parachute, 0.0, 0.0, -0.2)
        pickup = CreateObject(GetHashKey("ex_prop_adv_case_sm"), crateSpawn, true, true, true)
        ActivatePhysics(pickup)
        SetDamping(pickup, 2, 0.0245) 
        SetEntityVelocity(pickup, 0.0, 0.0, -0.2)
        soundID = GetSoundId()
        PlaySoundFromEntity(soundID, "Crate_Beeps", pickup, "MP_CRATE_DROP_SOUNDS", true, 0)
        AttachEntityToEntity(parachute, pickup, 0, 0.0, 0.0, 0.1, 0.0, 0.0, 0.0, false, false, false, false, 2, true)
        AttachEntityToEntity(pickup, crate, 0, 0.0, 0.0, 0.3, 0.0, 0.0, 0.0, false, false, true, false, 2, true)
        FreezeEntityPosition(crate, false)
        while HasObjectBeenBroken(crate) == false do
            Wait(0)
        end
        local parachuteCoords = vector3(GetEntityCoords(parachute))
        ShootSingleBulletBetweenCoords(parachuteCoords, parachuteCoords - vector3(0.0001, 0.0001, 0.0001), 0, false, GetHashKey("weapon_flare"), 0, true, false, -1.0)
        DetachEntity(parachute, true, true)
        DeleteEntity(parachute)
        DetachEntity(pickup)
    end)
end

function skillCheckCargoDrop()
    print("Memory game started")
    exports["memorygame"]:thermiteminigame(Config.minigame.correctBlocks, Config.minigame.incorrectBlocks, Config.minigame.timetoShow, Config.minigame.timetoLose,
    function()
        print("Memory game success")
        QBCore.Functions.Notify('Password accepted!', "success")
        QBCore.Functions.Progressbar("accepted", "Opening..", 5000, false, true, {
            disableMovement = true,
            disableCarMovement = true,
            disableMouse = false,
            disableCombat = true,
        }, {
            animDict = "mini@repair",
            anim = "fixing_a_player",
            flags = 16,
        }, {}, {}, function() -- Done
            ClearPedTasks(PlayerPedId())
            openCargoDropInventory()
        end, function() -- Cancel
            ClearPedTasks(PlayerPedId())
            QBCore.Functions.Notify("Canceled!", "error")
        end)
    end,
    function()
        print("Memory game failed try again")
        QBCore.Functions.Notify('Wrong password, try again!', "error")
    end)
end

function openCargoDropInventory()
    local playerCoords = GetEntityCoords(PlayerPedId())
    local cargoObject = GetClosestObjectOfType(playerCoords.x,playerCoords.y,playerCoords.z,3.0,GetHashKey("ex_prop_adv_case_sm"),0,0,0)
    local chance = math.random(1, 5)
	if chance <= 4 then
        print("common cargo inventory opened, chance: "..chance)
        local dirtyCargoItems = {} 
        dirtyCargoItems.label = "Cargo Drop"
        dirtyCargoItems.items = Config.commonCargoRewards
        dirtyCargoItems.slots = #Config.commonCargoRewards
        TriggerServerEvent("inventory:server:OpenInventory", "shop", "dirtyCargo_", dirtyCargoItems)
    else
        print("rare cargo inventory opened, chance: "..chance)
        local cleanCargoItems = {} 
        cleanCargoItems.label = "Cargo Drop"
        cleanCargoItems.items = Config.rareCargoRewards
        cleanCargoItems.slots = #Config.rareCargoRewards
        TriggerServerEvent("inventory:server:OpenInventory", "shop", "cleanCargo_", cleanCargoItems)
	end
    if DoesEntityExist(cargoObject) then
        SetEntityAsMissionEntity(cargoObject, true, true)
        RemoveBlip(blip)
        print(cargoObject.." Exists, Removing blip")
        Wait(3000)
        DeleteEntity(cargoObject)
        StopSound(soundID)
        ReleaseSoundId(soundID)
        print("Stoping sound: "..soundID.." & Deleting: "..cargoObject)
        Wait(2000)
        cargodrop = false
        print("cargo drop reset...")
    end
end








-- spawnAngryPed()
-- function spawnAngryPed()
--     local AngryPedHash = GetHashKey('a_m_m_hillbilly_02')
--     RequestModel(AngryPedHash)
--     AngryPed = CreatePed(30, AngryPedHash, -1128.081, 2708.321, 18.8, 39.467, true, false)
--     SetPedArmour(AngryPed, 100)
--     SetPedAsEnemy(AngryPed, true)
--     GiveWeaponToPed(AngryPed, GetHashKey('WEAPON_PISTOL'), 250, false, true)
--     TaskCombatPed(AngryPed, PlayerPedId())
--     SetPedAccuracy(AngryPed, 100)
--     SetPedDropsWeaponsWhenDead(AngryPed, false)
-- end

















