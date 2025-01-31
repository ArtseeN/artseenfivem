local QBCore = exports['qb-core']:GetCoreObject()
local activeVehicleGPS = {}
local blips = {}


RegisterCommand('aracgps', function(source, args)
    if not args[1] then
        QBCore.Functions.Notify('Bir araç kodu belirtmelisiniz! Örnek: /aracgps 12A21', 'error')
        return
    end

    local ped = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(ped, false)
    
    if vehicle == 0 then
        QBCore.Functions.Notify('Bir araçta olmalısınız!', 'error')
        return
    end

    local playerData = QBCore.Functions.GetPlayerData()
    if not (playerData.job.name == 'police' or playerData.job.name == 'sheriff') then
        QBCore.Functions.Notify('Bu komutu kullanma yetkiniz yok!', 'error')
        return
    end

    local plate = GetVehicleNumberPlateText(vehicle)
    local model = GetDisplayNameFromVehicleModel(GetEntityModel(vehicle))
    local code = args[1]

    TriggerServerEvent('vehicle-gps:server:activateGPS', code, plate, model, playerData.job.name)
end)


RegisterCommand('aracgpskontrol', function()
    local playerData = QBCore.Functions.GetPlayerData()
    if not (playerData.job.name == 'police' or playerData.job.name == 'sheriff') then
        QBCore.Functions.Notify('Bu komutu kullanma yetkiniz yok!', 'error')
        return
    end

    TriggerServerEvent('vehicle-gps:server:requestGPSList')
end)


RegisterNetEvent('vehicle-gps:client:updateGPSList')
AddEventHandler('vehicle-gps:client:updateGPSList', function(gpsData)
    activeVehicleGPS = gpsData
    RefreshBlips()
end)


RegisterCommand('aracgpskaldır', function(source, args)
    if not args[1] then
        QBCore.Functions.Notify('Bir araç kodu belirtmelisiniz! Örnek: /aracgpskaldır 12A21', 'error')
        return
    end

    local playerData = QBCore.Functions.GetPlayerData()
    if not (playerData.job.name == 'police' or playerData.job.name == 'sheriff') then
        QBCore.Functions.Notify('Bu komutu kullanma yetkiniz yok!', 'error')
        return
    end

    local code = args[1]
    TriggerServerEvent('vehicle-gps:server:removeGPS', code)
end)


function RefreshBlips()
    -- Yetki kontrolü
    local playerData = QBCore.Functions.GetPlayerData()
    if not (playerData.job.name == 'police' or playerData.job.name == 'sheriff') then
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
            SetBlipColour(blip, data.job == 'police' and 38 or 5) -- Polis için mavi, Şerif için sarı
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
                data.args.data.job == 'police' and 'Polis' or 'Şerif'
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