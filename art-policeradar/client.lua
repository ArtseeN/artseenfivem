QBCore = exports['qb-core']:GetCoreObject()

local radarVisible = false
local radarX, radarY = 0.8, 0.05
local policeVehicles = Config.PoliceVehicles

-- Radar açma/kapatma komutu
RegisterCommand('policeradar', function()
    local playerPed = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(playerPed, false)
    local job = exports['qb-core']:GetCoreObject().Functions.GetPlayerData().job

    if job and job.name == "police" then
        local vehicleModel = GetEntityModel(vehicle)
        local isPoliceVehicle = false

        for _, model in ipairs(policeVehicles) do
            if vehicleModel == GetHashKey(model) then
                isPoliceVehicle = true
                break
            end
        end

        if isPoliceVehicle then 
            radarVisible = not radarVisible
            SetNuiFocus(false, false)
            SendNUIMessage({
                action = 'toggleRadar',
                visible = radarVisible,
                x = radarX,
                y = radarY
            })

            if radarVisible then
                -- Radar açıkken sürekli bilgileri güncelle
                Citizen.CreateThread(function()
                    while radarVisible do
                        Citizen.Wait(500)
                        UpdateRadarData(vehicle)
                    end
                end)
            end

            TriggerEvent('chat:addMessage', {
                color = {255, 255, 255},
                multiline = true,
                args = {"LIVE.MP", "Radar başarıyla açıldı!"}
            })
        else
            TriggerEvent('chat:addMessage', {
                color = {255, 0, 0},
                multiline = true,
                args = {"LIVE.MP", "Bu komut yalnızca polis araçlarında kullanılabilir."}
            })
        end
    else
        TriggerEvent('chat:addMessage', {
            color = {255, 0, 0},
            multiline = true,
            args = {"LIVE.MP", "Bu komut yalnızca polis mesleği olan kişiler için kullanılabilir."}
        })
    end
end, false)

-- Radar verilerini güncelleyen fonksiyon
function UpdateRadarData(vehicle)
    local speed = math.floor(GetEntitySpeed(vehicle) * 3.6) -- Hız km/h cinsinden
    local targetVehicle = GetVehicleInFront(vehicle)

    if targetVehicle ~= 0 then
        local plate = GetVehicleNumberPlateText(targetVehicle)
        local color = GetVehicleColor(targetVehicle)
        local model = GetDisplayNameFromVehicleModel(GetEntityModel(targetVehicle))

        GetVehicleOwner(targetVehicle, function(owner)
            SendNUIMessage({
                action = 'updateRadar',
                speed = math.floor(GetEntitySpeed(targetVehicle) * 3.6) .. " km/h",
                owner = owner, 
                color = color,
                model = model,
                plate = plate
            })
        end)
    else
        SendNUIMessage({
            action = 'updateRadar',
            speed = "0 km/h",
            owner = "Hedef Araç Yok",
            plate = "Bilinmiyor",
            color = "Bilinmiyor",
            model = "Bilinmiyor"
        })
    end
end

-- Araçtan indiğinde radar kapanma
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1000) -- Her saniyede bir kontrol
        if radarVisible then
            local playerPed = PlayerPedId()
            if GetVehiclePedIsIn(playerPed, false) == 0 then
                radarVisible = false
                SendNUIMessage({ action = 'toggleRadar', visible = false })

                
                TriggerEvent('chat:addMessage', {
                    color = {255, 255, 255},
                    multiline = true,
                    args = {"LIVE.MP", "Radar otomatik olarak kapatıldı (Araçtan inildi)."}
                })
            end
        end
    end
end)


function GetVehicleInFront(vehicle)
    local position = GetEntityCoords(vehicle)
    local forward = GetEntityForwardVector(vehicle)
    local rayEnd = position + forward * 50.0 -- Önündeki 50 metreyi tarar

    local rayHandle = StartShapeTestRay(position.x, position.y, position.z, rayEnd.x, rayEnd.y, rayEnd.z, 2, vehicle, 7)
    local _, hit, _, _, entityHit = GetShapeTestResult(rayHandle)

    if hit == 1 and IsEntityAVehicle(entityHit) then
        return entityHit
    else
        return 0
    end
end


