local QBCore = exports['qb-core']:GetCoreObject()
if not lib then
    lib = exports.ox_lib
end
local activeStatuses = {}

-- Kemik pozisyonları ve isimleri
local bonePositions = {
    ['Sağ Omuz'] = 40269,
    ['Sol Omuz'] = 45509,
    ['Sağ Dirsek'] = 28252,
    ['Sol Dirsek'] = 22711,
    ['Sağ Kol'] = 57005,
    ['Sol Kol'] = 18905,
    ['Sağ Bacak'] = 16335,
    ['Sol Bacak'] = 46078,
    ['Sağ Diz'] = 16335,
    ['Sol Diz'] = 46078,
    ['Kafa'] = 31086,
    ['Gövde'] = 24818,
    ['Bel Hizası'] = 11816
}

local boneNames = {}
for name, id in pairs(bonePositions) do
    boneNames[id] = name
end

-- Status eklemek için fonksiyon
local function AddStatus(data)
    if not data.text or not data.bone or not data.duration then return end
    
    local statusId = #activeStatuses + 1
    activeStatuses[statusId] = {
        text = data.text,
        bone = data.bone,
        duration = data.duration,
        startTime = GetGameTimer()
    }
    
    -- Tüm oyunculara status'u senkronize et
    TriggerServerEvent('status:sync', activeStatuses)
    return statusId
end

local function RemoveStatus(id)
    activeStatuses[id] = nil
    TriggerServerEvent('status:sync', activeStatuses)
end

-- Ana menüyü göster
local function ShowMainMenu()
    local menuOptions = {
        {
            title = "Yeni Yazı Ekle",
            description = "Yeni bir yazı eklemek için tıkla",
            icon = "fas fa-plus",
            onSelect = function()
                local input = lib.inputDialog('Yapışkan Emote', {
                    {
                        type = 'input',
                        label = 'Mesaj',
                        placeholder = 'Örn: Kolu sargılı',
                        required = true
                    },
                    {
                        type = 'number',
                        label = 'Süre (Dakika)',
                        default = 20,
                        min = 1,
                        max = 255,
                        required = true
                    },
                    {
                        type = 'select',
                        label = 'Emote Pozisyonu',
                        options = {
                            { value = 'sag_omuz', label = 'Sağ Omuz' },
                            { value = 'sol_omuz', label = 'Sol Omuz' },
                            { value = 'sag_dirsek', label = 'Sağ Dirsek' },
                            { value = 'sol_dirsek', label = 'Sol Dirsek' },
                            { value = 'sag_kol', label = 'Sağ Kol' },
                            { value = 'sol_kol', label = 'Sol Kol' },
                            { value = 'sag_bacak', label = 'Sağ Bacak' },
                            { value = 'sol_bacak', label = 'Sol Bacak' },
                            { value = 'sag_diz', label = 'Sağ Diz' },
                            { value = 'sol_diz', label = 'Sol Diz' },
                            { value = 'kafa', label = 'Kafa' },
                            { value = 'govde', label = 'Gövde' },
                            { value = 'bel', label = 'Bel Hizası' }
                        },
                        required = true
                    }
                })

                if not input then return end

                local boneMap = {
                    sag_omuz = 40269,
                    sol_omuz = 45509,
                    sag_dirsek = 28252,
                    sol_dirsek = 22711,
                    sag_kol = 57005,
                    sol_kol = 18905,
                    sag_bacak = 16335,
                    sol_bacak = 46078,
                    sag_diz = 16335,
                    sol_diz = 46078,
                    kafa = 31086,
                    govde = 24818,
                    bel = 11816
                }

                local bone = boneMap[input[3]]
                AddStatus({
                    text = input[1],
                    bone = bone,
                    duration = input[2] * 60000
                })

                lib.notify({
                    title = 'Başarılı',
                    description = 'Emote eklendi',
                    type = 'success'
                })
            end
        }
    }

    for id, status in pairs(activeStatuses) do
        if GetGameTimer() - status.startTime < status.duration then
            table.insert(menuOptions, {
                title = status.text,
                description = boneNames[status.bone] .. " üzerindeki yazı",
                icon = "fas fa-times",
                onSelect = function()
                    RemoveStatus(id)
                    lib.notify({
                        title = 'Başarılı',
                        description = 'Yazı kaldırıldı',
                        type = 'success'
                    })
                end
            })
        end
    end

    lib.registerContext({
        id = 'status_menu',
        title = 'Yazı Menüsü',
        options = menuOptions
    })

    lib.showContext('status_menu')
end

-- /st komutu
RegisterCommand('st', function()
    ShowMainMenu()
end)


RegisterNetEvent('status:syncClient')
AddEventHandler('status:syncClient', function(newStatuses)
    activeStatuses = newStatuses
end)


CreateThread(function()
    while true do
        local wait = 0
        local player = PlayerPedId()
        local playerCoords = GetEntityCoords(player)
        
        for id, status in pairs(activeStatuses) do
            if GetGameTimer() - status.startTime < status.duration then
                local boneCoords = GetPedBoneCoords(player, status.bone, 0.0, 0.0, 0.0)
                
                -- Oyuncu ve yazı arasındaki mesafeyi hesapla
                local distance = #(playerCoords - boneCoords)
                
                -- Sadece 3 metre yakınındayken göster
                if distance <= 3.0 then
                    DrawText3D(boneCoords, status.text)
                end
            else
                activeStatuses[id] = nil
                TriggerServerEvent('status:sync', activeStatuses)
            end
        end
        
        Wait(wait)
    end
end)


function DrawText3D(coords, text)
    local camCoords = GetGameplayCamCoords()
    local dist = #(coords - camCoords)
    
    -- Mesafeye göre text boyutunu ayarla
    local scale = (1 / dist) * 2
    local fov = (1 / GetGameplayCamFov()) * 100
    scale = scale * fov
    
    -- Text ayarları
    SetTextScale(0.0 * scale, 0.55 * scale)
    SetTextFont(4)
    SetTextColour(255, 255, 255, 255)
    SetTextDropshadow(0, 0, 0, 0, 255)
    SetTextDropShadow()
    SetTextOutline()
    SetTextCentre(true)
    
    -- Text pozisyonu
    SetDrawOrigin(coords.x, coords.y, coords.z, 0)
    BeginTextCommandDisplayText('STRING')
    AddTextComponentSubstringPlayerName(text)
    EndTextCommandDisplayText(0.0, 0.0)
    ClearDrawOrigin()
end 
