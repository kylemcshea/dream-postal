TARGET = {}

function TARGET.IsOX()
    return GetResourceState("ox_target") ~= "missing" or Config.TARGET == 'ox'
end

function TARGET.IsQB()
    return GetResourceState("qb-target") ~= "missing" or Config.TARGET == 'qb-target'
end
