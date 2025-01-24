local activeCallsigns = {}
local renderDistance = 25.0 -- yazının görünürlük mesafesi (metre)


RegisterNetEvent('custom-callsign:applyCallsign', function(vehicleNetId, callsign)
    local vehicle = NetworkGetEntityFromNetworkId(vehicleNetId)
    if DoesEntityExist(vehicle) then
        activeCallsigns[vehicleNetId] = callsign
    end
end)


RegisterNetEvent('custom-callsign:removeCallsign', function(vehicleNetId)
    activeCallsigns[vehicleNetId] = nil
end)


CreateThread(function()
    while true do
        Wait(0)
        for vehicleNetId, callsign in pairs(activeCallsigns) do
            local vehicle = NetworkGetEntityFromNetworkId(vehicleNetId)
            if DoesEntityExist(vehicle) then
                local playerPed = PlayerPedId()
                local playerCoords = GetEntityCoords(playerPed)
                local vehicleCoords = GetEntityCoords(vehicle)

                if #(playerCoords - vehicleCoords) <= renderDistance then
                    -- yazı konumu
                    local offset = GetOffsetFromEntityInWorldCoords(vehicle, -0.8, -2.4, 0.1)
                    DrawText3D(offset.x, offset.y, offset.z, callsign)
                end
            else
                activeCallsigns[vehicleNetId] = nil
            end
        end
    end
end)

function DrawText3D(x, y, z, text)
    SetDrawOrigin(x, y, z, 0)
    SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    AddTextComponentString(text)
    DrawText(0.0, 0.0)
    ClearDrawOrigin()
end
