local QBCore = exports['qbx-core']:GetCoreObject()
local PlayerData = QBCore.Functions.GetPlayerData()

-- Variabels
local busBlip, InDelBus, route, max, stationsZone, LastMisson, MissionBlip = nil, false, 1, #Config.Stations, false, nil, nil

-- Function 

nextStop = function()
    route = route <= (max - 1) and route + 1 or "finish"
end

removeMissionBlip = function()
    if MissionBlip then
        RemoveBlip(MissionBlip)
        MissionBlip = nil
    end
end

GetMissionLocation = function()
    removeMissionBlip()
    if route == "finish" then
        SetBlipRoute(busBlip, true)
        SetBlipRouteColour(busBlip, 3)
        
        meterData = {
            ["nextstation"] = 'Back To Depot',
            ["TotalPrice"] = 0
        } 
    
        SendNUIMessage({
            action = "updateMeter",
            meterData = meterData
        })
        lib.hideTextUI()
        return
    end
    if Config.Debug and route ~= "finish" then print(Config.Stations[route][2]) end
    MissionBlip = AddBlipForCoord(Config.Stations[route][2].x, Config.Stations[route][2].y, Config.Stations[route][2].z)
    SetBlipColour(MissionBlip, 3)
    SetBlipRoute(MissionBlip, true)
    SetBlipRouteColour(MissionBlip, 3)
    LastMisson = route
    local shownTextUI = false
    DeliverZone = lib.zones.sphere({
        name = "missions",
        coords = Config.Stations[route][2].xyz,
        radius = 7,
        debug = Config.Debug,
        onEnter = function()
            if Config.Debug then print("Di dalam zona pengambilan penumpang") end
            stationsZone = true
            if not shownTextUI then
                lib.showTextUI("[E] - Bus Stop")
                shownTextUI = true
            end
        end,
        onExit = function()
            lib.hideTextUI()
            shownTextUI = false
            stationsZone = false
        end
    })
    return Config.Stations[route]
end

updateBlip = function()
    local coords = Config.Location
    busBlip = AddBlipForCoord(coords.x, coords.y, coords.z)
    SetBlipSprite(busBlip, 513)
    SetBlipDisplay(busBlip, 4)
    SetBlipScale(busBlip, 0.6)
    SetBlipAsShortRange(busBlip, true)
    SetBlipColour(busBlip, 49)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentSubstringPlayerName("Bus Depot")
    EndTextCommandSetBlipName(busBlip)
end

