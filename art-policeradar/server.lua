QBCore = exports['qb-core']:GetCoreObject()

QBCore.Functions.CreateCallback('polisradar:getVehicleOwner', function(source, cb, plate)
    local result = MySQL.single.await('SELECT citizenid FROM player_vehicles WHERE plate = ?', { plate })
    if result then
        local player = MySQL.single.await('SELECT charinfo FROM players WHERE citizenid = ?', { result.citizenid })
        if player then
            local charinfo = json.decode(player.charinfo)
            if charinfo and charinfo.firstname and charinfo.lastname then
                cb(charinfo.firstname .. " " .. charinfo.lastname) 
                return
            end
        end
    end
    cb("Sahip Bulunamadı") 
end)

