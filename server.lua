----Gets ESX------------------------------------
ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
------------------------------------------------
local washRate = 0

RegisterServerEvent('koe_moneywash:getRep')
AddEventHandler('koe_moneywash:getRep', function()
    local src = source
    local identifier =  ESX.GetPlayerFromId(source).identifier
    local xp = exports['koe_vendors']:getCrimLevel(identifier)
    local level

    if xp <= 99 then
        level = 0
    elseif xp <= 199 then
        level = 1 
    elseif xp <= 299 then
        level = 2
    elseif xp <= 1000 then
        level = 3
    elseif xp <= 2000 then
        level = 4
    elseif xp <= 2500 then
        level = 5
    elseif xp <= 3000 then
        level = 6
    elseif xp <= 3500 then
        level = 7
    elseif xp <= 4000 then
        level = 8
    elseif xp <= 4500 then
        level = 9
    elseif xp >= 5000 then
        level = 10
    end

    TriggerClientEvent('koe_moneywash:experience', src, xp, level)
end)

RegisterServerEvent('koe_moneywash:checkDirty')
AddEventHandler('koe_moneywash:checkDirty', function(amount, xp, level)
    local xPlayer = ESX.GetPlayerFromId(source)
    local dirty = xPlayer.getAccount('black_money').money

    if dirty >= amount then
        TriggerClientEvent('koe_moneywash:startWash', source, amount, xp, level)
    else
        TriggerClientEvent('ox_lib:notify', source, {type = 'error', description = 'Not enough dirty, you need $'..amount.. ' But you currently have $' ..dirty, duration = 8000, position = 'top'})
    end
end)

RegisterServerEvent('koe_moneywash:washIt')
AddEventHandler('koe_moneywash:washIt', function(amount, xp, level)
    local xPlayer = ESX.GetPlayerFromId(source)

    if level == 0 then
        washRate = 0.50
    elseif level == 1 then 
        washRate = 0.45
    elseif level == 2 then 
        washRate = 0.40
    elseif level == 3 then 
        washRate = 0.35
    elseif level == 4 then 
        washRate = 0.30
    elseif level == 5 then 
        washRate = 0.25
    elseif level == 6 then 
        washRate = 0.20
    elseif level == 7 then 
        washRate = 0.15
    elseif level == 8 then 
        washRate = 0.10
    elseif level == 9 then 
        washRate = 0.05
    elseif level == 10 then 
        washRate = 0.03
    end

    local washCut = amount * washRate
    
    xPlayer.removeAccountMoney('black_money', amount)
    xPlayer.addMoney(amount - washCut)

    local identifier =  ESX.GetPlayerFromId(source).identifier
    exports['koe_vendors']:giveCrimLevel(identifier, 200)

    TriggerClientEvent('ox_lib:notify', source, {type = 'inform', description = 'Your crime notoriety gave you a Wash Rate of %'..washRate, duration = 8000, position = 'top'})
end)