EnumerateEntitiesWithinDistance = function(entities, isPlayerEntities, coords, maxDistance)
	local nearbyEntities = {}
	if coords then
		coords = vector3(coords.x, coords.y, coords.z)
	else
		coords = GetEntityCoords(cache.ped)
	end
	for k, entity in pairs(entities) do
		local distance = #(coords - GetEntityCoords(entity))
		if distance <= maxDistance then
			nearbyEntities[#nearbyEntities+1] = isPlayerEntities and k or entity
		end
	end
	return nearbyEntities
end

GetVehiclesInArea = function(coords, maxDistance) -- Vehicle inspection in designated area
	return EnumerateEntitiesWithinDistance(GetGamePool('CVehicle'), false, coords, maxDistance)
end

IsSpawnPointClear = function(coords, maxDistance) -- Check the spawn point to see if it's empty or not:
	return #GetVehiclesInArea(coords, maxDistance) == 0
end

spawnBus = function()
    local coords = Config.Location
    local CanSpawn = IsSpawnPointClear(coords, 2.0)
    if CanSpawn then
        if Config.Debug then print("Spawning...") end
        local netId = lib.callback.await('nz_busjob:server:spawnBus', false, Config.AllowedVehicles, Config.Location)
        local veh = NetToVeh(netId)
        SetVehicleFuelLevel(veh, 100.0)
        SetVehicleEngineOn(veh, true, true, false)
        if Config.Debug then print(netId,veh) end

        local MissionData = GetMissionLocation()
        if Config.Debug then print(MissionData[1]) end
        local meterData = {
            ["nextstation"] = MissionData[1]
        }
        
        SendNUIMessage({
            action = "openMeter",
            toggle = true,
            meterData = meterData
        })
        SendNUIMessage({
            action = "toggleMeter"
        })
    else
        QBCore.Functions.Notify("Tidak dapat spawn bus", "error")
    end
end

spawnPed = function()
    if Config.Debug then print("Spawning ped object") end
    
    RequestModel(Config.Ped.model)
        while not HasModelLoaded(Config.Ped.model) do
            Wait(0)
            print("Waiting for model to load")
        end
    local ped = CreatePed(0, Config.Ped.model, Config.Ped.coords.x, Config.Ped.coords.y, Config.Ped.coords.z - 1, Config.Ped.coords.w, false, false)
    FreezeEntityPosition(ped, true)
    SetEntityInvincible(ped, true)
    SetBlockingOfNonTemporaryEvents(ped, true)
    TaskStartScenarioInPlace(ped, Config.Ped.scenario, true, true)

    exports.ox_target:addLocalEntity(ped, { {
        name = 'MainPed',
        icon = 'fa-solid fa-car-side',
        label = "Take Bus",
        distance = 1.5,
        onSelect = function()
            spawnBus()
        end
    } })

end

isPlayerVehicleABus = function()
    if not cache.vehicle then return false end
    local veh = GetEntityModel(cache.vehicle)

    if veh == Config.AllowedVehicles then
        return true
    end

    return false
end

delBus = function()
    local shownTextUI = false
    if VehicleZone then
        VehicleZone:remove()
        VehicleZone = nil
    end

    VehicleZone = lib.zones.sphere({
        name = "delete_bus",
        coords = Config.Location.xyz,
        radius = 7,
        debug = Config.Debug,
        onEnter = function()
            if isPlayerVehicleABus then 
                if not shownTextUI then
                    lib.showTextUI("[E] - Job Vehicles")
                    shownTextUI = true
                end
                InDelBus = true
            end
        end,
        onExit = function()
            shownTextUI = false
            InDelBus = false
            Wait(1000)
            lib.hideTextUI()
        end
    })
    
end

-- Events
AddEventHandler('onResourceStart', function(resourceName)
    -- handles script restarts
    if GetCurrentResourceName() ~= resourceName then return end
    -- DeliverZone:remove()
    spawnPed()
    updateBlip()
    delBus()
end)

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    PlayerData = QBCore.Functions.GetPlayerData()
    updateBlip()
    delBus()
    spawnPed()
end)

RegisterNetEvent('QBCore:Client:OnPlayerUnload', function()
    PlayerData = {}
    updateBlip()
    delBus()
end)

RegisterNetEvent('QBCore:Player:SetPlayerData', function(val)
    PlayerData = val
    updateBlip()
    delBus()
end)

-- command + keymapping
RegisterCommand('+bus_delveh', function()
    if  InDelBus then
        DeleteVehicle(cache.vehicle)
        lib.hideTextUI()
        SendNUIMessage({
            action = "openMeter",
            toggle = false
        })
    end
end, false)
RegisterKeyMapping('+bus_delveh', 'Bus Job', 'keyboard', 'e')

RegisterCommand('+bus_takepassangger', function()
    if Config.Debug then print(stationsZone) end
    if not stationsZone and route == "finish" then return end
    lib.hideTextUI()
    stationsZone = false

    DeliverZone:remove()
    DeliverZone = nil
    nextStop()
    local MissionData = GetMissionLocation()
    if route == "finish" then return end
    if Config.Debug then print(json.encode(MissionData)) end
    local meterData = {
        ["nextstation"] = MissionData[1],
        ["TotalPrice"] = 0
    }
    SendNUIMessage({
        action = "updateMeter",
        meterData = meterData
    })
end, false)
RegisterKeyMapping('+bus_takepassangger', 'Bus Job', 'keyboard', 'e')

-- debug
RegisterCommand("debug", function(source, args, rawCommand)
    if Config.debug then return end
    SendNUIMessage({
        action = "openMeter",
        toggle = true,
        meterData = Config.Meter
    })
    SendNUIMessage({
        action = "toggleMeter"
    })
    print("debug")
end, false)
