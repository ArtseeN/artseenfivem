local QBCore = exports['qb-core']:GetCoreObject()

RegisterServerEvent('attribute:updateAttribute')
AddEventHandler('attribute:updateAttribute', function(newAttribute)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    
    if Player then
        MySQL.Async.execute('INSERT INTO character_attributes (citizenid, attributes) VALUES (?, ?) ON DUPLICATE KEY UPDATE attributes = ?', {
            Player.PlayerData.citizenid,
            newAttribute,
            newAttribute
        }, function(rowsChanged)
            if rowsChanged > 0 then
                TriggerClientEvent('chat:addMessage', src, {
                    color = {0, 255, 0},
                    args = {'Sistem', 'Karakter özellikleriniz kaydedildi.'}
                })
            end
        end)
    end
end)

RegisterServerEvent('attribute:requestAttributes')
AddEventHandler('attribute:requestAttributes', function(targetId)
    local src = source
    local Target = QBCore.Functions.GetPlayer(targetId)
    
    if Target then
        MySQL.Async.fetchAll('SELECT attributes FROM character_attributes WHERE citizenid = ?', {
            Target.PlayerData.citizenid
        }, function(result)
            if result[1] and result[1].attributes then
                TriggerClientEvent('attribute:receiveAttributes', src, result[1].attributes)
            else
                TriggerClientEvent('attribute:receiveAttributes', src, nil)
            end
        end)
    else
        TriggerClientEvent('attribute:receiveAttributes', src, nil)
    end
end) 