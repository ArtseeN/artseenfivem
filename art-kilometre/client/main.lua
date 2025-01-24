local QBCore = exports['qb-core']:GetCoreObject()

Citizen.CreateThread(function()
    while QBCore == nil do
        Citizen.Wait(0)
    end
end)

RegisterCommand("km", function(source)
    local playerPed = PlayerPedId()
    if IsPedInAnyVehicle(playerPed, false) and GetPedInVehicleSeat(GetVehiclePedIsIn(playerPed, true), -1) == playerPed then
        local vehicle = GetVehiclePedIsIn(PlayerPedId())
        local plate = GetVehicleNumberPlateText(vehicle)
        QBCore.Functions.TriggerCallback('ExeLds:getKilometer', function(kilometre)
            local message
            if kilometre > Config.asama4km then        
                message = '^1LIVE.MP - Aracın toplam gittiği yol: ' .. kilometre .. 'km'
            elseif kilometre > Config.asama3km then        
                message = '^6LIVE.MP - Aracın toplam gittiği yol: ' .. kilometre .. 'km'
            elseif kilometre > Config.asama2km then        
                message = '^3LIVE.MP - Aracın toplam gittiği yol: ' .. kilometre .. 'km'
            elseif kilometre > Config.asama1km then        
                message = '^2LIVE.MP - Aracın toplam gittiği yol: ' .. kilometre .. 'km'
            elseif kilometre <= Config.asama1km then        
                message = '^7LIVE.MP - Aracın toplam gittiği yol: ' .. kilometre .. 'km'
            end
            TriggerEvent('chat:addMessage', {
                color = {255, 255, 255},
                multiline = true,
                args = {message}
            })
        end, plate)
    else
        TriggerEvent('chat:addMessage', {
            color = {255, 0, 0},
            multiline = true,
            args = {'^1LIVE.MP - Şoför koltuğunda oturduğun bir araç bulunamadı'}
        })
    end
end, false)

local ownedVehicles = {}
local lastCoords
local currentKilometer

Citizen.CreateThread(function()
    while true do
        local playerPed = PlayerPedId()
        local vehicle = GetVehiclePedIsIn(playerPed, true)
        if IsPedInAnyVehicle(playerPed, false) and GetPedInVehicleSeat(vehicle, -1) == playerPed then
            if currentKilometer == nil then
                local plate = GetVehicleNumberPlateText(vehicle)
                Citizen.Wait(500)
                QBCore.Functions.TriggerCallback('ExeLds:getKilometer', function(kilometre)
                    currentKilometer = kilometre
                end, plate)
            else
                DrawTxt("Kilometre : ", 2, {255, 255, 255}, 0.4, 0.170, 0.810)
                if currentKilometer > Config.asama4km then
                    DrawTxt(currentKilometer.."km", 2, {204, 0, 0}, 0.4, 0.250, 0.810)
                elseif currentKilometer > Config.asama3km then
                    DrawTxt(currentKilometer.."km", 2, {255, 102, 102}, 0.4, 0.250, 0.810)
                elseif currentKilometer > Config.asama2km then
                    DrawTxt(currentKilometer.."km", 2, {255, 153, 153}, 0.4, 0.250, 0.810)
                elseif currentKilometer > Config.asama1km then
                    DrawTxt(currentKilometer.."km", 2, {255, 204, 204}, 0.4, 0.250, 0.810)
                elseif currentKilometer <= Config.asama1km then
                    DrawTxt(currentKilometer.."km", 2, {255, 255, 255}, 0.4, 0.250, 0.810)
                end
            end
        end
        Citizen.Wait(10)
    end
end)

function DrawTxt(content, font, colour, scale, x, y)
    SetTextFont(font)
    SetTextScale(scale, scale)
    SetTextColour(colour[1], colour[2], colour[3], 255)
    SetTextEntry("STRING")
    SetTextDropShadow(0, 0, 0, 0, 255)
    SetTextDropShadow()
    SetTextEdge(4, 0, 0, 0, 255)
    SetTextOutline()
    AddTextComponentString(content)
    DrawText(x, y)
end

Citizen.CreateThread(function()
    while true do
        local playerPed = PlayerPedId()
        if IsPedInAnyVehicle(playerPed, false) and GetPedInVehicleSeat(GetVehiclePedIsIn(playerPed, true), -1) == playerPed then
            local vehicle = GetVehiclePedIsIn(PlayerPedId())
            local plate = GetVehicleNumberPlateText(vehicle)
            if ownedVehicles[plate] == nil then
                Citizen.Wait(500)
                QBCore.Functions.TriggerCallback('ExeLds:getOwnedCarInfo', function(result)
                    if result then
                        ownedVehicles[plate] = 1
                    else
                        ownedVehicles[plate] = 0
                    end
                end, plate)
            end

            if ownedVehicles[plate] and ownedVehicles[plate] > 0 then
                local currentCoords = GetEntityCoords(playerPed)
                if lastCoords == nil then
                    lastCoords = currentCoords
                end
                local distance = GetDistanceBetweenCoords(currentCoords, lastCoords, true)
                lastCoords = currentCoords
                ownedVehicles[plate] = ownedVehicles[plate] + distance
                if ownedVehicles[plate] > 1000 then
                    if currentKilometer == nil then
                        Citizen.Wait(500)
                        QBCore.Functions.TriggerCallback('ExeLds:getKilometer', function(kilometre)
                            currentKilometer = kilometre + 1
                        end, plate)
                    else
                        currentKilometer = currentKilometer + 1
                    end
                    TriggerServerEvent('ExeLds:updateCar', plate)
                    ownedVehicles[plate] = 1
                end
            end
        else
            lastCoords = nil
            currentKilometer = nil
            ownedVehicles = {}
        end
        Citizen.Wait(1000)
    end
end)

Citizen.CreateThread(function()
    while true do
        local playerPed = PlayerPedId()
        if IsPedInAnyVehicle(playerPed, false) and GetPedInVehicleSeat(GetVehiclePedIsIn(playerPed, true), -1) == playerPed then
            local vehicle = GetVehiclePedIsIn(PlayerPedId())
            if currentKilometer == nil then
                local plate = GetVehicleNumberPlateText(vehicle)
                Citizen.Wait(500)
                QBCore.Functions.TriggerCallback('ExeLds:getKilometer', function(kilometre)
                    currentKilometer = kilometre
                end, plate)
            else
            end
        end
        Citizen.Wait(20000)
    end
end)
