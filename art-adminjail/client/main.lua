local currentJailTime = nil  
local jailTimerActive = false  

RegisterNetEvent("adminjail:sendToJail", function(jailTime, reason)
    local playerPed = PlayerPedId()
    SetEntityCoords(playerPed, -1427.1672, -257.5446, 16.7804, 359.3169, false, false, false, true) 
    FreezeEntityPosition(playerPed, true)
    SendNUIMessage({ type = "resetJailTimer" })
    SendNUIMessage({ type = "hideJailTimer" })
    currentJailTime = jailTime
    jailTimerActive = true
    TriggerEvent("adminjail:startJailTimer", jailTime, reason)
end)

RegisterNetEvent("adminjail:releaseFromJail", function()
    local playerPed = PlayerPedId()
    FreezeEntityPosition(playerPed, false)
    SendNUIMessage({ type = "hideJailTimer" }) 
    SendNUIMessage({ type = "resetJailTimer" })
    SetEntityCoords(playerPed, 102.9150, -1715.4094, 30.1124, 51.3667, false, false, false, true)

   
    currentJailTime = nil
    jailTimerActive = false
end)

RegisterNetEvent("adminjail:startJailTimer", function(jailTime, reason)
    SendNUIMessage({ type = "showJailTimer", time = jailTime, reason = reason })
    Citizen.CreateThread(function()
        while jailTime > 0 do
            Citizen.Wait(1000)
            jailTime = jailTime - 1
            SendNUIMessage({ type = "updateJailTimer", time = jailTime })
            if jailTime <= 0 then
                SendNUIMessage({ type = "hideJailTimer" })
                SendNUIMessage({ type = "resetJailTimer" })
                jailTimerActive = false
                currentJailTime = nil
            end
        end
    end)
end)
