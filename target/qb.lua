if not TARGET.IsQB() then return end

---@param entity number
---@param labels table | string 
function TARGET.RemoveLocalEntity(entity, labels)
    -- TODO: set this up to work.
    -- exports['qb-target']:RemoveTargetEntity(entity, labels)
end

function TARGET.RemoveZone(id)
    exports['qb-target']:RemoveZone(id)
end

function TARGET.AddBoxZone(name, coords, size, parameters)
    local boxZone = exports["qb-target"]:AddBoxZone(name, coords, size.x, size.y, {
        name = name,
        debugPoly = Config.DEBUG,
        minZ = coords.z - 2,
        maxZ = coords.z + 2,
        heading = coords.w
    }, parameters)

    return boxZone
end