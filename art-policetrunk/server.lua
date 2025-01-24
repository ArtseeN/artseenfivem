local QBCore = exports['qb-core']:GetCoreObject()


RegisterNetEvent('qb-weapons:giveWeapon')
AddEventHandler('qb-weapons:giveWeapon', function(weapon)
    local src = source
    local xPlayer = QBCore.Functions.GetPlayer(src)

   
    if xPlayer.PlayerData.job.name ~= "police" then
        TriggerClientEvent('QBCore:Notify', src, "Bu işlemi sadece polisler yapabilir!", "error")
        return
    end

  
    if xPlayer.Functions.GetItemByName(weapon) then
        TriggerClientEvent('QBCore:Notify', src, "Bu silah zaten envanterinizde!", "error")
        return
    end

   
    xPlayer.Functions.AddItem(weapon, 1)  
    TriggerClientEvent('QBCore:Notify', src, "Silah alındı: " .. weapon, "success")
end)


RegisterNetEvent('qb-weapons:removeWeapon')
AddEventHandler('qb-weapons:removeWeapon', function(weapon)
    local src = source
    local xPlayer = QBCore.Functions.GetPlayer(src)

    if xPlayer.PlayerData.job.name ~= "police" then
        TriggerClientEvent('QBCore:Notify', src, "Bu işlemi sadece polisler yapabilir!", "error")
        return
    end

    if xPlayer.Functions.GetItemByName(weapon) then
        xPlayer.Functions.RemoveItem(weapon, 1) 
        TriggerClientEvent('QBCore:Notify', src, "Silah bırakıldı: " .. weapon, "success")
    else
        TriggerClientEvent('QBCore:Notify', src, "Envanterinizde bu silah yok!", "error")
    end
end)
