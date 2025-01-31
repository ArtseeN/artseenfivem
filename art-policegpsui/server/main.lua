local QBCore = exports['qb-core']:GetCoreObject()
local activeVehicleGPS = {}

-- Item kullanımını kaydet
QBCore.Functions.CreateUseableItem('police_gps', function(source)
    local src = source
    TriggerClientEvent('police-gps:client:useGPS', src)
end)

RegisterNetEvent('vehicle-gps:server:activateGPS')
AddEventHandler('vehicle-gps:server:activateGPS', function(code, plate, model, job)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    
    if not Player then return end
    
    -- Kod kontrolü
    if not code or code == '' then
        TriggerClientEvent('QBCore:Notify', src, 'Geçersiz araç kodu!', 'error')
        return
    end
    
    -- Yetki kontrolü
    local isAllowed = false
    for _, allowedJob in ipairs(Config.AllowedJobs) do
        if job == allowedJob then
            isAllowed = true
            break
        end
    end
    
    if not isAllowed then
        TriggerClientEvent('QBCore:Notify', src, 'Bu işlemi yapmaya yetkiniz yok!', 'error')
        return
    end
    
    activeVehicleGPS[code] = {
        plate = plate,
        model = model,
        job = job,
        officerName = Player.PlayerData.charinfo.firstname .. ' ' .. Player.PlayerData.charinfo.lastname,
        officerId = Player.PlayerData.citizenid
    }
    
    TriggerClientEvent('vehicle-gps:client:updateGPSList', -1, activeVehicleGPS)
    TriggerClientEvent('QBCore:Notify', src, 'Araç GPS sistemi aktif edildi: ' .. code, 'success')
end)

RegisterNetEvent('vehicle-gps:server:requestGPSList')
AddEventHandler('vehicle-gps:server:requestGPSList', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    
    if not Player then return end
    
    local playerJob = Player.PlayerData.job.name
    local isAllowed = false
    for _, job in ipairs(Config.AllowedJobs) do
        if playerJob == job then
            isAllowed = true
            break
        end
    end
    
    if not isAllowed then
        TriggerClientEvent('QBCore:Notify', src, 'Bu bilgilere erişim yetkiniz yok!', 'error')
        return
    end
    
    local menuItems = {}
    for code, data in pairs(activeVehicleGPS) do
        table.insert(menuItems, {
            header = 'Araç Kodu: ' .. code,
            txt = string.format('Model: %s\nPlaka: %s\nMemur: %s\nDepartman: %s',
                data.model,
                data.plate,
                data.officerName,
                Config.JobLabels[data.job] or data.job
            ),
            params = {
                event = 'vehicle-gps:client:showGPSDetails',
                args = {
                    code = code,
                    data = data
                }
            }
        })
    end
    
    TriggerClientEvent('qb-menu:client:openMenu', src, menuItems)
end)

RegisterNetEvent('vehicle-gps:server:removeGPS')
AddEventHandler('vehicle-gps:server:removeGPS', function(code)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    
    if not Player then return end
    
    if Player.PlayerData.job.name ~= 'police' and Player.PlayerData.job.name ~= 'sheriff' then
        TriggerClientEvent('QBCore:Notify', src, 'Bu işlemi yapmaya yetkiniz yok!', 'error')
        return
    end
    
    if activeVehicleGPS[code] then
        activeVehicleGPS[code] = nil
        TriggerClientEvent('vehicle-gps:client:updateGPSList', -1, activeVehicleGPS)
        TriggerClientEvent('QBCore:Notify', src, code .. ' kodlu araç GPS\'i kaldırıldı', 'success')
    else
        TriggerClientEvent('QBCore:Notify', src, 'Bu kodda aktif bir GPS bulunamadı!', 'error')
    end
end) 