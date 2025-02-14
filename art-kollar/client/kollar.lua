local QBCore = exports['qb-core']:GetCoreObject()

-- Komutu kaydet
RegisterCommand('kollar', function()
    local ped = PlayerPedId()
    local currentArms = GetPedDrawableVariation(ped, 3) -- Şu an giyilen kol ID'sini al
    
    local input = lib.inputDialog('Kol/Eldiven Menüsü', {
        {
            type = 'number',
            label = 'Kol/Eldiven ID (0-243)',
            description = 'Şu an giydiğiniz kol ID: ' .. currentArms .. '\nYeni ID girin (0-243)',
            default = currentArms,
            min = 0,
            max = 243,
            required = true
        }
    })

    if not input then return end -- Menü kapatıldıysa
    
    local kolID = input[1]
    if kolID then
        SetPedComponentVariation(ped, 3, kolID, 0, 0)
        lib.notify({
            title = 'Başarılı',
            description = 'Kol ID ' .. currentArms .. ' → ' .. kolID,
            type = 'success'
        })
    end
end) 