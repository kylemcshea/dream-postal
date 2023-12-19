FRAMEWORK      = nil
currentWorkers = {}

if (Config.FRAMEWORK == 'qb') then
    FRAMEWORK = Config.GET_CORE
elseif (Config.FRAMEWORK == 'esx') then
    FRAMEWORK = exports["es_extended"]:getSharedObject()
elseif (Config.FRAMEWORK == 'esx-old') then
    TriggerEvent('esx:getSharedObject', function(obj) FRAMEWORK = obj end)
else
    -- put in custom logic to grab framework and delete print code underneath
    print('^6[^3dream-postal^6]^0 Unsupported Framework detected!')
end

local PAY_MULTIPLIER = Config.PAY_MULTIPLIER

RegisterServerEvent("dream-postal:server:start:job", function()
    local source = source
    local ped = GetPlayerPed(source)
    local coords = GetEntityCoords(ped)
    local dist = #(coords - Config.POSTAL_BOSS_COORDS)

    if dist > 25 then
        print(("^8[CheatFlag]^0 dream-postal:server:start:job: %s(%s) Tried to start the job while %.2f meters away from marker"):format(GetPlayerName(source), GetPlayerIdentifier(source, 0), dist))
        return
    end

    currentWorkers[source] = {
        lastPoint = os.time(),
        takenPoints = 0
    }

    TriggerEvent("dream-postal:server:log", { source = source, type = "success", message = t('started_postal_job')})
end)

RegisterServerEvent("dream-postal:server:end:job", function()
    if not currentWorkers[source] then return end

    currentWorkers[source] = nil
    TriggerEvent("dream-postal:server:log", { source = source, type = "success", message = t('ended_shift')})
end)

---@param positionSet {startLocation: vector3, middleLocation: vector3, endLocation: vector3}
RegisterServerEvent('dream-postal:server:compensateDelivery', function(positionSet)
    local source = source
    local data = currentWorkers[source]

    if not data then
        print(("^8[CheatFlag]^0 dream-postal:server:compensateDelivery: %s(%s) Tried to deliver packages without starting the job"):format(GetPlayerName(source), GetPlayerIdentifier(source, 0)))
        return
    end

    local time = os.time() - data.lastPoint
    if os.time() - data.lastPoint < 30 then
        print(("^8[CheatFlag]^0 dream-postal:server:compensateDelivery: %s(%s) Tried to deliver packages while the last package was %s seconds ago"):format(GetPlayerName(source), GetPlayerIdentifier(source, 0), time))
        return
    end

    if #Config.POSTAL_DROP_OFF_PACKAGE - data.takenPoints < 0 then
        print(("^8[CheatFlag]^0 dream-postal:server:compensateDelivery: %s(%s) Tried to deliver packages while all point already taken?"):format(GetPlayerName(source), GetPlayerIdentifier(source, 0)))
        return
    end

    if not isNearAnyDeliverPoint(source) then
        print(("^8[CheatFlag]^0 dream-postal:server:compensateDelivery: %s(%s) Tried to deliver packages while not near any deliverpoint"):format(GetPlayerName(source), GetPlayerIdentifier(source, 0)))
        return
    end

    if not isValidPositionSet(positionSet) then
        print('Error: Missing position data.')
        return
    end

    local totalDistance = getDistance(positionSet.startLocation, positionSet.middleLocation) +
                          getDistance(positionSet.middleLocation, positionSet.endLocation)

    local compensation = math.floor(totalDistance * PAY_MULTIPLIER)
    
    local compensationMessage = t('you_have_been_paid', { ['compensation'] = compensation })
    TriggerClientEvent('dream-postal:client:notifyPlayer', source, compensationMessage, 'success')

    if (Config.FRAMEWORK == 'qb') then
        local Player = FRAMEWORK.Functions.GetPlayer(source)
        Player.Functions.AddMoney('bank', compensation)
    elseif (Config.FRAMEWORK == 'esx' or Config.FRAMEWORK == 'esx-old') then
        local xPlayer = FRAMEWORK.GetPlayerFromId(source)
        xPlayer.addAccountMoney('bank', compensation)
    else
        -- put in custom logic to grab framework and delete print code underneath
        print('^6[^3dream-postal^6]^0 Unsupported Framework detected!')
    end
    data.lastPoint = os.time()
    data.takenPoints += 1
    TriggerEvent("dream-postal:server:log", { source = source, type = "success", message = t('delivered_a_package')})
end)

local DISCORD_WEBHOOK = ''                         -- Your discord webhook here
local COLOR = '1327473'                                                                                                                             -- Color of the embed
local DISCORD_NAME = "DreamLife RP BOT"                                                                                                            -- Name of the bot
local DISCORD_IMAGE = "https://img.freepik.com/premium-vector/cute-robot-waving-hand-cartoon-illustration_138676-2744.jpg?w=2000"
local LOG_FOOTER = '[DreamLife RP LOGS]'

---@param data { type: string, message: string, source: int }
AddEventHandler('dream-postal:server:log', function(data)
    local src = data.source
    local xPlayer = getPlayerIdentification(src)
    local fullName = xPlayer.fullName
    local identifier = xPlayer.identifier

    local description = "Name: " .. fullName ..
    "\nIdentifier: " .. identifier ..
    "\nType: " .. data.type ..
    "\nMessage: " .. data.message

    local connect = {
        {
            ["color"] = COLOR,
            ["title"] = "**dream-postal**",
            ["description"] = description,
            ["footer"] = {
                ["text"] = LOG_FOOTER,
            },
        }
    }
    PerformHttpRequest(DISCORD_WEBHOOK, function() end, 'POST',
        json.encode({ username = DISCORD_NAME, embeds = connect, avatar_url = DISCORD_IMAGE }),
        { ['Content-Type'] = 'application/json' })
end)

AddEventHandler("playerDropped", function()
    if currentWorkers[source] then
        currentWorkers[source] = nil
    end

    TriggerEvent("dream-postal:server:log", { source = source, type = "success", message = t('ended_shift')})
end)


-- utils

function isNearAnyDeliverPoint(source)
    local coords = GetEntityCoords(GetPlayerPed(source))

    for _,v in pairs(Config.POSTAL_DROP_OFF_PACKAGE) do
        local deliverCoords = vector3(v.x, v.y, v.z)
        local dist = #(coords - deliverCoords)

        if dist < 15 then
            return true
        end
    end

    return false
end

function getDistance(pointA, pointB)
    return #(pointA - pointB)
end

function isValidPositionSet(positionSet)
    return positionSet and positionSet.startLocation and positionSet.middleLocation and positionSet.endLocation
end

---@return { fullName: string, identifier: string }
function getPlayerIdentification(src)
    local fullName = ''
    local identifier = ''

    if (Config.FRAMEWORK == 'qb') then
        local Player = FRAMEWORK.Functions.GetPlayer(src)
        fullName = Player.PlayerData.charinfo.firstname .. " " .. Player.PlayerData.charinfo.lastname
        identifier = Player.PlayerData.citizenid
    elseif (Config.FRAMEWORK == 'esx' or Config.FRAMEWORK == 'esx-old') then
        local xPlayer = FRAMEWORK.GetPlayerFromId(src)
        fullName = xPlayer.getName()
        identifier = xPlayer.identifier
    else
        -- put in custom logic to grab framework and delete print code underneath
        print('^6[^3dream-postal^6]^0 Unsupported Framework detected!')
    end

    return {
        fullName = fullName,
        identifier = identifier,
    }
end
