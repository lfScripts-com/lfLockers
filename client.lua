local ESX = exports["es_extended"]:getSharedObject()
local PlayerData = {}
local isNearLocker = false
local uiOpen = false
local currentLocker = nil

Citizen.CreateThread(function()
    while ESX == nil do
        Citizen.Wait(10)
    end
    
    while ESX.GetPlayerData() == nil do
        Citizen.Wait(10)
    end
    
    PlayerData = ESX.GetPlayerData()
end)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
    PlayerData = xPlayer
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
    PlayerData.job = job
end)

AddEventHandler('onClientResourceStart', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    
    PlayerData = ESX.GetPlayerData()
end)

local function IsPlayerJobMatch(jobRequired)
    return PlayerData.job and PlayerData.job.name == jobRequired
end

local function GetPlayerGrade()
    return PlayerData.job and PlayerData.job.grade or 0
end

local function GetNearbyLocker()
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    
    for i, locker in ipairs(Config.Lockers) do
        local distance = #(playerCoords - locker.position)
        if distance < locker.drawDistance then
            return locker, distance
        end
    end
    
    return nil, 999
end

local function OpenLockerUI(locker)
    if uiOpen then return end
    uiOpen = true
    currentLocker = locker
    
    SetNuiFocus(true, true)
    
    SendNUIMessage({
        action = 'openUI',
        isAdmin = GetPlayerGrade() >= locker.adminGrade,
        playerName = GetPlayerName(PlayerId()),
        playerGrade = GetPlayerGrade(),
        lockerName = locker.name
    })
end

local function OpenPersonalLocker(locker)
    TriggerServerEvent('lfLockers:openPersonalLocker', locker.id)
    CloseLockerUI()
end

local function OpenAdminUI(locker)
    TriggerServerEvent('lfLockers:getJobOfficers', locker.id)
end

function CloseLockerUI()
    if not uiOpen then return end
    uiOpen = false
    currentLocker = nil
    
    SetNuiFocus(false, false)
    
    SendNUIMessage({
        action = 'closeUI'
    })
end

RegisterNUICallback('openPersonalLocker', function(data, cb)
    if currentLocker then
        OpenPersonalLocker(currentLocker)
    end
    cb('ok')
end)

RegisterNUICallback('getJobOfficers', function(data, cb)
    if currentLocker then
        OpenAdminUI(currentLocker)
    end
    cb('ok')
end)

RegisterNUICallback('openOfficerLocker', function(data, cb)
    if currentLocker then
        TriggerServerEvent('lfLockers:openOfficerLocker', currentLocker.id, data.officerId)
    end
    CloseLockerUI()
    cb('ok')
end)

RegisterNUICallback('closeUI', function(data, cb)
    CloseLockerUI()
    cb('ok')
end)

RegisterNUICallback('showNotification', function(data, cb)
    if data.message then
        ESX.ShowAdvancedNotification(_U('locker_title'), _U('personal_locker'), data.message, 'CHAR_SOCIAL_CLUB', 1)
    end
    cb('ok')
end)

RegisterNetEvent('lfLockers:receiveJobOfficers')
AddEventHandler('lfLockers:receiveJobOfficers', function(officers)
    SendNUIMessage({
        action = 'setOfficers',
        officers = officers
    })
end)

Citizen.CreateThread(function()
    while true do
        local sleep = 1000
        
        local nearbyLocker, distance = GetNearbyLocker()
        
        if nearbyLocker and IsPlayerJobMatch(nearbyLocker.jobRequired) then
            if distance < nearbyLocker.drawDistance then
                sleep = 0
                
                isNearLocker = distance < 2.0
                
                local markerPos = vector3(
                    nearbyLocker.position.x, 
                    nearbyLocker.position.y, 
                    nearbyLocker.position.z - 0.95
                )
                
                DrawMarker(
                    nearbyLocker.markerType,
                    markerPos.x,
                    markerPos.y,
                    markerPos.z,
                    0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
                    nearbyLocker.markerSize.x, nearbyLocker.markerSize.y, nearbyLocker.markerSize.z,
                    nearbyLocker.markerColor.r, nearbyLocker.markerColor.g, nearbyLocker.markerColor.b, nearbyLocker.markerColor.a,
                    false, false, 2, nil, nil, false
                )
                
                if isNearLocker then
                    ESX.ShowHelpNotification(_U('press_to_access', nearbyLocker.name))
                    
                    if IsControlJustReleased(0, Config.Keys.open) then
                        if GetPlayerGrade() >= nearbyLocker.adminGrade then
                            OpenLockerUI(nearbyLocker)
                        else
                            OpenPersonalLocker(nearbyLocker)
                        end
                    end
                end
            else
                sleep = 500
                isNearLocker = false
            end
        else
            sleep = 2000
            isNearLocker = false
        end
        
        if not isNearLocker and uiOpen then
            CloseLockerUI()
        end
        
        Citizen.Wait(sleep)
    end
end)

Citizen.CreateThread(function()
    while true do
        local sleep = 200
        
        if uiOpen then
            sleep = 0
            if IsControlJustReleased(0, Config.Keys.cancel) then
                CloseLockerUI()
            end
        end
        
        Citizen.Wait(sleep)
    end
end) 