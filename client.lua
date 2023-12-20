---@diagnostic disable: lowercase-global
local POSTAL_BOSS_COORDS = Config.POSTAL_BOSS_COORDS
local POSTAL_BOSS_HEADING = Config.POSTAL_BOSS_HEADING
local POSTAL_BOSS_HASH = Config.POSTAL_BOSS_HASH
local POSTAL_BOSS_ANIMATION = Config.POSTAL_BOSS_ANIMATION
local POSTAL_VEHICLE_HASH = Config.POSTAL_VEHICLE_HASH
local POSTAL_VEHICLE_SPAWN_COORDS = Config.POSTAL_VEHICLE_SPAWN_COORDS
local POSTAL_GET_PACKAGE = Config.POSTAL_GET_PACKAGE
local POSTAL_DROP_OFF_PACKAGE = Config.POSTAL_DROP_OFF_PACKAGE
local PICK_UP_BLIP = Config.PICK_UP_BLIP
local DROP_OFF_BLIP = Config.DROP_OFF_BLIP
local GO_POSTAL_HQ_BLIP = Config.GO_POSTAL_HQ_BLIP
local MALE_OUTFIT = Config.MALE_OUTFIT
local FEMALE_OUTFIT = Config.FEMALE_OUTFIT
local DROP_OFF_PED_HASH = Config.DROP_OFF_PED_HASH
local SHOW_WHITE_ARROW_MARKER = Config.SHOW_WHITE_ARROW_MARKER
local IS_WHITELISTED_TO_JOB = Config.IS_WHITELISTED_TO_JOB
local WHITELISTED_JOB_TITLE = Config.WHITELISTED_JOB_TITLE

local isPedSpawned = false
local postalBossPed = nil

local postalJobState = {
    isDoingJob = false, -- <boolean>
    dropOffCoords = nil, -- <vec3>
    goPostalVan = nil, -- entity <number>
    isCarryingBox = false, -- <boolean>
    hasBoxInVan = false, -- <boolean>
    deliverToPed = nil, -- entity <number>
    isDeliveringPackage = false, -- <boolean>
    postalBoxZone = nil, -- <number>
    positionSet = {
        startLocation = nil, -- <vec3>
        middleLocation = nil, -- <vec3>
        endLocation = nil, -- <vec3>
    },
    pickupBlip = nil, -- <number> blip
    dropoffBlip = nil, -- <number> blip
}

function resetJobState()
    if (postalJobState.isCarryingBox) then
        removeBox()
    end

    if (postalJobState.pickupBlip) then
        RemoveBlip(postalJobState.pickupBlip)
    end

    if (postalJobState.dropoffBlip) then
        RemoveBlip(postalJobState.dropoffBlip)
    end

    if (postalJobState.postalBoxZone) then
        TARGET.RemoveZone(postalJobState.postalBoxZone)
    end

    if (postalJobState.goPostalVan) then
        if (Config.TARGET == 'ox') then
            exports.ox_target:removeLocalEntity(postalJobState.goPostalVan, { 'put-package-in-van', 'take-out-package-from-van', 'drop-off-in-trunk' })
        elseif (Config.TARGET == 'qb-target') then
            exports['qb-target']:RemoveTargetEntity(postalJobState.goPostalVan, { 'put-package-in-van', 'take-out-package-from-van', 'drop-off-in-trunk' })
        else
        -- put in custom logic to grab target and delete print code underneath
        print('^6[^3dream-postal^6]^0 Unsupported Target detected!')
        end
    end

    postalJobState = {
        isDoingJob = false,
        dropOffCoords = nil,
        goPostalVan = nil,
        isCarryingBox = false,
        hasBoxInVan = false,
        deliverToPed = nil,
        isDeliveringPackage = false,
        positionSet = {
            startLocation = nil,
            middleLocation = nil,
            endLocation = nil,
        },
        pickupBlip = nil,
        dropoffBlip = nil,
    }
end


