local QBCore = exports['qb-core']:GetCoreObject()
local PlayerData = {}
local display = false
local tabletObj = nil

-- İlk yükleme için PlayerData'yı al
CreateThread(function()
    while true do
        if LocalPlayer.state['isLoggedIn'] then
            PlayerData = QBCore.Functions.GetPlayerData()
            break
        end
        Wait(100)
    end
end)

-- Tablet prop'unu yükle ve animasyonu başlat
local function StartTabletAnimation()
    -- Önce animasyon dictionary'sini yükle
    RequestAnimDict(Config.Animation.dict)
    while not HasAnimDictLoaded(Config.Animation.dict) do
        Wait(100)
    end

    -- Prop modelini yükle
    RequestModel(Config.Animation.prop.model)
    while not HasModelLoaded(Config.Animation.prop.model) do
        Wait(100)
    end

    -- Tablet prop'unu oluştur ve karaktere bağla
    local ped = PlayerPedId()
    local bone = GetPedBoneIndex(ped, Config.Animation.prop.bone)
    
    tabletObj = CreateObject(Config.Animation.prop.model, 0.0, 0.0, 0.0, true, true, true)
    AttachEntityToEntity(tabletObj, ped, bone, 
        Config.Animation.prop.pos.x, Config.Animation.prop.pos.y, Config.Animation.prop.pos.z, 
        Config.Animation.prop.rot.x, Config.Animation.prop.rot.y, Config.Animation.prop.rot.z, 
        true, false, false, false, 2, true)

    -- Animasyonu başlat
    TaskPlayAnim(ped, Config.Animation.dict, Config.Animation.anim, 3.0, 3.0, -1, 49, 0, false, false, false)
end

-- Tablet animasyonunu durdur
local function StopTabletAnimation()
    -- Animasyonu durdur
    ClearPedTasks(PlayerPedId())
    
    -- Prop'u sil
    if tabletObj then
        DeleteObject(tabletObj)
        tabletObj = nil
    end
end

-- Command
RegisterCommand(Config.Command, function()
    if not PlayerData.job then PlayerData = QBCore.Functions.GetPlayerData() end
    
    -- İzin kontrolü
    local hasPermission = false
    for job, grade in pairs(Config.AllowedJobs) do
        if PlayerData.job.name == job and PlayerData.job.grade.level >= grade then
            hasPermission = true
            break
        end
    end
    
    if hasPermission then
        ToggleMDT()
    else
        QBCore.Functions.Notify('Bu komutu kullanma yetkiniz yok!', 'error')
    end
end)

-- MDT Toggle fonksiyonu
function ToggleMDT()
    display = not display
    if display then
        StartTabletAnimation()
        SetNuiFocus(true, true)
        SendNUIMessage({
            action = "show",
            status = true,
            officer = PlayerData.charinfo and PlayerData.charinfo.firstname .. " " .. PlayerData.charinfo.lastname or "Memur",
            badge = PlayerData.metadata and PlayerData.metadata.callsign or PlayerData.job.grade.name
        })
    else
        StopTabletAnimation()
        SetNuiFocus(false, false)
        SendNUIMessage({
            action = "show",
            status = false
        })
    end
end

-- NUI Callbacks
RegisterNUICallback('close', function(data, cb)
    ToggleMDT()
    cb('ok')
end)

RegisterNUICallback('searchPerson', function(data, cb)
    QBCore.Functions.TriggerCallback('police:mdt:searchPerson', function(result)
        if result then
            cb(result)
        else
            cb({})
        end
    end, data.searchTerm)
end)

RegisterNUICallback('searchVehicle', function(data, cb)
    QBCore.Functions.TriggerCallback('police:mdt:searchVehicle', function(result)
        if result then
            cb(result)
        else
            cb({})
        end
    end, data.searchTerm)
end)

RegisterNUICallback('addCriminal', function(data, cb)
    TriggerServerEvent('police:mdt:addCriminal', data)
    cb('ok')
end)

RegisterNUICallback('addWanted', function(data, cb)
    TriggerServerEvent('police:mdt:addWanted', data)
    cb('ok')
end)

RegisterNUICallback('removeWanted', function(data, cb)
    TriggerServerEvent('police:mdt:removeWanted', data.citizenid)
    cb('ok')
end)

-- Arananlar listesini getir
RegisterNUICallback('getWantedList', function(data, cb)
    QBCore.Functions.TriggerCallback('police:mdt:getWantedList', function(result)
        cb(result)
    end)
end)

-- Events
RegisterNetEvent('QBCore:Client:OnPlayerLoaded')
AddEventHandler('QBCore:Client:OnPlayerLoaded', function()
    PlayerData = QBCore.Functions.GetPlayerData()
end)

RegisterNetEvent('QBCore:Client:OnPlayerUnload')
AddEventHandler('QBCore:Client:OnPlayerUnload', function()
    PlayerData = {}
end)

RegisterNetEvent('QBCore:Client:OnJobUpdate')
AddEventHandler('QBCore:Client:OnJobUpdate', function(JobInfo)
    PlayerData.job = JobInfo
end)

-- ESC tuşu ile kapatma
CreateThread(function()
    while true do
        Wait(0)
        if IsControlJustReleased(0, 322) and display then -- 322 = ESC
            ToggleMDT()
        end
    end
end) 