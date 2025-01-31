local QBCore = exports['qb-core']:GetCoreObject()
local isInJob = false
local deliveryVehicle = nil
local currentBlip = nil
local deliveryBlip = nil
local currentDelivery = nil
local deliveryPeds = {} -- Teslimat NPC'leri için tablo
local uiOpen = false -- UI durumunu takip etmek için yeni değişken

-- Timer UI'ı için yeni değişkenler
local showTimer = false
local timerScaleform = nil

-- UI Kontrolleri
function OpenDeliveryUI()
    SetNuiFocus(true, true)
    SendNUIMessage({
        type = "showUI"
    })
    uiOpen = true
end

function CloseDeliveryUI()
    SetNuiFocus(false, false)
    SendNUIMessage({
        type = "hideUI"
    })
    uiOpen = false
end

-- Araç temizleme fonksiyonu
function CleanupJob()
    if deliveryVehicle then
        DeleteVehicle(deliveryVehicle)
        deliveryVehicle = nil
    end
    RemoveDeliveryBlip()
    isInJob = false
    currentDelivery = nil
    CloseDeliveryUI()
end

-- Teslimat NPC'si yürüme fonksiyonu
function WalkAwayDeliveryPed(ped)
    local randomOffset = vector3(
        math.random(-20, 20),
        math.random(-20, 20),
        0
    )
    local pedPos = GetEntityCoords(ped)
    local targetPos = pedPos + randomOffset
    
    TaskGoStraightToCoord(ped, targetPos.x, targetPos.y, targetPos.z, 1.0, -1, 0.0, 0.0)
    Wait(5000) -- 5 saniye sonra NPC'yi sil
    DeletePed(ped)
end

-- Teslimat Noktası Kontrolü
CreateThread(function()
    while true do
        Wait(0)
        if isInJob and currentDelivery and not currentDelivery.completed then
            local pos = GetEntityCoords(PlayerPedId())
            local dist = #(pos - vector3(currentDelivery.location.x, currentDelivery.location.y, currentDelivery.location.z))
            
            if dist < 2.0 then
                QBCore.Functions.DrawText3D(currentDelivery.location.x, currentDelivery.location.y, currentDelivery.location.z + 0.3, '~g~E~w~ - Siparişi Teslim Et')
                if IsControlJustReleased(0, 38) then -- E tuşu
                    currentDelivery.completed = true
                    
                    -- Teslimat animasyonu
                    TaskStartScenarioInPlace(PlayerPedId(), "PROP_HUMAN_BUM_BIN", 0, true)
                    Wait(3000)
                    ClearPedTasks(PlayerPedId())
                    
                    -- Teslimat bildirimi
                    QBCore.Functions.Notify('Siparişi teslim ettin!', 'success')
                    
                    -- Blip'i kaldır
                    RemoveDeliveryBlip()
                    
                    -- NPC'yi yürüt ve sil
                    local deliveryPed = GetClosestPed(currentDelivery.location.x, currentDelivery.location.y, currentDelivery.location.z, 2.0, 1, 0, 0, 0, -1)
                    if deliveryPed then
                        WalkAwayDeliveryPed(deliveryPed)
                    end
                    
                    SendNUIMessage({
                        type = "deliveredToNPC"
                    })
                end
            end
        end
    end
end)

-- Event Handlers
RegisterNetEvent('qb-delivery:client:openMenu', function()
    if isInJob then
        OpenDeliveryUI()
    else
        QBCore.Functions.Notify('Mesleğe başlamak için E tuşuna bas', 'primary', 3500)
        CreateThread(function()
            while not isInJob do
                Wait(0)
                local pos = GetEntityCoords(PlayerPedId())
                local dist = #(pos - vector3(Config.StartLocation.x, Config.StartLocation.y, Config.StartLocation.z))
                
                if dist < 2.0 then
                    QBCore.Functions.DrawText3D(Config.StartLocation.x, Config.StartLocation.y, Config.StartLocation.z + 0.3, '~g~E~w~ - Mesleğe Başla')
                    if IsControlJustReleased(0, 38) then -- E tuşu
                        isInJob = true
                        SpawnDeliveryVehicle()
                        Wait(500) -- Kısa bir bekleme ekleyelim
                        OpenDeliveryUI() -- UI'ı burada açıyoruz
                        break
                    end
                else
                    break
                end
            end
        end)
    end
end)

-- ESC tuşu kontrolü
CreateThread(function()
    while true do
        Wait(0)
        if uiOpen and IsControlJustReleased(0, 177) then -- ESC ve UI açıksa
            CloseDeliveryUI()
        end
    end
end)

RegisterNUICallback('startJob', function(data, cb)
    -- Eğer araç yoksa yeni araç spawn et
    if not DoesEntityExist(deliveryVehicle) then
        SpawnDeliveryVehicle()
    end
    
    -- Diğer değişkenleri ayarla
    isInJob = true
    
    cb({})
end)

