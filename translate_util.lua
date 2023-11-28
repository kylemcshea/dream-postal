local tObject = DREAM_TRANSLATE[Config.LANGUAGE]

---@param key string
---@param values table | nil
function t(key, values)
    if not tObject[key] then
        print('Translation key not found: ' .. key)
        return key
    end

    local text = tObject[key]

    if (not values) then
        return text
    end

    for tKey, value in pairs(values) do
        text = text:gsub('{{ ' .. tKey .. ' }}', tostring(value))
    end

    return text
end
