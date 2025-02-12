local QBCore = exports['qb-core']:GetCoreObject()
local activeGPS = {}

-- Araç GPS'i ekleme
QBCore.Commands.Add('aracgps', 'Araç GPS sistemi', {{name = 'callsign', help = 'Araç çağrı kodu'}}, true, function(source, args)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    
    if not Config.AllowedJobs[Player.PlayerData.job.name] or not Config.AllowedJobs[Player.PlayerData.job.name].allowed then
        TriggerClientEvent('QBCore:Notify', src, 'Bu komutu kullanma yetkiniz yok!', 'error')
        return
    end

    -- Aktif GPS kontrolü
    if activeGPS[src] then
        TriggerClientEvent('QBCore:Notify', src, 'Zaten aktif bir GPS sinyaliniz var! Önce /aracgpskapat yapın.', 'error')
        return
    end

    -- Araçta olup olmadığını kontrol et
    TriggerClientEvent('vehicle-gps:client:checkVehicle', src, args[1])
end)

-- Araç kontrolü sonrası GPS ekleme
RegisterNetEvent('vehicle-gps:server:addGPSAfterCheck')
AddEventHandler('vehicle-gps:server:addGPSAfterCheck', function(callSign, inVehicle)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)

    if not inVehicle then
        TriggerClientEvent('QBCore:Notify', src, 'Bu komutu kullanmak için araçta olmalısınız!', 'error')
        return
    end

    if not callSign then
        TriggerClientEvent('QBCore:Notify', src, 'Geçerli bir çağrı kodu girmelisiniz!', 'error')
        return
    end
    
    activeGPS[src] = {
        callSign = callSign,
        name = Player.PlayerData.charinfo.firstname .. ' ' .. Player.PlayerData.charinfo.lastname,
        job = Player.PlayerData.job.name
    }

    TriggerClientEvent('vehicle-gps:client:updateGPSData', -1, activeGPS)
    TriggerClientEvent('QBCore:Notify', src, 'GPS sistemi aktif edildi: ' .. callSign, 'success')
end)

-- GPS görüntülemeyi aç
QBCore.Commands.Add('aracgpsac', 'GPS görüntülemeyi aç', {}, true, function(source)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    
    if not Config.AllowedJobs[Player.PlayerData.job.name] or not Config.AllowedJobs[Player.PlayerData.job.name].allowed then
        TriggerClientEvent('QBCore:Notify', src, 'Bu komutu kullanma yetkiniz yok!', 'error')
        return
    end

    TriggerClientEvent('vehicle-gps:client:showGPS', src, true)
    TriggerClientEvent('QBCore:Notify', src, 'GPS görüntüleme açıldı', 'success')
end)

-- GPS görüntülemeyi kapat
QBCore.Commands.Add('aracgpskapat', 'GPS görüntülemeyi kapat', {}, true, function(source)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    
    if not Config.AllowedJobs[Player.PlayerData.job.name] or not Config.AllowedJobs[Player.PlayerData.job.name].allowed then
        TriggerClientEvent('QBCore:Notify', src, 'Bu komutu kullanma yetkiniz yok!', 'error')
        return
    end

    if activeGPS[src] then
        activeGPS[src] = nil
        TriggerClientEvent('vehicle-gps:client:updateGPSData', -1, activeGPS)
    end

    TriggerClientEvent('vehicle-gps:client:showGPS', src, false)
    TriggerClientEvent('QBCore:Notify', src, 'GPS görüntüleme kapatıldı', 'success')
end)

-- GPS kontrol
QBCore.Commands.Add('aracgpskontrol', 'Aktif GPS listesi', {}, true, function(source)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    
    if not Config.AllowedJobs[Player.PlayerData.job.name] or not Config.AllowedJobs[Player.PlayerData.job.name].allowed then
        TriggerClientEvent('QBCore:Notify', src, 'Bu komutu kullanma yetkiniz yok!', 'error')
        return
    end

    -- GPS listesini client'a gönder
    TriggerClientEvent('vehicle-gps:client:showGPSList', src, activeGPS)
end)

-- Oyuncu çıkış yaptığında GPS'i kaldır
AddEventHandler('playerDropped', function()
    if activeGPS[source] then
        activeGPS[source] = nil
        TriggerClientEvent('vehicle-gps:client:updateGPSData', -1, activeGPS)
    end
end)

-- GPS güncelleme eventi
RegisterNetEvent('vehicle-gps:server:requestGPSUpdate')
AddEventHandler('vehicle-gps:server:requestGPSUpdate', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    
    if not Config.AllowedJobs[Player.PlayerData.job.name] or not Config.AllowedJobs[Player.PlayerData.job.name].allowed then
        return
    end
    
    -- Tüm aktif GPS verilerini gönder
    TriggerClientEvent('vehicle-gps:client:updateGPSData', src, activeGPS)
end)

-- Meslek değiştiğinde GPS'i kaldır
RegisterNetEvent('vehicle-gps:server:removeGPSOnJobChange')
AddEventHandler('vehicle-gps:server:removeGPSOnJobChange', function()
    local src = source
    if activeGPS[src] then
        activeGPS[src] = nil
        TriggerClientEvent('vehicle-gps:client:updateGPSData', -1, activeGPS)
    end
end) 