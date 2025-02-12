local QBCore = exports['qb-core']:GetCoreObject()
local showGPS = false
local gpsBlips = {}
local lastVehiclePositions = {} -- Son araç konumlarını tutacak tablo

-- GPS verilerini güncelle
RegisterNetEvent('vehicle-gps:client:updateGPSData')
AddEventHandler('vehicle-gps:client:updateGPSData', function(gpsData)
    if not showGPS then return end
    
    -- Mevcut blipleri temizle
    for _, blip in pairs(gpsBlips) do
        if DoesBlipExist(blip) then
            RemoveBlip(blip)
        end
    end
    gpsBlips = {}

    -- Yeni blipleri oluştur
    local Player = QBCore.Functions.GetPlayerData()
    if not Config.AllowedJobs[Player.job.name] or not Config.AllowedJobs[Player.job.name].allowed then return end

    for serverId, data in pairs(gpsData) do
        local targetPed = GetPlayerPed(GetPlayerFromServerId(serverId))
        if DoesEntityExist(targetPed) then
            local vehicle = GetVehiclePedIsIn(targetPed, false)
            local coords
            
            if vehicle ~= 0 then
                -- Eğer kişi araçtaysa, aracın konumunu kaydet
                coords = GetEntityCoords(vehicle)
                lastVehiclePositions[serverId] = coords
            else
                -- Eğer kişi araçta değilse, son kaydedilen konumu kullan
                coords = lastVehiclePositions[serverId]
            end

            if coords then
                local blip = AddBlipForCoord(coords.x, coords.y, coords.z)
                SetBlipSprite(blip, Config.BlipSettings.sprite)
                local blipColor = Config.AllowedJobs[data.job].blipColor
                SetBlipColour(blip, blipColor)
                SetBlipScale(blip, Config.BlipSettings.scale)
                SetBlipAsShortRange(blip, Config.BlipSettings.shortRange)
                BeginTextCommandSetBlipName("STRING")
                AddTextComponentString(data.callSign)
                EndTextCommandSetBlipName(blip)
                table.insert(gpsBlips, blip)
            end
        end
    end
end)

-- GPS görüntüleme durumunu değiştir
RegisterNetEvent('vehicle-gps:client:showGPS')
AddEventHandler('vehicle-gps:client:showGPS', function(state)
    showGPS = state
    if not state then
        for _, blip in pairs(gpsBlips) do
            if DoesBlipExist(blip) then
                RemoveBlip(blip)
            end
        end
        gpsBlips = {}
        lastVehiclePositions = {} -- GPS kapatıldığında son konumları da temizle
    end
end)

-- GPS konumlarını güncelle
CreateThread(function()
    while true do
        Wait(1000)
        if showGPS then
            TriggerServerEvent('vehicle-gps:server:requestGPSUpdate')
        end
    end
end)

-- GPS Kontrol Menüsü
RegisterNetEvent('vehicle-gps:client:showGPSList')
AddEventHandler('vehicle-gps:client:showGPSList', function(gpsData)
    local menuItems = {}
    
    for _, data in pairs(gpsData) do
        table.insert(menuItems, {
            header = "📍 " .. data.callSign,
            txt = ("Memur: %s | Birim: %s"):format(data.name, data.job),
            params = {
                event = "vehicle-gps:client:selectGPSItem",
                args = {
                    callSign = data.callSign,
                    name = data.name,
                    job = data.job
                }
            }
        })
    end
    
    if #menuItems == 0 then
        table.insert(menuItems, {
            header = "GPS Listesi",
            txt = "Aktif GPS sinyali bulunmuyor",
            params = {
                event = "vehicle-gps:client:selectGPSItem"
            }
        })
    end
    
    -- Menüyü göster
    exports['qb-menu']:openMenu(menuItems)
end)

-- Menü item seçildiğinde
RegisterNetEvent('vehicle-gps:client:selectGPSItem')
AddEventHandler('vehicle-gps:client:selectGPSItem', function(data)
    if not data or not data.callSign then return end
    
    -- İsterseniz buraya seçilen GPS için ek özellikler ekleyebilirsiniz
    -- Örneğin: Seçilen GPS'e rota çizme gibi
    QBCore.Functions.Notify(('Seçilen GPS: %s - %s'):format(data.callSign, data.name), 'primary')
end)

-- Araç kontrolü eventi (mevcut kodların sonuna ekleyin)
RegisterNetEvent('vehicle-gps:client:checkVehicle')
AddEventHandler('vehicle-gps:client:checkVehicle', function(callSign)
    local ped = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(ped, false)
    
    -- Araçta olup olmadığını kontrol et
    local inVehicle = vehicle ~= 0 and GetPedInVehicleSeat(vehicle, -1) == ped
    
    -- Sonucu server'a gönder
    TriggerServerEvent('vehicle-gps:server:addGPSAfterCheck', callSign, inVehicle)
end)

-- Mevcut kodların üstüne ekleyin
RegisterNetEvent('QBCore:Client:OnJobUpdate')
AddEventHandler('QBCore:Client:OnJobUpdate', function(job)
    -- Yeni meslek izin verilen mesleklerden değilse GPS'i kapat
    if not Config.AllowedJobs[job.name] or not Config.AllowedJobs[job.name].allowed then
        showGPS = false
        -- Blipleri temizle
        for _, blip in pairs(gpsBlips) do
            if DoesBlipExist(blip) then
                RemoveBlip(blip)
            end
        end
        gpsBlips = {}
        lastVehiclePositions = {}
        -- Server'a bildir
        TriggerServerEvent('vehicle-gps:server:removeGPSOnJobChange')
    end
end) 