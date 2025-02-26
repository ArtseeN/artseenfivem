local QBCore = exports['qb-core']:GetCoreObject()

RegisterNetEvent('QBCore:Client:OnPlayerLoaded')
AddEventHandler('QBCore:Client:OnPlayerLoaded', function()
    TriggerServerEvent('attribute:loadAttributes')
end)

lib.registerContext({
    id = 'attribute_menu',
    title = 'Karakter Özelliği Ayarla',
    options = {
        {
            title = 'Özellik Gir',
            description = 'Karakterinizin özelliklerini yazın',
            onSelect = function()
                local input = lib.inputDialog('Karakter Özelliği', {
                    {
                        type = 'input',
                        label = 'Özelliklerinizi detaylı yazın',
                        placeholder = 'Örn: 45\'lerinde bir adam, Hispanik aksanı var, alnı kırışıklık dolu'
                    }
                })

                if input then
                    
                    TriggerServerEvent('attribute:updateAttribute', input[1])
                end
            end
        }
    }
})

RegisterCommand('attributeayarla', function()
    lib.showContext('attribute_menu')
end)

RegisterCommand('attributebak', function(source, args)
    if #args < 1 then
        TriggerEvent('chat:addMessage', {
            color = {255, 0, 0},
            args = {'Hata', 'Bir oyuncu ID\'si girmelisiniz.'}
        })
        return
    end

    TriggerServerEvent('attribute:requestAttributes', tonumber(args[1]))
end)

RegisterNetEvent('attribute:receiveAttributes')
AddEventHandler('attribute:receiveAttributes', function(attributes)
    if attributes then
        TriggerEvent('chat:addMessage', {
            color = {255, 255, 0},
            args = {'Karakter Özellikleri', attributes}
        })
    else
        TriggerEvent('chat:addMessage', {
            color = {255, 0, 0},
            args = {'Hata', 'Bu oyuncunun kayıtlı özellikleri bulunamadı.'}
        })
    end
end) 