local QBCore = exports['qbx-core']:GetCoreObject()

lib.callback.register('nz_busjob:server:spawnBus', function(source, model, coords)
    local netId = QBCore.Functions.CreateVehicle(source, model, coords, true)
    if not netId or netId == 0 then return end
    local veh = NetworkGetEntityFromNetworkId(netId)
    if not veh or veh == 0 then return end
    
    if Config.Debug then print(netId, veh) end
    local plate = "BUS " .. math.random(100, 999)
    SetVehicleNumberPlateText(veh, plate)
    TriggerClientEvent('vehiclekeys:client:SetOwner', source, plate)
    if Config.Debug then print("Spawnning car...") end
    return netId
end)

if Config.Debug then print("Server Side Running...") end