RegisterNUICallback('endJob', function(data, cb)
    -- Eğer aktif teslimat varsa, önce onu iptal et
    if currentDelivery then
        -- Timer'ı temizle
        showTimer = false
        if timerScaleform then
            SetScaleformMovieAsNoLongerNeeded(timerScaleform)
            timerScaleform = nil
        end
        
        -- Blip'i temizle
        RemoveDeliveryBlip()
        currentDelivery = nil
    end
    
    -- Aracı silme - artık aracı silmiyoruz
    -- if deliveryVehicle then
    --     DeleteVehicle(deliveryVehicle)
    --     deliveryVehicle = nil
    -- end
    
    -- Diğer değişkenleri sıfırla
    isInJob = false
    
    -- Kazancı server'a gönder
    if data.totalEarnings and data.totalEarnings > 0 then
        TriggerServerEvent('qb-delivery:server:finishJob', data.totalEarnings)
    end
    
    cb({})
end)

RegisterNUICallback('acceptOrder', function(data, cb)
    if data.coordinates then
        currentDelivery = {
            location = vector4(
                data.coordinates.x,
                data.coordinates.y,
                data.coordinates.z,
                data.coordinates.w
            ),
            completed = false
        }
        
        -- Teslimat NPC'si oluştur
        local customerModel = `a_m_y_business_03`
        RequestModel(customerModel)
        while not HasModelLoaded(customerModel) do Wait(0) end
        
        local customerPed = CreatePed(4, customerModel, 
            currentDelivery.location.x, 
            currentDelivery.location.y, 
            currentDelivery.location.z - 1, 
            currentDelivery.location.w, 
            false, true)
        
        SetEntityHeading(customerPed, currentDelivery.location.w)
        FreezeEntityPosition(customerPed, true)
        SetEntityInvincible(customerPed, true)
        SetBlockingOfNonTemporaryEvents(customerPed, true)
        table.insert(deliveryPeds, customerPed)
        
        CreateDeliveryBlip(currentDelivery.location)
    end
    cb({})
end)

RegisterNUICallback('completeDelivery', function(data, cb)
    if currentDelivery and currentDelivery.completed then
        RemoveDeliveryBlip()
        currentDelivery = nil
        TriggerServerEvent('qb-delivery:server:reward', data.price)
    end
    cb({})
end)

RegisterNUICallback('closeUI', function(data, cb)
    CloseDeliveryUI()
    cb({})
end)

RegisterNUICallback('getLocations', function(data, cb)
    cb(Config.Locations)
end)

RegisterNUICallback('failDelivery', function(data, cb)
    -- Aracı sil
    if deliveryVehicle then
        DeleteVehicle(deliveryVehicle)
        deliveryVehicle = nil
    end
    
    -- Blip'i temizle
    RemoveDeliveryBlip()
    
    -- Para cezası uygula (opsiyonel)
    TriggerServerEvent('qb-delivery:server:applyPenalty', Config.FailurePenalty)
    
    -- Oyuncuya bildir
    QBCore.Functions.Notify('Siparişi zamanında teslim edemedin!', 'error')
    
    cb({})
end)

-- Araç Spawn
function SpawnDeliveryVehicle()
    -- Eğer araç varsa ve hala geçerliyse, yeni araç spawn etme
    if deliveryVehicle and DoesEntityExist(deliveryVehicle) then 
        return 
    end
    
    QBCore.Functions.SpawnVehicle(Config.MotorcycleModel, function(vehicle)
        deliveryVehicle = vehicle
        SetVehicleNumberPlateText(vehicle, "DLVRY"..tostring(math.random(1000, 9999)))
        exports['LegacyFuel']:SetFuel(vehicle, 100.0)
        TriggerEvent('vehiclekeys:client:SetOwner', QBCore.Functions.GetPlate(vehicle))
        SetVehicleEngineOn(vehicle, true, true)
        
        -- Aracın spawn noktasını ayarla
        SetEntityCoords(vehicle, Config.VehicleSpawnPoint.x, Config.VehicleSpawnPoint.y, Config.VehicleSpawnPoint.z)
        SetEntityHeading(vehicle, Config.VehicleSpawnPoint.w)
        
        -- Oyuncuyu aracın yanına ışınla (opsiyonel)
        -- SetEntityCoords(PlayerPedId(), Config.VehicleSpawnPoint.x + 2.0, Config.VehicleSpawnPoint.y, Config.VehicleSpawnPoint.z)
    end, Config.VehicleSpawnPoint, true)
end


