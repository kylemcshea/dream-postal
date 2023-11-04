FRAMEWORK = nil

if (Config.FRAMEWORK == 'qb') then
    FRAMEWORK = Config.GET_CORE
elseif (Config.FRAMEWORK == 'esx') then
    TriggerEvent('esx:getSharedObject', function(obj) FRAMEWORK = obj end)
else
    -- put in custom logic to grab framework and delete print code underneath
    print('^6[^3dream-postal^6]^0 Unsupported Framework detected!')
end

local PAY_MULTIPLIER = Config.PAY_MULTIPLIER

---@param positionSet {startLocation: vector3, middleLocation: vector3, endLocation: vector3}
RegisterServerEvent('dream-postal:server:compensateDelivery', function(positionSet)
    if not isValidPositionSet(positionSet) then
        print('Error: Missing position data.')
        return
    end

    local totalDistance = getDistance(positionSet.startLocation, positionSet.middleLocation) +
                          getDistance(positionSet.middleLocation, positionSet.endLocation)

    local compensation = math.floor(totalDistance * PAY_MULTIPLIER)

    if (Config.FRAMEWORK == 'qb') then
        local Player = FRAMEWORK.Functions.GetPlayer(source)
        Player.Functions.AddMoney('bank', compensation)
    elseif (Config.FRAMEWORK == 'esx') then
        local xPlayer = FRAMEWORK.GetPlayerFromId(source)
        xPlayer.addAccountMoney('bank', compensation)
    else
        -- put in custom logic to grab framework and delete print code underneath
        print('^6[^3dream-postal^6]^0 Unsupported Framework detected!')
    end
end)

local DISCORD_WEBHOOK = ''                         -- Your discord webhook here
local COLOR = '1327473'                                                                                                                             -- Color of the embed
local DISCORD_NAME = "DreamLife RP BOT"                                                                                                            -- Name of the bot
local DISCORD_IMAGE = "https://img.freepik.com/premium-vector/cute-robot-waving-hand-cartoon-illustration_138676-2744.jpg?w=2000"
local LOG_FOOTER = '[DreamLife RP LOGS]'

---@param data { type: string, message: string, postalJobState?: table }
RegisterServerEvent('dream-postal:server:log', function(data)
    local src = source
    local xPlayer = getPlayerIdentification(src)
    local fullName = xPlayer.fullName
    local identifier = xPlayer.identifier

    local description = "Name: " .. fullName ..
    "\nIdentifier: " .. identifier ..
    "\nType: " .. data.type ..
    "\nMessage: " .. data.message .. "\n"

    -- IF data.postalJobState sent
    -- Iterate through the postalJobState fields and add them to the description
    if data.postalJobState then
        description = description .. "\nPostal Job State:\n"
        for key, value in pairs(data.postalJobState) do
            if type(value) == "table" then
                description = description .. key .. ":\n"
                for subKey, subValue in pairs(value) do
                    description = description .. "  " .. subKey .. ": " .. tostring(subValue) .. "\n"
                end
            else
                description = description .. key .. ": " .. tostring(value) .. "\n"
            end
        end
    end

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


-- utils

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
    elseif (Config.FRAMEWORK == 'esx') then
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