function GetVehicleOwner(vehicle, callback)
    local plate = GetVehicleNumberPlateText(vehicle)
    QBCore.Functions.TriggerCallback('polisradar:getVehicleOwner', function(result)
        if result and result ~= "" then
            callback(result) 
        else
            callback("Sahip Bulunamadı") 
        end
    end, plate)
end

-- Araç rengini alma fonksiyonu
function GetVehicleColor(vehicle)
    local primaryColor, _ = GetVehicleColours(vehicle)
    local colors = {
        [0] = "Metalik Siyah",
        [1] = "Metalik Grafit Siyah",
        [2] = "Metalik Gri",
        [3] = "Metalik Gümüş",
        [4] = "Metalik Mavi Gri",
        [5] = "Metalik Lacivert",
        [6] = "Metalik Gri",
        [7] = "Metalik Açık Gri",
        [8] = "Metalik Benzin Yeşili",
        [9] = "Metalik Koyu Mor",
        [10] = "Metalik Bordo",
        [11] = "Metalik Kırmızı",
        [12] = "Metalik Parlak Kırmızı",
        [13] = "Metalik Turuncu",
        [14] = "Metalik Altın",
        [15] = "Metalik Şampanya",
        [16] = "Metalik Koyu Kahverengi",
        [17] = "Metalik Açık Kahverengi",
        [18] = "Metalik Koyu Bej",
        [19] = "Metalik Açık Bej",
        [20] = "Metalik Koyu Mavi",
        [21] = "Metalik Açık Mavi",
        [22] = "Metalik Mavi",
        [23] = "Metalik Gece Mavisi",
        [24] = "Metalik Mor",
        [25] = "Metalik Koyu Pembe",
        [26] = "Metalik Açık Pembe",
        [27] = "Metalik Yeşil",
        [28] = "Metalik Lime Yeşili",
        [29] = "Metalik Sarı",
        [30] = "Metalik Soluk Altın",
        [31] = "Metalik Turuncumsu Kırmızı",
        [32] = "Metalik Koyu Kırmızı", -- gerçek kırmızı
        [33] = "Metalik Koyu Kırmızı",
        [34] = "Metalik Gümüş Gri",
        [35] = "Metalik Parlak Gri",
        [36] = "Metalik İnci Beyazı",
        [37] = "Metalik Şeker Beyazı",
        [38] = "Mat Siyah",
        [39] = "Mat Gri",
        [40] = "Mat Gümüş",
        [41] = "Mat Mavi",
        [42] = "Mat Deniz Mavisi",
        [43] = "Mat Yeşil",
        [44] = "Mat Petrol Yeşili",
        [45] = "Mat Bordo",
        [46] = "Mat Kırmızı",
        [47] = "Mat Parlak Turuncu",
        [48] = "Mat Sarı",
        [49] = "Mat Beyaz",
        [50] = "Metalik Yeşil",
        [51] = "Metalik Bakır",
        [52] = "Metalik Bronz",
        [53] = "Metalik Altın Sarısı",
        [54] = "Metalik Krem",
        [55] = "Klasik Siyah",
        [56] = "Klasik Koyu Gri",
        [57] = "Klasik Açık Gri",
        [58] = "Klasik Beyaz",
        [59] = "Klasik Koyu Mavi",
        [60] = "Klasik Açık Mavi",
        [61] = "Klasik Koyu Yeşil",
        [62] = "Klasik Lime Yeşili",
        [63] = "Klasik Koyu Kırmızı",
        [64] = "Klasik Parlak Mavi",
        [65] = "Klasik Açık Pembe",
        [66] = "Klasik Parlak Turuncu",
        [67] = "Klasik Altın",
        [68] = "Klasik Bej",
        [69] = "Klasik Kahverengi",
        [70] = "Klasik Şeker Beyazı",
        [71] = "Metalik İnci Altın",
        [72] = "Metalik Soluk Yeşil",
        [73] = "Metalik Şampanya Altın",
        [74] = "Koyu Zeytin Yeşili",
        [75] = "Metalik Orta Gri",
        [76] = "Koyu Bordo",
        [77] = "Gece Siyahı",
        [78] = "Karbon Siyahı",
    }

    return colors[primaryColor] or "Bilinmiyor"
end
