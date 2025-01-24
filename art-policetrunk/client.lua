local QBCore = exports['qb-core']:GetCoreObject()

local isTrunkOpen = false
local weaponsTaken = {} -- Envanterdeki silahlar

local policeVehicles = Config.PoliceVehicles

RegisterCommand('policetrunk', function()
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)

    local job = QBCore.Functions.GetPlayerData().job.name
    if job ~= "police" then
        TriggerEvent('chat:addMessage', {
            template = '<div><span style="color: red;">LIVE:MP - </span> <span style="color: white;">Polis izniniz yok!</span></div>',
            args = {}
        })
        return
    end

    local vehicle = GetClosestVehicle(playerCoords, 5.0, 0, 71) -- Yakındaki araç

    if DoesEntityExist(vehicle) then
        local vehicleModel = GetEntityModel(vehicle)
        local isPoliceVehicle = false
        for _, model in ipairs(policeVehicles) do
            if vehicleModel == GetHashKey(model) then
                isPoliceVehicle = true
                break
            end
        end

       
        if isPoliceVehicle then
            SetVehicleDoorOpen(vehicle, 5, false, false) 
            SendNUIMessage({ action = "openUI" })
            SetNuiFocus(true, true) 
            isTrunkOpen = true

           
            TriggerEvent('chat:addMessage', {
                template = '<div><span style="color: green;">LIVE:MP - </span> <span style="color: white;">Bagaj başarıyla açıldı</span></div>',
                args = {}
            })
        else
           
            TriggerEvent('chat:addMessage', {
                template = '<div><span style="color: red;">LIVE:MP - </span> <span style="color: white;">Bu araç bir polis aracı değil</span></div>',
                args = {}
            })
        end
    else
        
        TriggerEvent('chat:addMessage', {
            template = '<div><span style="color: red;">LIVE:MP - </span> <span style="color: white;">Yakınlarda araç yok</span></div>',
            args = {}
        })
    end
end)

CreateThread(function()
    while true do
        Wait(0)
        if isTrunkOpen and IsControlJustReleased(0, 200) then 
            closeTrunkUI()
        end
    end
end)

RegisterNUICallback('closeUI', function()
    closeTrunkUI()
end)


function closeTrunkUI()
    local playerPed = PlayerPedId()
    local vehicle = GetClosestVehicle(GetEntityCoords(playerPed), 5.0, 0, 71)

    if DoesEntityExist(vehicle) then
        SetVehicleDoorShut(vehicle, 5, false) 
    end

    SendNUIMessage({ action = "closeUI" })
    SetNuiFocus(false, false)
    isTrunkOpen = false

   
    TriggerEvent('chat:addMessage', {
        template = '<div><span style="color: red;">LIVE:MP - </span> <span style="color: white;">Bagaj kapatıldı!</span></div>',
        args = {}
    })
end


RegisterNUICallback('takeWeapon', function(data)
    local weapon = data.weapon

    if weaponsTaken[weapon] then
        TriggerEvent('chat:addMessage', {
            template = '<div><span style="color: red;">LIVE:MP - </span> <span style="color: white;">Bu silah zaten alındı, tekrar alamazsınız!</span></div>',
            args = {}
        })
        return
    end

    TriggerServerEvent('qb-weapons:giveWeapon', weapon)
    weaponsTaken[weapon] = true 

    TriggerEvent('chat:addMessage', {
        template = '<div><span style="color: green;">LIVE:MP - </span> <span style="color: white;">Silah başarıyla alındı!</span></div>',
        args = {}
    })
end)


RegisterNUICallback('dropWeapon', function(data)
    local weapon = data.weapon

   
    TriggerServerEvent('qb-weapons:removeWeapon', weapon)
    weaponsTaken[weapon] = false 

 
    TriggerEvent('chat:addMessage', {
        template = '<div><span style="color: green;">LIVE:MP - </span> <span style="color: white;">Silah başarıyla bırakıldı!</span></div>',
        args = {}
    })
end)
