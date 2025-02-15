local activeStatuses = {}

RegisterServerEvent('status:sync')
AddEventHandler('status:sync', function(newStatuses)
    activeStatuses = newStatuses
    TriggerClientEvent('status:syncClient', -1, activeStatuses)
end) 