if Config and Config.ESXMode == 'old' then
    ESX = ESX or nil
    TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
else
    ESX = exports["es_extended"]:getSharedObject()
end

AddEventHandler('onResourceStart', function(resourceName)
    if resourceName ~= GetCurrentResourceName() then return end
end)

local function GetLockerConfig(lockerId)
    for i, locker in ipairs(Config.Lockers) do
        if locker.id == lockerId then
            return locker
        end
    end
    return nil
end

local function GetPlayerFullName(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return "Inconnu" end
    
    local result = MySQL.Sync.fetchAll('SELECT firstname, lastname FROM users WHERE identifier = @identifier', {
        ['@identifier'] = xPlayer.identifier
    })
    
    if result and result[1] then
        return result[1].firstname .. ' ' .. result[1].lastname
    else
        return "Inconnu"
    end
end

local function GenerateLockerID(xPlayer, lockerId)
    return lockerId .. '_' .. xPlayer.identifier:gsub(':', '_')
end

RegisterServerEvent('lfLockers:openPersonalLocker')
AddEventHandler('lfLockers:openPersonalLocker', function(lockerId)
    local source = source
    local xPlayer = ESX.GetPlayerFromId(source)
    
    if not xPlayer then return end
    
    local lockerConfig = GetLockerConfig(lockerId)
    if not lockerConfig then
        TriggerClientEvent('esx:showNotification', source, _U('config_not_found'))
        return
    end
    
    if xPlayer.job.name ~= lockerConfig.jobRequired then
        TriggerClientEvent('esx:showNotification', source, _U('no_access'))
        return
    end
    
    local fullName = GetPlayerFullName(source)
    local personalLockerId = GenerateLockerID(xPlayer, lockerId)
    
    exports.ox_inventory:RegisterStash(personalLockerId, _U('personal_locker') .. ' ' .. fullName, 50, lockerConfig.lockerWeight, xPlayer.identifier)
    TriggerClientEvent('ox_inventory:openInventory', source, 'stash', personalLockerId)
end)

RegisterServerEvent('lfLockers:openOfficerLocker')
AddEventHandler('lfLockers:openOfficerLocker', function(lockerId, targetId)
    local source = source
    local xPlayer = ESX.GetPlayerFromId(source)
    
    if not xPlayer then return end
    
    local lockerConfig = GetLockerConfig(lockerId)
    if not lockerConfig then
        TriggerClientEvent('esx:showNotification', source, _U('config_not_found'))
        return
    end
    
    if xPlayer.job.name ~= lockerConfig.jobRequired or xPlayer.job.grade < lockerConfig.adminGrade then
        TriggerClientEvent('esx:showNotification', source, _U('insufficient_rights'))
        return
    end
    
    local isOfflinePlayer = type(targetId) == "string"
    local tPlayer, offlineIdentifier
    
    if isOfflinePlayer then
        offlineIdentifier = targetId
        
        local result = MySQL.Sync.fetchAll('SELECT firstname, lastname FROM users WHERE identifier = @identifier AND job = @job', {
            ['@identifier'] = offlineIdentifier,
            ['@job'] = lockerConfig.jobRequired
        })
        
        if not result or not result[1] then
            TriggerClientEvent('esx:showNotification', source, _U('officer_wrong_job'))
            return
        end
        
        local fullName = result[1].firstname .. ' ' .. result[1].lastname
        local personalLockerId = lockerId .. '_' .. offlineIdentifier:gsub(':', '_')
        
        exports.ox_inventory:RegisterStash(personalLockerId, _U('personal_locker') .. ' ' .. fullName, 50, lockerConfig.lockerWeight, offlineIdentifier)
        TriggerClientEvent('ox_inventory:openInventory', source, 'stash', personalLockerId)
    else
        tPlayer = ESX.GetPlayerFromId(targetId)
        
        if not tPlayer then
            TriggerClientEvent('esx:showNotification', source, _U('officer_not_found'))
            return
        end
        
        if tPlayer.job.name ~= lockerConfig.jobRequired then
            TriggerClientEvent('esx:showNotification', source, _U('officer_not_found'))
            return
        end
        
        local fullName = GetPlayerFullName(targetId)
        local personalLockerId = GenerateLockerID(tPlayer, lockerId)
        
        exports.ox_inventory:RegisterStash(personalLockerId, _U('personal_locker') .. ' ' .. fullName, 50, lockerConfig.lockerWeight, tPlayer.identifier)
        TriggerClientEvent('ox_inventory:openInventory', source, 'stash', personalLockerId)
    end
end)

RegisterServerEvent('lfLockers:getJobOfficers')
AddEventHandler('lfLockers:getJobOfficers', function(lockerId)
    local source = source
    local xPlayer = ESX.GetPlayerFromId(source)
    
    if not xPlayer then return end
    
    local lockerConfig = GetLockerConfig(lockerId)
    if not lockerConfig then
        TriggerClientEvent('esx:showNotification', source, _U('config_not_found'))
        return
    end
    
    if xPlayer.job.name ~= lockerConfig.jobRequired or xPlayer.job.grade < lockerConfig.adminGrade then
        TriggerClientEvent('esx:showNotification', source, _U('insufficient_rights'))
        return
    end
    
    local officers = {}
    
    local result = MySQL.Sync.fetchAll('SELECT identifier, firstname, lastname, job_grade FROM users WHERE job = @job', {
        ['@job'] = lockerConfig.jobRequired
    })
    
    if result then
        for i=1, #result do
            local officerData = result[i]
            local gradeLabel = _U('rank') .. ' ' .. officerData.job_grade
            
            local gradeResult = MySQL.Sync.fetchAll('SELECT label FROM job_grades WHERE job_name = @job AND grade = @grade', {
                ['@job'] = lockerConfig.jobRequired,
                ['@grade'] = officerData.job_grade
            })
            
            if gradeResult and gradeResult[1] then
                gradeLabel = gradeResult[1].label
            end
            
            table.insert(officers, {
                id = officerData.identifier,
                name = officerData.firstname .. ' ' .. officerData.lastname,
                grade = gradeLabel,
                online = false
            })
        end
    end
    
    local players = ESX.GetPlayers()
    for i=1, #players do
        local tPlayer = ESX.GetPlayerFromId(players[i])
        if tPlayer and tPlayer.job.name == lockerConfig.jobRequired then
            local found = false
            for j=1, #officers do
                if officers[j].id == tPlayer.identifier then
                    officers[j].online = true
                    officers[j].id = players[i]
                    found = true
                    break
                end
            end
            
            if not found then
                local fullName = GetPlayerFullName(players[i])
                table.insert(officers, {
                    id = players[i],
                    name = fullName,
                    grade = tPlayer.job.grade_label or _U('rank') .. ' ' .. tPlayer.job.grade,
                    online = true
                })
            end
        end
    end
    
    TriggerClientEvent('lfLockers:receiveJobOfficers', source, officers)
end) 