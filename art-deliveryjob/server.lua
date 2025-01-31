local QBCore = exports['qb-core']:GetCoreObject()

RegisterNetEvent('qb-delivery:server:reward', function(amount)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    
    if Player then
        Player.Functions.AddMoney('cash', amount, "delivery-job-payment")
        TriggerClientEvent('QBCore:Notify', src, amount .. '$ kazandın!', 'success')
    end
end) 