function CreateDeliveryBlip(location)
    RemoveDeliveryBlip()
    deliveryBlip = AddBlipForCoord(location.x, location.y, location.z)
    SetBlipSprite(deliveryBlip, 1)
    SetBlipDisplay(deliveryBlip, 4)
    SetBlipScale(deliveryBlip, 0.8)
    SetBlipAsShortRange(deliveryBlip, true)
    SetBlipColour(deliveryBlip, 2)
    SetBlipRoute(deliveryBlip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentSubstringPlayerName("Teslimat Noktası")
    EndTextCommandSetBlipName(deliveryBlip)
end

function RemoveDeliveryBlip()
    if deliveryBlip then
        RemoveBlip(deliveryBlip)
        deliveryBlip = nil
    end
end

AddEventHandler('onResourceStart', function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then return end
    CleanupJob()
end)

AddEventHandler('onResourceStop', function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then return end
    if deliveryVehicle and DoesEntityExist(deliveryVehicle) then
        DeleteVehicle(deliveryVehicle)
    end
    CleanupJob()
    for _, ped in pairs(deliveryPeds) do
        DeletePed(ped)
    end
end)


AddEventHandler('onClientResourceStop', function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then return end
    if deliveryVehicle and DoesEntityExist(deliveryVehicle) then
        DeleteVehicle(deliveryVehicle)
    end
    CleanupJob()
end)


AddEventHandler('baseevents:onPlayerDied', function(killedBy, pos)
    if deliveryVehicle and DoesEntityExist(deliveryVehicle) then
        DeleteVehicle(deliveryVehicle)
        deliveryVehicle = nil
    end
end)


CreateThread(function()
    local model = `a_m_y_business_02`
    RequestModel(model)
    while not HasModelLoaded(model) do Wait(0) end
    
    local ped = CreatePed(4, model, Config.StartLocation.x, Config.StartLocation.y, Config.StartLocation.z - 1, Config.StartLocation.w, false, true)
    SetEntityHeading(ped, Config.StartLocation.w)
    FreezeEntityPosition(ped, true)
    SetEntityInvincible(ped, true)
    SetBlockingOfNonTemporaryEvents(ped, true)
    
    exports['qb-target']:AddTargetEntity(ped, {
        options = {
            {
                type = "client",
                event = "qb-delivery:client:openMenu",
                icon = "fas fa-motorcycle",
                label = "Kurye İşi",
            }
        },
        distance = 2.0
    })
    local blip = AddBlipForCoord(Config.StartLocation.x, Config.StartLocation.y, Config.StartLocation.z)
    SetBlipSprite(blip, 280)
    SetBlipDisplay(blip, 4)
    SetBlipScale(blip, 0.8)
    SetBlipAsShortRange(blip, true)
    SetBlipColour(blip, 2)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentSubstringPlayerName("Kurye İşi")
    EndTextCommandSetBlipName(blip)
end)


function CreateTimerUI()
    if timerScaleform then
        SetScaleformMovieAsNoLongerNeeded(timerScaleform)
    end
    
    timerScaleform = RequestScaleformMovie("MP_BIG_MESSAGE_FREEMODE")
    while not HasScaleformMovieLoaded(timerScaleform) do
        Wait(0)
    end
    
    BeginScaleformMovieMethod(timerScaleform, "SHOW_SHARD_WASTED_MP_MESSAGE")
    PushScaleformMovieMethodParameterString("~y~TESLİMAT SÜRESİ") -- Sarı renk
    PushScaleformMovieMethodParameterString("~w~BAŞLADI") -- Beyaz renk
    EndScaleformMovieMethod()
end


RegisterNUICallback('updateTimer', function(data, cb)
    if not showTimer then return end
    
    BeginScaleformMovieMethod(timerScaleform, "SHOW_SHARD_WASTED_MP_MESSAGE")
    
    if tonumber(string.match(data.time, "%d+")) <= 30 then
        PushScaleformMovieMethodParameterString("~r~KALAN SÜRE") -- Kırmızı başlık
        PushScaleformMovieMethodParameterString("~r~" .. data.time) -- Kırmızı süre
    else
        PushScaleformMovieMethodParameterString("~g~KALAN SÜRE") -- Yeşil başlık
        PushScaleformMovieMethodParameterString("~w~" .. data.time) -- Beyaz süre
    end
    
    EndScaleformMovieMethod()
    
    cb({})
end)


RegisterNUICallback('startTimer', function(data, cb)
    showTimer = true
    CreateTimerUI()
    cb({})
end)


RegisterNUICallback('stopTimer', function(data, cb)
    showTimer = false
    if timerScaleform then
        SetScaleformMovieAsNoLongerNeeded(timerScaleform)
        timerScaleform = nil
    end
    cb({})
end)


CreateThread(function()
    while true do
        Wait(0)
        if showTimer and timerScaleform then
            -- Parametreler: x, y, width, height
            -- x: 0.85 -> 0.90 (daha sağa)
            -- y: 0.15 -> 0.10 (daha yukarı)
            -- width: 0.2 -> 0.3 (daha geniş)
            -- height: 0.2 -> 0.3 (daha yüksek)
            DrawScaleformMovie(timerScaleform, 0.90, 0.10, 0.3, 0.3, 255, 255, 255, 255, 0)
        end
    end
end) 