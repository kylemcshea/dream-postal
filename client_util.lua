FRAMEWORK = nil

if (Config.FRAMEWORK == 'qb') then
    FRAMEWORK = Config.GET_CORE
elseif (Config.FRAMEWORK == 'esx') then
    FRAMEWORK = exports["es_extended"]:getSharedObject()
elseif (Config.FRAMEWORK == 'esx-old') then
    Citizen.CreateThread(function()
        while FRAMEWORK == nil do
            TriggerEvent('esx:getSharedObject', function(obj) FRAMEWORK = obj end)
            Citizen.Wait(0)
        end
    end)
else
    -- put in custom logic to grab framework and delete print code underneath
    print('^6[^3dream-postal^6]^0 Unsupported Framework detected!')
end

---@param message string text of the notification
---@param type? string
---@param duration? integer milliseconds notification will remain on screen. Defaults to 5000
function NotifyPlayer(message, type, duration)
    duration = duration or 5000

    if (Config.NOTIFY == 'qb') then
        FRAMEWORK.Functions.Notify(message, type, duration)
    elseif (Config.NOTIFY == 'ox') then
        lib.notify({
            title = 'GoPostal',
            description = message,
            type = type,
            duration = duration,
        })
    elseif (Config.NOTIFY == 'esx') then
        FRAMEWORK.ShowHelpNotification(message)
    elseif (Config.NOTIFY == 'esx-new') then
        FRAMEWORK.ShowNotification(message, type, duration)
    elseif (Config.NOTIFY == 'okok') then
        exports['okokNotify']:Alert('GoPostal', message, duration, type)
    elseif (Config.NOTIFY == 'mythic') then
        exports['mythic_notify']:DoHudText(type, message)
    elseif (Config.NOTIFY == 'chat') then
        TriggerEvent('chatMessage', message)
    else
        -- put in custom logic to notify player and delete print code underneath
        print('^6[^3dream-postal^6]^0 Unsupported Notify detected!')
    end
end

RegisterNetEvent('dream-postal:client:notifyPlayer', function(message, type, duration)
    NotifyPlayer(message, type, duration)
end)

---@param vehicle number
function GivePlayerVehicleKeys(vehicle)
    local plate = GetVehicleNumberPlateText(vehicle)
    TriggerEvent('vehiclekeys:client:SetOwner', plate)
end

-- DEV TOOL to print the nearest postal box coordinates.
RegisterCommand('pbox', function()
    local boxCoords = getNearestPostalBox(100.0)

    if (not boxCoords) then
        return
    end

    -- Print the retrieved data. To see this:
    -- Press F8 > Click "Open Log" > Scroll to the bottom of the log.
    -- Then, you can copy the coordinates and heading tool Config.POSTAL_GET_PACKAGE
    print("Postal Box Coordinates:", boxCoords)
end)

local isRecording = false
local postalBoxes = {}
local SLEEP_MS = 5000

-- This command allows users to record postal boxes in their vicinity.
RegisterCommand('pbox_record', function()
    isRecording = not isRecording

    if (not isRecording) then
        print("Stopped recording postal box locations.")
        return
    end

    print("Started recording postal box locations...")

    CreateThread(function()
        while (isRecording) do
            print('Searching for postal box...')
            local boxCoords = getNearestPostalBox(100.0)

            Wait(SLEEP_MS)

            if (not boxCoords) then
                print('No postal box found within range.')
            else
                print('Found postal box at: ', boxCoords)

                local found = false

                -- Check if the found coordinates are already in our configuration.
                for _, configCoords in pairs(Config.POSTAL_GET_PACKAGE) do
                    if (boxCoords == configCoords) then
                        found = true
                        print('This postal box is already in the config.')
                        break
                    end
                end

                -- Check if we have already recorded it in this session.
                if not found then
                    for _, currentCoords in pairs(postalBoxes) do
                        if (boxCoords == currentCoords) then
                            found = true
                            print('This postal box is already recorded in the current session.')
                            break
                        end
                    end
                end

                if not found then
                    print('New postal box recorded!')
                    table.insert(postalBoxes, boxCoords)
                end
            end
        end

        -- Once recording is stopped, print out the newly recorded coordinates.
        print('NEWLY RECORDED POSTAL COORDINATES: ')
        for _, newCoords in pairs(postalBoxes) do
            print(newCoords)
        end
    end)
end)

function getPlayerOutfit(playerPed)
    local outfitComponents = {
        {componentId = 1, label = "Masks [1]"},
        {componentId = 2, label = "Hair [2]"},
        {componentId = 3, label = "Hands [3]"},
        {componentId = 4, label = "Pants [4]"},
        {componentId = 5, label = "Parachutes/Backpacks [5]"},
        {componentId = 6, label = "Shoes [6]"},
        {componentId = 7, label = "Accessories [7]"},
        {componentId = 8, label = "Undershirt [8]"},
        {componentId = 9, label = "Body Armors [9]"},
        {componentId = 10, label = "Decals/Logos [10]"},
        {componentId = 11, label = "Jackets [11]"},
    }

    local outfitDetails = {}

    for _, component in ipairs(outfitComponents) do
        outfitDetails[component.label] = {
            drawable = GetPedDrawableVariation(playerPed, component.componentId),
            texture = GetPedTextureVariation(playerPed, component.componentId)
        }
    end

    return outfitDetails
end

RegisterCommand('gpfit', function()
    local playerPed = PlayerPedId()
    local playerOutfit = getPlayerOutfit(playerPed)
    for label, details in pairs(playerOutfit) do
        print(label .. ": Drawable(" .. details.drawable .. "), Texture(" .. details.texture .. ")")
    end
end)

local postalBoxHash = `prop_postbox_01a`

---@param searchRadius number
---@return vector3 | nil
function getNearestPostalBox(searchRadius)
    local playerCoords = GetEntityCoords(PlayerPedId())
    local nearestPostalBox = GetClosestObjectOfType(playerCoords, searchRadius, postalBoxHash)
    if (nearestPostalBox == 0) then return nil end

    return GetEntityCoords(nearestPostalBox)
end
