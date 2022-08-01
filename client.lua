----Gets ESX-------------------------------------------------------------------------------------------------------------------------------
ESX = nil

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end
	while ESX.GetPlayerData().job == nil do
		Citizen.Wait(100)
	end
	PlayerLoaded = true
	ESX.PlayerData = ESX.GetPlayerData()

end)

Citizen.CreateThread(function()
	RegisterNetEvent('esx:playerLoaded')
	AddEventHandler('esx:playerLoaded', function (xPlayer)
		while ESX == nil do
			Citizen.Wait(0)
		end
		ESX.PlayerData = xPlayer
		PlayerLoaded = true
	end)
end) 

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
	ESX.PlayerData.job = job

end)
---------------------------------------------------------------------------------------------------------------------------------------

local pedSpawned = false
local pedNpc
local xp
local level
local location = 0
local inZone = false
local sphere

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1000)
            local pedCoords = GetEntityCoords(PlayerPedId()) 
            local npcCoords = Config.PedLocation
            local dst = #(pedCoords - npcCoords)
            
            if dst < 30 and pedSpawned == false then
                TriggerEvent('koe_moneywash:spawnPed',npcCoords, Config.PedHeading)
                pedSpawned = true
            end
            if dst >= 31  then
                pedSpawned = false
                DeleteEntity(pedNpc)
            end
    end
end)

RegisterNetEvent('koe_moneywash:spawnPed')
AddEventHandler('koe_moneywash:spawnPed',function(coords,heading) 

    local hash = GetHashKey(Config.PedModel)
    if not HasModelLoaded(hash) then
        RequestModel(hash)
        Wait(10)
    end
    while not HasModelLoaded(hash) do 
        Wait(10)
    end

    pedNpc = CreatePed(5, hash, coords, heading, false, false)
    FreezeEntityPosition(pedNpc, true)
    SetEntityInvincible(pedNpc, true)
    SetBlockingOfNonTemporaryEvents(pedNpc, true)
    SetModelAsNoLongerNeeded(hash)
    exports['qtarget']:AddEntityZone('pedNpc', pedNpc, {
            name    = "pedNpc",
            debugPoly   = false,
            useZ = true
                }, {
                options = {
                    {
                    event = "koe_moneywash:checkRep",
                    icon = "fa-solid fa-money-bill",
                    label = "Talk to Frank",
                    }                               
                },
                    distance = 2.5
                })
end)

RegisterNetEvent('koe_moneywash:checkRep')
AddEventHandler('koe_moneywash:checkRep',function() 
    TriggerServerEvent('koe_moneywash:getRep')
end)

RegisterNetEvent('koe_moneywash:experience')
AddEventHandler('koe_moneywash:experience',function(xp, level) 
    xp = xp
    level = level

    lib.notify({
        title = 'Frank',
        description = 'How much money do you want to wash?',
        type = 'inform',
        duration = 2000,
        position = 'top'
    })

    local input = lib.inputDialog('Enter a Amount', {'Amount'})

    if input then
        local amount = tonumber(input[1])
        TriggerServerEvent('koe_moneywash:checkDirty', amount, xp, level)
    end
end)

RegisterNetEvent('koe_moneywash:startWash')
AddEventHandler('koe_moneywash:startWash',function(amount, xp, level) 
    location = Config.WashLocations[math.random(#Config.WashLocations)]

    lib.notify({
        title = 'Frank',
        description = 'Head to the location i marked on your GPS',
        type = 'inform',
        duration = 8000,
        position = 'top'
    })

    sphere = lib.zones.sphere({
        coords = location,
        radius = 3,
        debug = false,
        inside = inside,
        onEnter = onEnter,
        amount = amount,
        xp = xp,
        level = level,
        onExit = onExit
    })
    
    Blip = AddBlipForCoord(location)
    SetBlipRoute(Blip,true)
end)

function inside(self)
    inZone = true
    lib.showTextUI('[E] - To Wash')
    if IsControlJustReleased(0, 38) and inZone == true then
        RemoveBlip(Blip)
        
        rng = math.random(1,50)

        if rng == 1 then
            local data = exports['cd_dispatch']:GetPlayerInfo()
            TriggerServerEvent('cd_dispatch:AddNotification', {
                job_table = {'police'}, 
                coords = data.coords,
                title = 'Suspicious Activity ',
                message = 'A '..data.sex..' is handing something to someone '..data.street, 
                flash = 0,
                unique_id = tostring(math.random(0000000,9999999)),
                blip = {
                sprite = 480, 
                scale = 1.2, 
                colour = 3,
                flashes = true, 
                text = 'Suspicious Activity',
                time = (5*60*1000),
                sound = 1,
                }
            })
        end

        xp = sphere.xp
        amount = sphere.amount
        level = sphere.level
        local waitTime = math.random(30000, 120000)
        lib.hideTextUI()
        sphere:remove()
        TriggerEvent('koe_moneywash:spawnPickupPed', amount, xp, level, waitTime)
        lib.progressBar({
            duration = waitTime,
            label = 'Washing...',
            useWhileDead = false,
            canCancel = false,
            disable = {
                car = true,
                move = true,
            },
        })
        TriggerServerEvent('koe_moneywash:washIt', amount, xp, level)
    end

end

function onExit(self)
    inZone = false
    lib.hideTextUI()
end

RegisterNetEvent('koe_moneywash:spawnPickupPed')
AddEventHandler('koe_moneywash:spawnPickupPed',function(amount, xp, level, waitTime) 
    print(waitTime)
    local hash2 = GetHashKey('g_m_m_chicold_01')
    if not HasModelLoaded(hash2) then
        RequestModel(hash2)
        Wait(10)
    end
    while not HasModelLoaded(hash2) do 
        Wait(10)
    end
    local moveTo = vector3(location.x -20, location.y -20, location.z)
    pedNpc2 = CreatePed(5, hash2, moveTo, heading, true, false)

    TaskGoToEntity(pedNpc2, PlayerPedId(), waitTime * 2, 2.0, 2.0, 1073741824, 0)
    SetEntityInvincible(pedNpc2, true)
    SetBlockingOfNonTemporaryEvents(pedNpc2, true)
    Citizen.Wait(waitTime + 5000)
    SetModelAsNoLongerNeeded(hash2)
    TaskWanderStandard(pedNpc2, 10.0, 10)
end)
