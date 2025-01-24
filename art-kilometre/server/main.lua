local QBCore = exports['qb-core']:GetCoreObject()

RegisterServerEvent('ExeLds:updateCar')
AddEventHandler('ExeLds:updateCar', function(plate)
    local src = source
    MySQL.Sync.execute('UPDATE player_vehicles SET kilometre = kilometre + @kilometre WHERE plate = @plate', {
        ['@kilometre'] = 1,
        ['@plate'] = plate
    })
end)

QBCore.Functions.CreateCallback('ExeLds:getKilometer', function(source, cb, plate)
    MySQL.Async.fetchAll("SELECT kilometre FROM player_vehicles WHERE plate = @plate", { ["@plate"] = plate }, function(result)
        if result[1] then
            cb(result[1].kilometre)
        else
            cb(0)  -- Return 0 if no result is found
        end
    end)
end)

QBCore.Functions.CreateCallback('ExeLds:getOwnedCarInfo', function(source, cb, plate)
    MySQL.Async.fetchAll("SELECT citizenid FROM player_vehicles WHERE plate = @plate", { ["@plate"] = plate }, function(result)
        if result[1] then
            cb(true)
        else
            cb(false)
        end
    end)
end)
