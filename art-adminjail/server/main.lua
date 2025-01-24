local QBCore = exports['qb-core']:GetCoreObject()



RegisterCommand("adminjail", function(source, args, rawCommand)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)

    if not (QBCore.Functions.HasPermission(src, 'admin') or QBCore.Functions.HasPermission(src, 'god')) then
        TriggerClientEvent('QBCore:Notify', src, "Yeterli yetkiniz yok!", "error")
        return
    end

    local targetId = tonumber(args[1])
    local jailTime = tonumber(args[2])
    local reason = table.concat(args, " ", 3)

    if not targetId or not jailTime then
        TriggerClientEvent('QBCore:Notify', src, "Geçerli bir oyuncu ID'si ve süre girin!", "error")
        return
    end

    local targetPlayer = QBCore.Functions.GetPlayer(targetId)
    if not targetPlayer then
        TriggerClientEvent('QBCore:Notify', src, "Bu oyuncu çevrimiçi değil!", "error")
        return
    end

    local citizenId = targetPlayer.PlayerData.citizenid
    local license = targetPlayer.PlayerData.license
    local name = targetPlayer.PlayerData.charinfo.firstname .. " " .. targetPlayer.PlayerData.charinfo.lastname

   
    exports.oxmysql:execute('SELECT * FROM jail_data WHERE citizenid = ?', {citizenId}, function(result)
        if result[1] then
           
            exports.oxmysql:execute('UPDATE jail_data SET jail_time = ?, reason = ? WHERE citizenid = ?', {
                os.time() + jailTime, reason, citizenId
            })
            
            TriggerClientEvent("adminjail:sendToJail", targetId, jailTime, reason)
            TriggerClientEvent('QBCore:Notify', src, name .. " başarılı bir şekilde tekrar hapise gönderildi.", "success")
        else
            
            exports.oxmysql:execute('INSERT INTO jail_data (citizenid, license, name, jail_time, reason) VALUES (?, ?, ?, ?, ?)', {
                citizenId, license, name, os.time() + jailTime, reason
            })
            TriggerClientEvent("adminjail:sendToJail", targetId, jailTime, reason)
            TriggerClientEvent('QBCore:Notify', src, name .. " başarılı bir şekilde hapise gönderildi.", "success")
        end
    end)
end, false)


RegisterCommand("adminunjail", function(source, args, rawCommand)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)

    if not (QBCore.Functions.HasPermission(src, 'admin') or QBCore.Functions.HasPermission(src, 'god')) then
        TriggerClientEvent('QBCore:Notify', src, "Yeterli yetkiniz yok!", "error")
        return
    end

    local targetId = tonumber(args[1])
    if not targetId then
        TriggerClientEvent('QBCore:Notify', src, "Geçerli bir oyuncu ID'si girin!", "error")
        return
    end

    local targetPlayer = QBCore.Functions.GetPlayer(targetId)
    if not targetPlayer then
        TriggerClientEvent('QBCore:Notify', src, "Bu oyuncu çevrimiçi değil!", "error")
        return
    end

    local citizenId = targetPlayer.PlayerData.citizenid

    
    exports.oxmysql:execute('DELETE FROM jail_data WHERE citizenid = ?', {citizenId})
    TriggerClientEvent("adminjail:releaseFromJail", targetId)

    TriggerClientEvent('QBCore:Notify', targetId, "Hapis süreniz sona erdi. Hapisten çıktınız!", "success")
    TriggerClientEvent('QBCore:Notify', src, targetPlayer.PlayerData.charinfo.firstname .. " hapisten çıkarıldı.", "success")
end, false)


Citizen.CreateThread(function()
    while true do
        Citizen.Wait(60000) 

        
        exports.oxmysql:execute('SELECT * FROM jail_data', {}, function(results)
            for _, row in ipairs(results) do
                local currentTime = os.time()
                if currentTime >= row.jail_time then
                    local targetPlayer = QBCore.Functions.GetPlayerByCitizenId(row.citizenid)
                    if targetPlayer then
                        TriggerClientEvent("adminjail:releaseFromJail", targetPlayer.PlayerData.source)
                        TriggerClientEvent('QBCore:Notify', targetPlayer.PlayerData.source, "Hapis süreniz sona erdi. Hapisten çıktınız!", "success")
                    end

                    exports.oxmysql:execute('DELETE FROM jail_data WHERE citizenid = ?', {row.citizenid})
                    TriggerClientEvent("adminjail:releaseFromJail", targetId)
                end
            end
        end)
    end
end)


AddEventHandler('QBCore:Player:SetPlayerData', function(playerData)
    local citizenId = playerData.citizenid
    local license = playerData.license

    
    exports.oxmysql:execute('SELECT * FROM jail_data WHERE citizenid = ? AND license = ?', {citizenId, license}, function(result)
        if result[1] then
            local remainingTime = result[1].jail_time - os.time()

            if remainingTime > 0 then
                
                TriggerClientEvent("adminjail:sendToJail", playerData.source, remainingTime, result[1].reason)
                TriggerClientEvent('QBCore:Notify', playerData.source, "Hapisteki süre devam ediyor!", "error")
            else
                exports.oxmysql:execute('DELETE FROM jail_data WHERE citizenid = ?', {citizenId})
                TriggerClientEvent("adminjail:releaseFromJail", targetId)
            end
        end
    end)
end)