function startPostalJob()
    if not isSpawnPointClear(POSTAL_VEHICLE_SPAWN_COORDS, 10.0) then
        NotifyPlayer(t('please_clear_area'), 'error', 7500)
        return
    end

    local playerPed = PlayerPedId()
    NotifyPlayer(t('head_over_to_waypoint'))
    postalJobState.isDoingJob = true
    postalJobState.positionSet.startLocation = GetEntityCoords(playerPed)
    TriggerServerEvent("dream-postal:server:start:job")
    spawnGoPostalVehicle()
    putOnJobOutfit()

    -- grab coords to go to pick up postal delivery
    local randomNumber = math.random(1, #POSTAL_GET_PACKAGE)
    local tempDeliveryCoords = POSTAL_GET_PACKAGE[randomNumber]

    local retval, groundZ = GetGroundZFor_3dCoord(tempDeliveryCoords.x, tempDeliveryCoords.y, tempDeliveryCoords.z, false)
    local deliveryCoords = tempDeliveryCoords
    if retval then
        deliveryCoords = vec3(tempDeliveryCoords.x, tempDeliveryCoords.y, groundZ)
    end

    local deliveryBlip = AddBlipForCoord(deliveryCoords)
	SetBlipSprite(deliveryBlip, PICK_UP_BLIP.sprite)
	SetBlipDisplay(deliveryBlip, PICK_UP_BLIP.display)
	SetBlipScale(deliveryBlip, PICK_UP_BLIP.scale)
	SetBlipColour(deliveryBlip, PICK_UP_BLIP.colour)
	SetBlipAsShortRange(deliveryBlip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentSubstringPlayerName(PICK_UP_BLIP.label)
	EndTextCommandSetBlipName(deliveryBlip)

    postalJobState.pickupBlip = deliveryBlip

    SetNewWaypoint(deliveryCoords.x, deliveryCoords.y)

    local parameters = {
        options = {{
            type   = "client",
            action = pickupMail,
            icon   = 'fas fa-envelope',
            label  = t('grab_package'),
        }},
        distance = 3.0,
        rotation = 45,
    }

    postalJobState.postalBoxZone = TARGET.AddBoxZone('dream-postal-grab-delivery', deliveryCoords, vec3(1.0, 1.0, 3.0), parameters)

    if (SHOW_WHITE_ARROW_MARKER) then
        CreateThread(function()
            while postalJobState.postalBoxZone do
                local playerCoords = GetEntityCoords(playerPed)
                local distanceToMarker = #(playerCoords - deliveryCoords)

                if (distanceToMarker <= 50.0) then
                    DrawMarker(22, deliveryCoords.x, deliveryCoords.y, (deliveryCoords.z + 1.75), 0, 0, 0, 0, 0, 1.0, 1.0, 1.0, 1.0, 255, 255, 220, 200, 0, 0, 0, 1)
                    Wait(1)
                else
                    Wait(3000)
                end
            end
        end)
    end
end

function pickupMail()
    if (not postalJobState.isDoingJob) then
        NotifyPlayer(t('you_are_not_on_the_job'), 'error')
        return
    end

    NotifyPlayer(t('place_package_in_back_of_van'))

    TARGET.RemoveZone(postalJobState.postalBoxZone)
    RemoveBlip(postalJobState.pickupBlip)
    postalJobState.pickupBlip = nil
    postalJobState.postalBoxZone = nil
    postalJobState.positionSet.middleLocation = GetEntityCoords(PlayerPedId())
    carryBox()

    if (Config.TARGET == 'ox') then
        exports.ox_target:addLocalEntity(postalJobState.goPostalVan, {
            {
                name = 'drop-off-in-trunk',
                icon = 'fa-solid fa-envelope',
                label = t('drop_off_package_in_trunk'),
                drawSprite = true,
                bones = { 'door_pside_r', 'seat_pside_r' },
                canInteract = function(entity, _distance, coords, _name)
                    local boneId = GetEntityBoneIndexByName(entity, 'door_pside_r')

                    if boneId ~= -1 then
                        return #(coords - GetEntityBonePosition_2(entity, boneId)) < 5.0 or
                            #(coords - GetEntityBonePosition_2(entity, GetEntityBoneIndexByName(entity, 'seat_pside_r'))) < 5.0
                    end
                end,
                distance = 3.0,
                onSelect = insertPackageIntoVehicle,
            }
        })
    elseif (Config.TARGET == 'qb-target') then
        exports['qb-target']:AddTargetEntity(postalJobState.goPostalVan, {
            options = {
                {
                    type = "client",
                    icon = 'fa-solid fa-envelope',
                    label = t('drop_off_package_in_trunk'),
                    canInteract = function(entity, distance, data)
                        -- Here we're checking for the bone positions, similar to your ox_target logic
                        local boneId = GetEntityBoneIndexByName(entity, 'door_pside_r')

                        if boneId ~= -1 then
                            local coords = GetEntityCoords(PlayerPedId())  -- Get the coords of the player to compare with the entity's bone positions
                            return #(coords - GetEntityBonePosition_2(entity, boneId)) < 5.0 or
                                #(coords - GetEntityBonePosition_2(entity, GetEntityBoneIndexByName(entity, 'seat_pside_r'))) < 5.0
                        end

                        return false  -- Add a return false in case boneId is -1
                    end,
                    action = function()
                        if postalJobState.isCarryingBox then
                            insertPackageIntoVehicle()
                        else
                            NotifyPlayer(t('you are not carrying a package'), 'error')
                        end
                    end,
                }
            },
            distance = 3.0,
        })
    else
        -- put in custom logic to grab target and delete print code underneath
        print('^6[^3dream-postal^6]^0 Unsupported Target detected!')
    end
end

function insertPackageIntoVehicle()
    -- TODO: add some sort of animation
    removeBox()

    if (Config.TARGET == 'ox') then
        exports.ox_target:removeLocalEntity(postalJobState.goPostalVan, { 'drop-off-in-trunk' })
    elseif (Config.TARGET == 'qb-target') then
        exports['qb-target']:RemoveTargetEntity(postalJobState.goPostalVan, { 'drop-off-in-trunk' })
    else
        -- put in custom logic to grab target and delete print code underneath
        print('^6[^3dream-postal^6]^0 Unsupported Target detected!')
    end
    postalJobState.isCarryingBox = false
    postalJobState.hasBoxInVan = true
    postalJobState.isDeliveringPackage = true

    createRemovePackageFromVanZone()

    local randomNumber = math.random(1, #POSTAL_DROP_OFF_PACKAGE)
    local deliverPackageToCoords = POSTAL_DROP_OFF_PACKAGE[randomNumber] ---@as vector4

    SetNewWaypoint(deliverPackageToCoords.x, deliverPackageToCoords.y)

    local deliveryCoords = vec3(deliverPackageToCoords.x, deliverPackageToCoords.y, deliverPackageToCoords.z)
    local deliveryHeading = deliverPackageToCoords.w ---@as number

    local dropoffBlip = AddBlipForCoord(deliveryCoords)
	SetBlipSprite(dropoffBlip, DROP_OFF_BLIP.sprite)
	SetBlipDisplay(dropoffBlip, DROP_OFF_BLIP.display)
	SetBlipScale(dropoffBlip, DROP_OFF_BLIP.scale)
	SetBlipColour(dropoffBlip, DROP_OFF_BLIP.colour)
	SetBlipAsShortRange(dropoffBlip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentSubstringPlayerName(DROP_OFF_BLIP.label)
	EndTextCommandSetBlipName(dropoffBlip)

    postalJobState.dropoffBlip = dropoffBlip
    postalJobState.dropOffCoords = deliveryCoords

    CreateThread(function()
        while postalJobState.isDeliveringPackage do
            local playerCoords = GetEntityCoords(PlayerPedId())
            local distanceFromPed = #(deliveryCoords- playerCoords)
            if distanceFromPed < 200 and not postalJobState.deliverToPed then
                spawnDeliverToPed(DROP_OFF_PED_HASH, deliveryCoords, deliveryHeading)
            end
            if postalJobState.deliverToPed and distanceFromPed >= 200 then
                DeletePed(postalJobState.deliverToPed)
                postalJobState.deliverToPed = nil
            end
            Wait(2000)
        end

        if (postalJobState.deliverToPed) then
            DeletePed(postalJobState.deliverToPed)
            postalJobState.deliverToPed = nil
        end
    end)
end

function createRemovePackageFromVanZone()
    if (Config.TARGET == 'ox') then
        exports.ox_target:addLocalEntity(postalJobState.goPostalVan, {
            {
                name = 'take-out-package-from-van',
                icon = 'fa-solid fa-envelope',
                label = t('take_out_package'),
                drawSprite = true,
                bones = { 'door_pside_r', 'seat_pside_r' },
                canInteract = function(entity, _distance, coords, _name)
                    if (postalJobState.isCarryingBox or not postalJobState.isDoingJob) then
                        return false
                    end

                    local boneId = GetEntityBoneIndexByName(entity, 'door_pside_r')

                    if boneId ~= -1 then
                        return #(coords - GetEntityBonePosition_2(entity, boneId)) < 5.0 or
                            #(coords - GetEntityBonePosition_2(entity, GetEntityBoneIndexByName(entity, 'seat_pside_r'))) < 5.0
                    end
                end,
                distance = 3.0,
                onSelect = removePackageFromVehicle,
            }
        })
    elseif (Config.TARGET == 'qb-target') then
        exports['qb-target']:AddTargetEntity(postalJobState.goPostalVan, {
            options = {
                {
                    type = "client",
                    icon = 'fa-solid fa-envelope',
                    label = t('take_out_package'),
                    canInteract = function(entity, distance, data)
                        if (postalJobState.isCarryingBox or not postalJobState.isDoingJob) then
                            return false
                        end

                        -- Here we're checking for the bone positions, similar to your ox_target logic
                        local boneId = GetEntityBoneIndexByName(entity, 'door_pside_r')

                        if boneId ~= -1 then
                            local coords = GetEntityCoords(PlayerPedId())  -- Get the coords of the player to compare with the entity's bone positions
                            return #(coords - GetEntityBonePosition_2(entity, boneId)) < 5.0 or
                                #(coords - GetEntityBonePosition_2(entity, GetEntityBoneIndexByName(entity, 'seat_pside_r'))) < 5.0
                        end

                        return false  -- Add a return false in case boneId is -1
                    end,
                    action = function()
                        removePackageFromVehicle()
                    end,
                }
            },
            distance = 3.0,
        })
    else
        -- put in custom logic to grab target and delete print code underneath
        print('^6[^3dream-postal^6]^0 Unsupported Target detected!')
    end
end

function removePackageFromVehicle()
    carryBox()
    postalJobState.hasBoxInVan = false

    if (Config.TARGET == 'ox') then
        exports.ox_target:removeLocalEntity(postalJobState.goPostalVan, { 'take-out-package-from-van' })
    elseif (Config.TARGET == 'qb-target') then
        exports['qb-target']:RemoveTargetEntity(postalJobState.goPostalVan, { 'take-out-package-from-van' })
    else
        -- put in custom logic to grab target and delete print code underneath
        print('^6[^3dream-postal^6]^0 Unsupported Target detected!')
    end

    createPutPackageInVanZone()
end

function createPutPackageInVanZone()
    if (Config.TARGET == 'ox') then
        exports.ox_target:addLocalEntity(postalJobState.goPostalVan, {
            {
                name = 'put-package-in-van',
                icon = 'fa-solid fa-envelope',
                label = t('put_package_in_van'),
                drawSprite = true,
                bones = { 'door_pside_r', 'seat_pside_r' },
                canInteract = function(entity, _distance, coords, _name)
                    if (not postalJobState.isCarryingBox or not postalJobState.isDoingJob) then
                        return false
                    end

                    local boneId = GetEntityBoneIndexByName(entity, 'door_pside_r')

                    if boneId ~= -1 then
                        return #(coords - GetEntityBonePosition_2(entity, boneId)) < 5.0 or
                            #(coords - GetEntityBonePosition_2(entity, GetEntityBoneIndexByName(entity, 'seat_pside_r'))) < 5.0
                    end
                end,
                distance = 3.0,
                onSelect = putPackageInVehicle,
            }
        })
    elseif (Config.TARGET == 'qb-target') then
        exports['qb-target']:AddTargetEntity(postalJobState.goPostalVan, {
            options = {
                {
                    type = "client",
                    icon = 'fa-solid fa-envelope',
                    label = t('put_package_in_van'),
                    canInteract = function(entity, distance, data)
                        if (not postalJobState.isCarryingBox or not postalJobState.isDoingJob) then
                            return false
                        end

                        -- Here we're checking for the bone positions, similar to your ox_target logic
                        local boneId = GetEntityBoneIndexByName(entity, 'door_pside_r')

                        if boneId ~= -1 then
                            local coords = GetEntityCoords(PlayerPedId())  -- Get the coords of the player to compare with the entity's bone positions
                            return #(coords - GetEntityBonePosition_2(entity, boneId)) < 5.0 or
                                #(coords - GetEntityBonePosition_2(entity, GetEntityBoneIndexByName(entity, 'seat_pside_r'))) < 5.0
                        end

                        return false  -- Add a return false in case boneId is -1
                    end,
                    action = function()
                        putPackageInVehicle()
                    end,
                }
            },
            distance = 3.0,
        })
    else
        -- put in custom logic to grab target and delete print code underneath
        print('^6[^3dream-postal^6]^0 Unsupported Target detected!')
    end
end

function putPackageInVehicle()
    removeBox()
    postalJobState.isCarryingBox = false
    postalJobState.hasBoxInVan = true

    if (Config.TARGET == 'ox') then
        exports.ox_target:removeLocalEntity(postalJobState.goPostalVan, { 'put-package-in-van' })
    elseif (Config.TARGET == 'qb-target') then
        exports['qb-target']:RemoveTargetEntity(postalJobState.goPostalVan, { 'put-package-in-van' })
    else
        -- put in custom logic to grab target and delete print code underneath
        print('^6[^3dream-postal^6]^0 Unsupported Target detected!')
    end

    createRemovePackageFromVanZone()
end

function spawnGoPostalVehicle()
    RequestModel(POSTAL_VEHICLE_HASH)
    while not HasModelLoaded(POSTAL_VEHICLE_HASH) do Citizen.Wait(0) end
    local vehicle = CreateVehicle(POSTAL_VEHICLE_HASH, POSTAL_VEHICLE_SPAWN_COORDS, true, false)

    GivePlayerVehicleKeys(vehicle)

    local networkId = NetworkGetNetworkIdFromEntity(vehicle)
    SetNetworkIdCanMigrate(networkId, true)

    SetVehicleHasBeenOwnedByPlayer(vehicle, true)
    SetVehicleNeedsToBeHotwired(vehicle, false)
    SetVehRadioStation(vehicle, 'OFF')
    SetVehicleFuelLevel(vehicle, 100.0)
    SetModelAsNoLongerNeeded(POSTAL_VEHICLE_HASH)

    postalJobState.goPostalVan = vehicle
end

function endPostalJob()
    NotifyPlayer(t('you_are_done_with_shift'))
    TriggerServerEvent("dream-postal:server:end:job")

    if (postalJobState.goPostalVan) then
        DeleteEntity(postalJobState.goPostalVan)
    end
    takeOffJobOutfit()
    resetJobState()
end

function spawnPostalBossPed()
    local postalPedHashKey = joaat(POSTAL_BOSS_HASH)
    if not HasModelLoaded(postalPedHashKey) then
        RequestModel(postalPedHashKey)
        Wait(10)
    end
    while not HasModelLoaded(postalPedHashKey) do
        Wait(10)
    end

    postalBossPed = CreatePed(5, postalPedHashKey, POSTAL_BOSS_COORDS, POSTAL_BOSS_HEADING, false, false)
    FreezeEntityPosition(postalBossPed, true)
    SetEntityInvincible(postalBossPed, true)
    SetBlockingOfNonTemporaryEvents(postalBossPed, true)
    SetModelAsNoLongerNeeded(postalPedHashKey)
    TaskStartScenarioInPlace(postalBossPed, POSTAL_BOSS_ANIMATION, 0 ,true)

    if (Config.TARGET == 'ox') then
        exports.ox_target:addLocalEntity(postalBossPed, {
            {
                name = 'start-postal-job',
                icon = 'fa-solid fa-envelope',
                label = t('start_postal_job'),
                canInteract = function()
                    return postalJobState.isDoingJob == false
                end,
                distance = 3.0,
                onSelect = startPostalJob,
                groups = IS_WHITELISTED_TO_JOB and WHITELISTED_JOB_TITLE or nil,
            },
            {
                name = 'end-postal-job',
                icon = 'fa-solid fa-envelope',
                label = t('end_postal_job'),
                canInteract = function()
                    return postalJobState.isDoingJob == true
                end,
                distance = 3.0,
                onSelect = endPostalJob,
                groups = IS_WHITELISTED_TO_JOB and WHITELISTED_JOB_TITLE or nil,
            }
        })
    elseif (Config.TARGET == 'qb-target') then
        exports['qb-target']:AddTargetEntity(postalBossPed, {
            options = {
                {
                    type = "client",
                    icon = 'fa-solid fa-envelope',
                    label = t('start_postal_job'),
                    canInteract = function()
                        return postalJobState.isDoingJob == false
                    end,
                    action = function()
                        startPostalJob()
                    end,
                    job = IS_WHITELISTED_TO_JOB and WHITELISTED_JOB_TITLE or nil,
                },
                {
                    type = "client",
                    icon = 'fa-solid fa-envelope',
                    label = t('end_postal_job'),
                    canInteract = function()
                        return postalJobState.isDoingJob == true
                    end,
                    action = function()
                        endPostalJob()
                    end,
                    job = IS_WHITELISTED_TO_JOB and WHITELISTED_JOB_TITLE or nil,
                }
            },
            distance = 3.0,
        })
    else
        -- put in custom logic to grab target and delete print code underneath
        print('^6[^3dream-postal^6]^0 Unsupported Target detected!')
    end
end

---@param hash string
---@param coords vector3
---@param heading number
function spawnDeliverToPed(hash, coords, heading)
    local hashKey = joaat(hash)
    if not HasModelLoaded(hashKey) then
        RequestModel(hashKey)
        Wait(10)
    end
    while not HasModelLoaded(hashKey) do
        Wait(10)
    end

    local spawnZ = coords.z

    local retval, groundZ = GetGroundZFor_3dCoord(coords.x, coords.y, coords.z, false)
    if retval then
        spawnZ = groundZ
    end

    local deliverToPed = CreatePed(5, hashKey, coords.x, coords.y, spawnZ, heading, false, false)
    FreezeEntityPosition(deliverToPed, true)
    SetEntityInvincible(deliverToPed, true)
    SetBlockingOfNonTemporaryEvents(deliverToPed, true)
    SetModelAsNoLongerNeeded(hashKey)
    TaskStartScenarioInPlace(deliverToPed, POSTAL_BOSS_ANIMATION, 0 ,true)

    postalJobState.deliverToPed = deliverToPed

    if (SHOW_WHITE_ARROW_MARKER) then
        CreateThread(function()
            local playerPed = PlayerPedId()
            while postalJobState.isDeliveringPackage do
                local playerCoords = GetEntityCoords(playerPed)
                local distanceToMarker = #(playerCoords - coords)

                if (distanceToMarker <= 50.0) then
                    DrawMarker(22, coords.x, coords.y, (coords.z + 1.50), 0, 0, 0, 0, 0, 1.0, 1.0, 1.0, 1.0, 255, 255, 220, 200, 0, 0, 0, 1)
                    Wait(1)
                else
                    Wait(3000)
                end
            end
        end)
    end

    if (Config.TARGET == 'ox') then
        exports.ox_target:addLocalEntity(deliverToPed, {
            {
                name = 'drop-off-package',
                icon = 'fa-solid fa-envelope',
                label = t('drop_off_package'),
                canInteract = function()
                    return postalJobState.isDoingJob
                end,
                distance = 3.0,
                onSelect = deliverPackageToPed,
            },
        })
    elseif (Config.TARGET == 'qb-target') then
        exports['qb-target']:AddTargetEntity(deliverToPed, {
            options = {
                {
                    type = "client",
                    icon = 'fa-solid fa-envelope',
                    label = t('drop_off_package'),
                    canInteract = function()
                        return postalJobState.isDoingJob
                    end,
                    action = function()
                        deliverPackageToPed()
                    end,
                }
            },
            distance = 3.0,
        })
    else
        -- put in custom logic to grab target and delete print code underneath
        print('^6[^3dream-postal^6]^0 Unsupported Target detected!')
    end
end

function deliverPackageToPed()
    -- check if player is clocked in
    if (not postalJobState.isDoingJob) then
        return
    end

    -- check if location of van is within distance
    local dropOffCoords = postalJobState.dropOffCoords
    local vehicleCoords = GetEntityCoords(postalJobState.goPostalVan)
    if #(dropOffCoords - vehicleCoords) > 30.00 then
        return
    end

    if (not postalJobState.isCarryingBox) then
        NotifyPlayer(t('where_is_the_package'), 'error', 7500)
        return
    end

    local playerPed = PlayerPedId()
    NotifyPlayer(t('you_delivered_the_package'), 'success')

    RemoveBlip(postalJobState.dropoffBlip)
    postalJobState.dropoffBlip = nil

    postalJobState.positionSet.endLocation = GetEntityCoords(playerPed)
    removeBox()

    TriggerServerEvent('dream-postal:server:compensateDelivery', postalJobState.positionSet)

    postalJobState.positionSet = {
        startLocation = nil,
        middleLocation = nil,
        endLocation = nil,
    }

    postalJobState.isCarryingBox = false

    -- TODO: add a thread that triggers a random animation from delivery ped before despawning
    postalJobState.isDeliveringPackage = false

    postalJobState.hasBoxInVan = false

    if (Config.TARGET == 'ox') then
        exports.ox_target:removeLocalEntity(postalJobState.goPostalVan, { 'put-package-in-van', 'take-out-package-from-van' })
    elseif (Config.TARGET == 'qb-target') then
        exports['qb-target']:RemoveTargetEntity(postalJobState.goPostalVan, { 'put-package-in-van', 'take-out-package-from-van' })
    else
        -- put in custom logic to grab target and delete print code underneath
        print('^6[^3dream-postal^6]^0 Unsupported Target detected!')
    end

    -- grab coords to go to pick up postal delivery
    local randomNumber = math.random(1, #POSTAL_GET_PACKAGE)
    local tempDeliveryCoords = POSTAL_GET_PACKAGE[randomNumber]

    local retval, groundZ = GetGroundZFor_3dCoord(tempDeliveryCoords.x, tempDeliveryCoords.y, tempDeliveryCoords.z, false)
    local deliveryCoords = tempDeliveryCoords
    if retval then
        deliveryCoords = vec3(tempDeliveryCoords.x, tempDeliveryCoords.y, groundZ)
    end

    SetNewWaypoint(deliveryCoords.x, deliveryCoords.y)

    local deliveryBlip = AddBlipForCoord(deliveryCoords)
	SetBlipSprite(deliveryBlip, PICK_UP_BLIP.sprite)
	SetBlipDisplay(deliveryBlip, PICK_UP_BLIP.display)
	SetBlipScale(deliveryBlip, PICK_UP_BLIP.scale)
	SetBlipColour(deliveryBlip, PICK_UP_BLIP.colour)
	SetBlipAsShortRange(deliveryBlip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentSubstringPlayerName(PICK_UP_BLIP.label)
	EndTextCommandSetBlipName(deliveryBlip)

    postalJobState.pickupBlip = deliveryBlip

    postalJobState.positionSet.startLocation = GetEntityCoords(playerPed)

    local parameters = {
        options = {{
            type   = "client",
            action = pickupMail,
            icon   = 'fas fa-envelope',
            label  = t('grab_package'),
        }},
        distance = 3.0,
        rotation = 45,
    }

    postalJobState.postalBoxZone = TARGET.AddBoxZone('dream-postal-grab-delivery', deliveryCoords, vec3(1.0, 1.0, 3.0), parameters)

    if (SHOW_WHITE_ARROW_MARKER) then
        CreateThread(function()
            while postalJobState.postalBoxZone do
                local playerCoords = GetEntityCoords(playerPed)
                local distanceToMarker = #(playerCoords - deliveryCoords)

                if (distanceToMarker <= 50.0) then
                    DrawMarker(22, deliveryCoords.x, deliveryCoords.y, (deliveryCoords.z + 1.75), 0, 0, 0, 0, 0, 1.0, 1.0, 1.0, 1.0, 255, 255, 220, 200, 0, 0, 0, 1)
                    Wait(1)
                else
                    Wait(3000)
                end
            end
        end)
    end
end

CreateThread(function()
    local blip = AddBlipForCoord(POSTAL_BOSS_COORDS)
	SetBlipSprite(blip, GO_POSTAL_HQ_BLIP.sprite)
	SetBlipDisplay(blip, GO_POSTAL_HQ_BLIP.display)
	SetBlipScale(blip, GO_POSTAL_HQ_BLIP.scale)
	SetBlipColour(blip, GO_POSTAL_HQ_BLIP.colour)
	SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentSubstringPlayerName(GO_POSTAL_HQ_BLIP.label)
	EndTextCommandSetBlipName(blip)
end)

CreateThread(function()
    while true do
        Citizen.Wait(2000)
        local playerCoords = GetEntityCoords(PlayerPedId())
        local distanceFromPed = #(POSTAL_BOSS_COORDS - playerCoords)

        if distanceFromPed < 200 and not isPedSpawned then
            isPedSpawned = true
            spawnPostalBossPed()
        end

        if postalBossPed and distanceFromPed >= 200 and isPedSpawned then
            isPedSpawned = false
            DeletePed(postalBossPed)
        end
    end
end)

RegisterCommand('removebox', function()
    if (not postalJobState.isCarryingBox) then return end
    removeBox()
end)

function removeBox()
    local playerPed = PlayerPedId()
    for _, v in pairs(GetGamePool("CObject")) do
        if IsEntityAttachedToEntity(playerPed, v) then
          SetEntityAsMissionEntity(v, true, true)
          DeleteObject(v)
          DeleteEntity(v)
        end
    end
    ClearPedTasks(playerPed)
end

local boxHash = `hei_prop_heist_box`
function carryBox()
    postalJobState.isCarryingBox = true
    local ped = PlayerPedId()
    local x,y,z = table.unpack(GetEntityCoords(ped))
    local prop = CreateObject(boxHash, x, y, z + 0.2,  true,  true, true)
	AttachEntityToEntity(prop, ped, GetPedBoneIndex(ped, 60309), 0.025, 0.08, 0.255, -145.0, 290.0, 0.0, true, true, false, true, 1, true)
    LoadDict('anim@heists@box_carry@')

    if not IsEntityPlayingAnim(ped, "anim@heists@box_carry@", "idle", 3 ) then
        TaskPlayAnim(ped, 'anim@heists@box_carry@', "idle", 3.0, -8, -1, 63, 0, false, false, false)
    end

    -- ensure player does not drive while they have box in their hand to stop powergaming.
    CreateThread(function()
        while (postalJobState.isCarryingBox) do
            if IsPedInAnyVehicle(PlayerPedId(), false) then
                NotifyPlayer(t('you_cannot_drive_with_box'), 'error', 3000)
                SetVehicleEngineOn(postalJobState.goPostalVan, false, false, true)
            end
            Wait(3000)
        end
    end)
end

function LoadDict(dict)
    RequestAnimDict(dict)
	while not HasAnimDictLoaded(dict) do
	  	Citizen.Wait(10)
    end
end

local mask, tmask, hand, thand, pants, tpants, backpack, tbackpack, shoes, tshoes
local accessories, taccessories, undershirt, tundershirt, jacket, tjacket
local bodyarmor, tbodyarmor, decal, tdecal, propGlasses, propGlassesTexture

local maleHash = `mp_m_freemode_01`
function putOnJobOutfit()
    local playerPed = PlayerPedId()
    local isMale = IsPedModel(playerPed, maleHash)

    mask = GetPedDrawableVariation(playerPed, 1)
    tmask = GetPedTextureVariation(playerPed, 1)

    hand = GetPedDrawableVariation(playerPed, 3)
    thand = GetPedTextureVariation(playerPed, 3)

    pants = GetPedDrawableVariation(playerPed, 4)
    tpants = GetPedTextureVariation(playerPed, 4)

    backpack = GetPedDrawableVariation(playerPed, 5)
    tbackpack = GetPedTextureVariation(playerPed, 5)

    shoes = GetPedDrawableVariation(playerPed, 6)
    tshoes = GetPedTextureVariation(playerPed, 6)

    accessories = GetPedDrawableVariation(playerPed, 7)
    taccessories = GetPedTextureVariation(playerPed, 7)

    undershirt = GetPedDrawableVariation(playerPed, 8)
    tundershirt = GetPedTextureVariation(playerPed, 8)

    bodyarmor = GetPedDrawableVariation(playerPed, 9)
    tbodyarmor = GetPedTextureVariation(playerPed, 9)

    decal = GetPedDrawableVariation(playerPed, 10)
    tdecal = GetPedTextureVariation(playerPed, 10)

    jacket = GetPedDrawableVariation(playerPed, 11)
    tjacket = GetPedTextureVariation(playerPed, 11)

    propGlasses = GetPedPropIndex(playerPed, 1)
    propGlassesTexture = GetPedPropTextureIndex(playerPed, 1)

    if isMale then
        SetPedComponentVariation(playerPed, 1, MALE_OUTFIT.mask, MALE_OUTFIT.maskTexture)
        SetPedComponentVariation(playerPed, 3, MALE_OUTFIT.hand, MALE_OUTFIT.handTexture)
        SetPedComponentVariation(playerPed, 4, MALE_OUTFIT.pants, MALE_OUTFIT.pantsTexture)
        SetPedComponentVariation(playerPed, 5, MALE_OUTFIT.backpack, MALE_OUTFIT.backpackTexture)
        SetPedComponentVariation(playerPed, 6, MALE_OUTFIT.shoes, MALE_OUTFIT.shoesTexture)
        SetPedComponentVariation(playerPed, 7, MALE_OUTFIT.accessories, MALE_OUTFIT.accessoriesTexture)
        SetPedComponentVariation(playerPed, 8, MALE_OUTFIT.shirt, MALE_OUTFIT.shirtTexture)
        SetPedComponentVariation(playerPed, 9, MALE_OUTFIT.bodyArmor, MALE_OUTFIT.bodyArmorTexture)
        SetPedComponentVariation(playerPed, 10, MALE_OUTFIT.decal, MALE_OUTFIT.decalTexture)
        SetPedComponentVariation(playerPed, 11, MALE_OUTFIT.jacket, MALE_OUTFIT.jacketTexture)
        SetPedPropIndex(playerPed, 1, MALE_OUTFIT.glasses, MALE_OUTFIT.glassesTexture)
    else
        SetPedComponentVariation(playerPed, 1, FEMALE_OUTFIT.mask, FEMALE_OUTFIT.maskTexture)
        SetPedComponentVariation(playerPed, 3, FEMALE_OUTFIT.hand, FEMALE_OUTFIT.handTexture)
        SetPedComponentVariation(playerPed, 4, FEMALE_OUTFIT.pants, FEMALE_OUTFIT.pantsTexture)
        SetPedComponentVariation(playerPed, 5, FEMALE_OUTFIT.backpack, FEMALE_OUTFIT.backpackTexture)
        SetPedComponentVariation(playerPed, 6, FEMALE_OUTFIT.shoes, FEMALE_OUTFIT.shoesTexture)
        SetPedComponentVariation(playerPed, 7, FEMALE_OUTFIT.accessories, FEMALE_OUTFIT.accessoriesTexture)
        SetPedComponentVariation(playerPed, 8, FEMALE_OUTFIT.shirt, FEMALE_OUTFIT.shirtTexture)
        SetPedComponentVariation(playerPed, 9, FEMALE_OUTFIT.bodyArmor, FEMALE_OUTFIT.bodyArmorTexture)
        SetPedComponentVariation(playerPed, 10, FEMALE_OUTFIT.decal, FEMALE_OUTFIT.decalTexture)
        SetPedComponentVariation(playerPed, 11, FEMALE_OUTFIT.jacket, FEMALE_OUTFIT.jacketTexture)
        SetPedPropIndex(playerPed, 1, FEMALE_OUTFIT.glasses, FEMALE_OUTFIT.glassesTexture)
    end
end

function takeOffJobOutfit()
    local playerPed = PlayerPedId()

    SetPedComponentVariation(playerPed, 1, mask, tmask)
    SetPedComponentVariation(playerPed, 3, hand, thand)
    SetPedComponentVariation(playerPed, 4, pants, tpants)
    SetPedComponentVariation(playerPed, 5, backpack, tbackpack)
    SetPedComponentVariation(playerPed, 6, shoes, tshoes)
    SetPedComponentVariation(playerPed, 7, accessories, taccessories)
    SetPedComponentVariation(playerPed, 8, undershirt, tundershirt)
    SetPedComponentVariation(playerPed, 9, bodyarmor, tbodyarmor)
    SetPedComponentVariation(playerPed, 10, decal, tdecal)
    SetPedComponentVariation(playerPed, 11, jacket, tjacket)

    if (propGlasses <= 0) then
        ClearPedProp(playerPed, 1)
    else
        SetPedPropIndex(playerPed, 1, propGlasses, propGlassesTexture)
    end
end

function getVehicles()
	return GetGamePool('CVehicle')
end

function EnumerateEntitiesWithinDistance(entities, isPlayerEntities, coords, maxDistance)
	local nearbyEntities = {}

	if coords then
		coords = vector3(coords.x, coords.y, coords.z)
	else
		coords = GetEntityCoords(PlayerPedId())
	end

	for k, entity in pairs(entities) do
		if #(coords - GetEntityCoords(entity)) <= maxDistance then
			table.insert(nearbyEntities, isPlayerEntities and k or entity)
		end
	end

	return nearbyEntities
end

function getVehiclesInArea(coords, maxDistance)
	return EnumerateEntitiesWithinDistance(getVehicles(), false, coords, maxDistance)
end

function isSpawnPointClear(coords, maxDistance)
	return #getVehiclesInArea(coords, maxDistance) == 0
end

AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then
        if (postalJobState.isDoingJob) then
            NotifyPlayer(t('force_clock_out_script_restart'))
            takeOffJobOutfit()
            if (postalJobState.isCarryingBox) then
                removeBox()
            end
            resetJobState()
        end
    end
end)
