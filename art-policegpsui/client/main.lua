local QBCore = exports['qb-core']:GetCoreObject()
local activeVehicleGPS = {}
local blips = {}

-- Item kullanımını RegisterNetEvent ile kaydet
RegisterNetEvent('QBCore:Client:UpdateObject', function()
	QBCore = exports['qb-core']:GetCoreObject()
end)

RegisterNetEvent('police-gps:client:useGPS')
AddEventHandler('police-gps:client:useGPS', function()
    local playerData = QBCore.Functions.GetPlayerData()
    if not IsJobAllowed(playerData.job.name) then
        QBCore.Functions.Notify('Bu cihazı kullanma yetkiniz yok!', 'error')
        return
    end
    
    if not IsPedInAnyVehicle(PlayerPedId(), false) then
        QBCore.Functions.Notify('Bu cihazı sadece araç içinde kullanabilirsiniz!', 'error')
        return
    end
    
    SetNuiFocus(true, true)
    SendNUIMessage({
        type = 'openGPS'
    })
end)


RegisterNetEvent('vehicle-gps:client:updateGPSList')
AddEventHandler('vehicle-gps:client:updateGPSList', function(gpsData)
    activeVehicleGPS = gpsData
    RefreshBlips()
end)


function RefreshBlips()
    -- Yetki kontrolü
    local playerData = QBCore.Functions.GetPlayerData()
    if not IsJobAllowed(playerData.job.name) then
        for _, blip in pairs(blips) do
            RemoveBlip(blip)
        end
        blips = {}
        return
    end


    for _, blip in pairs(blips) do
        RemoveBlip(blip)
    end
    blips = {}

    for code, data in pairs(activeVehicleGPS) do
        local vehicle = GetVehicleByPlate(data.plate)
        if vehicle then
            local blip = AddBlipForEntity(vehicle)
            SetBlipSprite(blip, 1)
            SetBlipScale(blip, 0.8)
            SetBlipColour(blip, Config.JobColors[data.job] or 1) -- Config'den renk al veya varsayılan
            BeginTextCommandSetBlipName("STRING")
            AddTextComponentString(code)
            EndTextCommandSetBlipName(blip)
            blips[code] = blip
        end
    end
end

function GetVehicleByPlate(plate)
    local vehicles = GetGamePool('CVehicle')
    for _, vehicle in pairs(vehicles) do
        if GetVehicleNumberPlateText(vehicle) == plate then
            return vehicle
        end
    end
    return nil
end

RegisterNetEvent('vehicle-gps:client:showGPSDetails')
AddEventHandler('vehicle-gps:client:showGPSDetails', function(data)
    local menuItems = {
        {
            header = 'Araç GPS Detayları',
            isMenuHeader = true
        },
        {
            header = 'Araç Bilgileri',
            txt = string.format('Kod: %s\nModel: %s\nPlaka: %s\nMemur: %s\nDepartman: %s',
                data.args.code,
                data.args.data.model,
                data.args.data.plate,
                data.args.data.officerName,
                Config.JobLabels[data.args.data.job] or data.args.data.job
            )
        },
        {
            header = 'GPS\'i Kaldır',
            txt = 'Araç GPS sistemini devre dışı bırak',
            params = {
                isServer = true,
                event = 'vehicle-gps:server:removeGPS',
                args = data.args.code
            }
        },
        {
            header = '⬅ Geri',
            txt = 'Menüyü Kapat',
            params = {
                event = 'qb-menu:client:closeMenu'
            }
        }
    }
    
    exports['qb-menu']:openMenu(menuItems)
end)

CreateThread(function()
    while true do
        RefreshBlips()
        Wait(1000)
    end
end)

-- Yetki kontrolü için yardımcı fonksiyon
function IsJobAllowed(jobName)
    for _, job in ipairs(Config.AllowedJobs) do
        if jobName == job then
            return true
        end
    end
    return false
end

-- NUI Callback'leri
RegisterNUICallback('activateGPS', function(data, cb)
    local code = data.code
    local ped = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(ped, false)
    local playerData = QBCore.Functions.GetPlayerData()
    
    if vehicle == 0 then
        QBCore.Functions.Notify('Bir araçta olmalısınız!', 'error')
        SetNuiFocus(false, false) -- Fare odağını kaldır
        cb('ok')
        return
    end

    local plate = GetVehicleNumberPlateText(vehicle)
    local model = GetDisplayNameFromVehicleModel(GetEntityModel(vehicle))
    
    TriggerServerEvent('vehicle-gps:server:activateGPS', code, plate, model, playerData.job.name)
    SetNuiFocus(false, false) -- Fare odağını kaldır
    cb('ok')
end)

RegisterNUICallback('closeGPS', function(data, cb)
    SetNuiFocus(false, false) -- Fare odağını kaldır
    cb('ok')
end)

-- GPS listesi için NUI callback
RegisterNUICallback('requestGPSList', function(data, cb)
    TriggerServerEvent('vehicle-gps:server:requestGPSList')
    cb('ok')
end)

-- GPS kaldırma için NUI callback
RegisterNUICallback('removeGPS', function(data, cb)
    if not data.code then return end
    TriggerServerEvent('vehicle-gps:server:removeGPS', data.code)
    cb('ok')
end)

-- GPS listesi güncellemesi için client event
RegisterNetEvent('vehicle-gps:client:updateGPSList')
AddEventHandler('vehicle-gps:client:updateGPSList', function(gpsData)
    activeVehicleGPS = gpsData
    RefreshBlips()
    -- UI'yi güncelle
    SendNUIMessage({
        type = 'updateGPSList',
        list = gpsData
    })
end) 