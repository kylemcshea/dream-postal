if not TARGET.IsOX() then return end

local ZoneIDMap = {}

local function convert(options)
    local distance = options.distance
    options = options.options
    for _, v in pairs(options) do
        v.onSelect = v.action
        v.distance = v.distance or distance
        v.name = v.name or v.label
        v.groups = v.job or v.gang
        v.type = nil
        v.action = nil

        v.job = nil
        v.gang = nil
        v.qtarget = true
    end

    return options
end

---@param entity number
---@param labels table | string 
function TARGET.RemoveLocalEntity(entity, labels)
    -- TODO: set this up to work.
    -- exports.ox_target:removeLocalEntity(entity, labels)
end

function TARGET.RemoveZone(id)
    exports.ox_target:removeZone(ZoneIDMap[id])
end

function TARGET.AddBoxZone(name, coords, size, parameters)
    local rotation = parameters.rotation
    local boxZone = exports["ox_target"]:addBoxZone({
        coords = coords,
        size = size,
        rotation = rotation,
        debug = Config.DEBUG,
        options = convert(parameters)
    })

    ZoneIDMap[name] = boxZone

    return boxZone
end
