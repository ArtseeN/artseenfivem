local QBCore = exports['qb-core']:GetCoreObject()
local callsigns = {} -- aktif callsign'lar için tablo


RegisterCommand('callsign', function(source, args)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player or Player.PlayerData.job.name ~= "police" then
        TriggerClientEvent('chat:addMessage', source, {
            template = '<div><span style="color: red;">LIVE:MP - </span> <span style="color: white;">{0}</span></div>',
            args = {"Bu komutu yalnızca polisler kullanabilir"}
        })
        return
    end

    local vehicle = GetVehiclePedIsIn(GetPlayerPed(source), false)
    if not vehicle or vehicle == 0 then
        TriggerClientEvent('chat:addMessage', source, {
            template = '<div><span style="color: red;">LIVE:MP - </span> <span style="color: white;">{0}</span></div>',
            args = {"Bir araca binmelisiniz"}
        })
        return
    end

    local callsign = table.concat(args, " ")
    if callsign == "" then
        TriggerClientEvent('chat:addMessage', source, {
            template = '<div><span style="color: red;">LIVE:MP - </span> <span style="color: white;">{0}</span></div>',
            args = {"Bir çağrı kodu giriniz Örnek: /callsign 12A24"}
        })
        return
    end

    local vehicleNetId = NetworkGetNetworkIdFromEntity(vehicle)
    callsigns[vehicleNetId] = callsign

    TriggerClientEvent('custom-callsign:applyCallsign', -1, vehicleNetId, callsign)
    TriggerClientEvent('chat:addMessage', source, {
        template = '<div><span style="color: red;">LIVE:MP - </span> <span style="color: white;">{0}</span></div>',
        args = {"Çağrı kodu başarıyla uygulandı: " .. callsign}
    })
end, false)


AddEventHandler('entityRemoved', function(entity)
    if callsigns[entity] then
        callsigns[entity] = nil
        TriggerClientEvent('custom-callsign:removeCallsign', -1, entity)
    end
end)
